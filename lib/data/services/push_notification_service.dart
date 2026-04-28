import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hestia/core/error/error_handler.dart';

/// Handles Firebase Cloud Messaging setup and listeners.
/// Token storage is delegated to NotificationService.
class PushNotificationService {
  final FirebaseMessaging _messaging;

  PushNotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  /// Initialize Firebase and request permissions
  Future<void> initialize() async {
    await Firebase.initializeApp();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    logger.i('Push permission status: ${settings.authorizationStatus}');

    // Set foreground presentation options (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Get the current FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      logger.e('Failed to get FCM token', error: e);
      return null;
    }
  }

  /// Listen for token refresh events
  void onTokenRefresh(void Function(String token) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }

  /// Listen for foreground messages
  void onForegroundMessage(void Function(RemoteMessage message) callback) {
    FirebaseMessaging.onMessage.listen(callback);
  }

  /// Listen for when user taps a notification (app in background)
  void onMessageOpenedApp(void Function(RemoteMessage message) callback) {
    FirebaseMessaging.onMessageOpenedApp.listen(callback);
  }

  /// Check if app was opened from a notification (app was terminated)
  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }

  /// Delete token on logout
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      logger.e('Failed to delete FCM token', error: e);
    }
  }
}
