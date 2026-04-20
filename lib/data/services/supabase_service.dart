import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized access to the Supabase client.
/// Every service extends or uses this.
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  SupabaseClient get client => _client;

  GoTrueClient get auth => _client.auth;

  /// Current authenticated user ID. Throws if not logged in.
  String get currentUserId {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('User is not authenticated');
    return uid;
  }

  /// Current user ID or null
  String? get currentUserIdOrNull => _client.auth.currentUser?.id;

  /// Build a query on a table
  SupabaseQueryBuilder from(String table) => _client.from(table);

  /// Current session
  Session? get currentSession => _client.auth.currentSession;
}
