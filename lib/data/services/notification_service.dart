import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class NotificationService extends SupabaseService {
  NotificationService({super.client});

  Future<List<Map<String, dynamic>>> getNotifications({
    required String userId,
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      var query =
          from(SupabaseTables.notifications).select().eq('user_id', userId);

      if (unreadOnly) query = query.eq('is_read', false);

      final response =
          await query.order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await from(SupabaseTables.notifications)
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      throw ServerException('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAsUnread(String notificationId) async {
    try {
      await from(SupabaseTables.notifications)
          .update({'is_read': false}).eq('id', notificationId);
    } catch (e) {
      throw ServerException('Failed to mark notification as unread: $e');
    }
  }

  Future<void> delete(String notificationId) async {
    try {
      await from(SupabaseTables.notifications)
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw ServerException('Failed to delete notification: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await from(SupabaseTables.notifications)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw ServerException('Failed to mark all as read: $e');
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await from(SupabaseTables.notifications)
          .select()
          .eq('user_id', userId)
          .eq('is_read', false);
      return (response as List).length;
    } catch (e) {
      throw ServerException('Failed to get unread count: $e');
    }
  }

  Future<void> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      await from(SupabaseTables.deviceTokens).upsert({
        'user_id': userId,
        'token': token,
        'platform': platform,
        'is_active': true,
        'last_update': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      }, onConflict: 'user_id,token');
    } catch (e) {
      throw ServerException('Failed to register device token: $e');
    }
  }

  Future<void> removeDeviceToken(String token) async {
    try {
      await from(SupabaseTables.deviceTokens).delete().eq('token', token);
    } catch (e) {
      throw ServerException('Failed to remove device token: $e');
    }
  }
}
