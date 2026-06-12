import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/services/supabase_service.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRealtimeService extends SupabaseService {
  NotificationRealtimeService({super.client});

  /// Subscribes to INSERT events on `notifications` for [userId].
  /// Calls [onNew] with the fully parsed entity each time a row arrives.
  /// Returns the channel so the caller can unsubscribe later.
  RealtimeChannel? subscribe({
    required String userId,
    required void Function(AppNotification) onNew,
  }) {
    if (!isInitialized) return null;
    try {
      return client
          .channel('notifications-$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              try {
                final row = payload.newRecord;
                final n = AppNotification(
                  id: row['id'] as String,
                  userId: row['user_id'] as String,
                  householdId: row['household_id'] as String,
                  title: row['title'] as String,
                  body: row['body'] as String,
                  type: NotificationType.fromString(row['type'] as String),
                  payload: row['payload'] as Map<String, dynamic>?,
                  isRead: (row['is_read'] as bool?) ?? false,
                  createdAt: (row['created_at'] as num).toInt().fromUnix,
                );
                onNew(n);
              } catch (e, st) {
                logger.e('realtime notification parse failed',
                    error: e, stackTrace: st);
              }
            },
          )
          .subscribe();
    } catch (e, st) {
      logger.w('notifications realtime subscribe failed',
          error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> unsubscribe(RealtimeChannel? channel) async {
    if (channel == null || !isInitialized) return;
    try {
      await client.removeChannel(channel);
    } catch (e, st) {
      logger.w('notifications realtime unsubscribe failed',
          error: e, stackTrace: st);
    }
  }
}
