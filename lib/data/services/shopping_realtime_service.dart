import 'package:hestia/core/config/flavor.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/data/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Realtime subscriptions for collaborative shopping.
///
/// No-ops when the app runs in mock flavor or Supabase is not initialized.
class ShoppingRealtimeService extends SupabaseService {
  ShoppingRealtimeService({super.client});

  bool get _enabled => FlavorConfig.isSupabase && isInitialized;

  /// Item-level changes for a single list (detail screen).
  RealtimeChannel? subscribeToListItems({
    required String listId,
    required void Function() onChanged,
  }) {
    if (!_enabled) return null;
    try {
      return client
          .channel('shopping-list-items-$listId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'shopping_list_items',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'list_id',
              value: listId,
            ),
            callback: (_) => onChanged(),
          )
          .subscribe();
    } catch (e, st) {
      logger.w('shopping_list_items realtime subscribe failed',
          error: e, stackTrace: st);
      return null;
    }
  }

  /// List metadata + session rows for the shopping index screen.
  RealtimeChannel? subscribeToHouseholdShopping({
    required String householdId,
    required void Function() onChanged,
  }) {
    if (!_enabled) return null;
    try {
      return client
          .channel('shopping-household-$householdId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'shopping_lists',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'household_id',
              value: householdId,
            ),
            callback: (_) => onChanged(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'shopping_sessions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'household_id',
              value: householdId,
            ),
            callback: (_) => onChanged(),
          )
          .subscribe();
    } catch (e, st) {
      logger.w('household shopping realtime subscribe failed',
          error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> unsubscribe(RealtimeChannel? channel) async {
    if (channel == null || !_enabled) return;
    try {
      await client.removeChannel(channel);
    } catch (e, st) {
      logger.w('realtime unsubscribe failed', error: e, stackTrace: st);
    }
  }
}
