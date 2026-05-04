import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<(List<AppNotification>, Failure?)> getNotifications({
    required String userId,
    bool unreadOnly = false,
    int limit = 50,
  });

  Future<Failure?> markAsRead(String notificationId);

  Future<Failure?> markAsUnread(String notificationId);

  Future<Failure?> markAllAsRead(String userId);

  Future<Failure?> delete(String notificationId);

  Future<(int, Failure?)> getUnreadCount(String userId);

  Future<Failure?> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
  });

  Future<Failure?> removeDeviceToken(String token);
}
