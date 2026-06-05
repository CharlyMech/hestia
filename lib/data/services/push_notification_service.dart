import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/env.dart';
import 'package:hestia/core/config/firebase_options.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/data/services/notification_service.dart';
import 'package:hestia/presentation/widgets/common/app_toast.dart';

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  if (Env.isFirebaseConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  logger.d('Background push received: ${message.messageId}');
}

/// Full FCM integration:
/// - Requests permission
/// - Registers / refreshes token in Supabase `device_tokens`
/// - Shows in-app [AppToast] for foreground messages
/// - Routes to the correct screen on notification tap (background + terminated)
class PushNotificationService {
  final NotificationService _notificationSvc;
  final FirebaseMessaging _messaging;

  PushNotificationService(
    this._notificationSvc, {
    FirebaseMessaging? messaging,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  /// Call once immediately after the user is authenticated.
  Future<void> initialize({required String userId}) async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Do NOT cold-prompt here — the OS dialog is shown in onboarding/settings.
    // Read the current status without requesting it.
    final settings = await _messaging.getNotificationSettings();
    logger.i('Push permission: ${settings.authorizationStatus}');
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Only register a token once the user has actually granted permission.
    if (granted) {
      final token = await _getFcmToken();
      if (token != null) await _registerToken(userId, token);
    }

    _messaging.onTokenRefresh.listen((t) => _registerToken(userId, t));

    FirebaseMessaging.onMessage.listen(_handleForeground);

    FirebaseMessaging.onMessageOpenedApp.listen(_routeFromMessage);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _routeFromMessage(initial);
      });
    }
  }

  /// Shows the OS notification permission dialog (onboarding / settings).
  /// Registers the FCM token immediately if the user grants it.
  Future<bool> requestPermission({String? userId}) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    if (granted && userId != null) {
      final token = await _getFcmToken();
      if (token != null) await _registerToken(userId, token);
    }
    return granted;
  }

  /// Call on sign-out — removes token from Supabase and deletes it locally.
  Future<void> onSignOut() async {
    try {
      final token = await _getFcmToken();
      if (token != null) await _notificationSvc.removeDeviceToken(token);
      await _messaging.deleteToken();
      logger.i('FCM token cleaned up on sign-out');
    } on FirebaseException catch (e) {
      if (e.code == 'apns-token-not-set') {
        logger.d('FCM cleanup skipped: APNS token not available');
        return;
      }
      logger.e('Failed to clean up FCM token on sign-out', error: e);
    } catch (e) {
      logger.e('Failed to clean up FCM token on sign-out', error: e);
    }
  }

  // ── Private ────────────────────────────────────────────────────────────────

  /// FCM on iOS requires APNS; simulators often never provide a token.
  Future<String?> _getFcmToken() async {
    try {
      if (Platform.isIOS) {
        final apns = await _messaging.getAPNSToken();
        if (apns == null) {
          logger.d(
            'APNS token not available — FCM skipped (iOS Simulator or early launch)',
          );
          return null;
        }
      }
      return await _messaging.getToken();
    } on FirebaseException catch (e) {
      if (e.code == 'apns-token-not-set') {
        logger.d('FCM token unavailable: ${e.message}');
        return null;
      }
      logger.e('Failed to get FCM token', error: e);
      return null;
    } catch (e) {
      logger.e('Failed to get FCM token', error: e);
      return null;
    }
  }

  Future<void> _registerToken(String userId, String token) async {
    try {
      await _notificationSvc.registerDeviceToken(
        userId: userId,
        token: token,
        platform: Platform.isIOS ? 'ios' : 'android',
      );
      logger.d('FCM token registered for user $userId');
    } catch (e) {
      logger.e('Failed to register FCM token', error: e);
    }
  }

  void _handleForeground(RemoteMessage msg) {
    final notification = msg.notification;
    if (notification == null) return;

    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;

    ctx.showToast(AppToastConfig(
      type: _toastTypeFor(msg.data),
      title: notification.title ?? 'Notification',
      description: notification.body,
      actionLabel: 'View',
      onAction: () => _routeFromMessage(msg),
      position: ToastPosition.top,
      duration: const Duration(seconds: 5),
    ));
  }

  void _routeFromMessage(RemoteMessage msg) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;

    final type = msg.data['type'] as String?;
    final id = msg.data['id'] as String?;

    switch (type) {
      case 'transaction':
        ctx.push(AppRoutes.transactions);
      case 'goal':
        ctx.push(AppRoutes.goals);
      case 'shopping_session':
        if (id != null) {
          ctx.push(AppRoutes.shoppingListDetail, extra: id);
        } else {
          ctx.push(AppRoutes.notifications);
        }
      case 'reminder':
      case 'appointment':
        ctx.push(AppRoutes.calendarScreen);
      case 'alert':
      case 'system':
      default:
        ctx.push(AppRoutes.notifications);
    }
  }

  ToastType _toastTypeFor(Map<String, dynamic> data) =>
      switch (data['type'] as String?) {
        'transaction' => ToastType.success,
        'goal' => ToastType.info,
        'shopping_session' => ToastType.info,
        'alert' => ToastType.warning,
        _ => ToastType.neutral,
      };
}
