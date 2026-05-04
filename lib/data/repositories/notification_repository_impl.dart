import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/dtos/notification_dto.dart';
import 'package:hestia/data/services/notification_service.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _service;

  NotificationRepositoryImpl(this._service);

  @override
  Future<(List<AppNotification>, Failure?)> getNotifications({
    required String userId,
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      final data = await _service.getNotifications(
        userId: userId,
        unreadOnly: unreadOnly,
        limit: limit,
      );

      final notifications = data.map((json) {
        final dto = NotificationDto.fromJson(json);
        return AppNotification(
          id: dto.id,
          userId: dto.userId,
          householdId: dto.householdId,
          title: dto.title,
          body: dto.body,
          type: NotificationType.fromString(dto.type),
          payload: dto.payload,
          isRead: dto.isRead,
          createdAt: dto.createdAt.fromUnix,
        );
      }).toList();

      return (notifications, null);
    } catch (e) {
      return (<AppNotification>[], mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> markAsUnread(String notificationId) async {
    try {
      await _service.markAsUnread(notificationId);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> markAllAsRead(String userId) async {
    try {
      await _service.markAllAsRead(userId);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> delete(String notificationId) async {
    try {
      await _service.delete(notificationId);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<(int, Failure?)> getUnreadCount(String userId) async {
    try {
      final count = await _service.getUnreadCount(userId);
      return (count, null);
    } catch (e) {
      return (0, mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      await _service.registerDeviceToken(
        userId: userId,
        token: token,
        platform: platform,
      );
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> removeDeviceToken(String token) async {
    try {
      await _service.removeDeviceToken(token);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}
