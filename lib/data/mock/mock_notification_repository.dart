import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mock/mock_store.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/domain/repositories/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  @override
  Future<(List<AppNotification>, Failure?)> getNotifications({
    required String userId,
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    final list = MockStore.instance.notifications
        .where((n) => n.userId == userId)
        .where((n) => !unreadOnly || !n.isRead)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return (list.take(limit).toList(), null);
  }

  @override
  Future<Failure?> markAsRead(String notificationId) async {
    final list = MockStore.instance.notifications;
    final i = list.indexWhere((n) => n.id == notificationId);
    if (i < 0) return const ServerFailure('Notification not found');
    list[i] = _markRead(list[i]);
    return null;
  }

  @override
  Future<Failure?> markAllAsRead(String userId) async {
    final list = MockStore.instance.notifications;
    for (var i = 0; i < list.length; i++) {
      if (list[i].userId == userId && !list[i].isRead) {
        list[i] = _markRead(list[i]);
      }
    }
    return null;
  }

  @override
  Future<(int, Failure?)> getUnreadCount(String userId) async {
    final n = MockStore.instance.notifications
        .where((x) => x.userId == userId && !x.isRead)
        .length;
    return (n, null);
  }

  @override
  Future<Failure?> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
  }) async => null;

  @override
  Future<Failure?> removeDeviceToken(String token) async => null;

  AppNotification _markRead(AppNotification n) => AppNotification(
        id: n.id,
        userId: n.userId,
        householdId: n.householdId,
        title: n.title,
        body: n.body,
        type: n.type,
        payload: n.payload,
        isRead: true,
        createdAt: n.createdAt,
      );
}
