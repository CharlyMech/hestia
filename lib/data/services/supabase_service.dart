import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized access to the Supabase client.
/// Every service extends or uses this.
class SupabaseService {
  final SupabaseClient? _client;

  SupabaseService({SupabaseClient? client})
      : _client = client ?? _tryGetClient();

  static SupabaseClient? _tryGetClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isInitialized => _client != null;

  SupabaseClient get client {
    final c = _client;
    if (c == null) throw StateError('Supabase is not initialized');
    return c;
  }

  GoTrueClient get auth => client.auth;

  /// Current authenticated user ID. Throws if not logged in.
  String get currentUserId {
    final uid = _client?.auth.currentUser?.id;
    if (uid == null) throw StateError('User is not authenticated');
    return uid;
  }

  /// Current user ID or null
  String? get currentUserIdOrNull => _client?.auth.currentUser?.id;

  /// Build a query on a table
  SupabaseQueryBuilder from(String table) => client.from(table);

  /// Current session
  Session? get currentSession => _client?.auth.currentSession;
}
