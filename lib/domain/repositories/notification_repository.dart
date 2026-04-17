import 'package:home_expenses/core/error/failures.dart';
import 'package:home_expenses/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<(List<AppNotification>, Failure?)> getNotifications({
    required String userId,
    bool unreadOnly = false,
    int limit = 50,
  });

  Future<Failure?> markAsRead(String notificationId);

  Future<Failure?> markAllAsRead(String userId);

  Future<(int, Failure?)> getUnreadCount(String userId);

  Future<Failure?> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
  });

  Future<Failure?> removeDeviceToken(String token);
}
