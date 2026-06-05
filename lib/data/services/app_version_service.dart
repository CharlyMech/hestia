import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class AppVersionService extends SupabaseService {
  AppVersionService({super.client});

  Future<Map<String, dynamic>?> getLatestVersion({
    required String platform,
  }) async {
    try {
      final response = await from(SupabaseTables.appVersions)
          .select()
          .eq('platform', platform)
          .eq('is_active', true)
          .order('build_number', ascending: false)
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e) {
      throw ServerException('Failed to fetch app version: $e');
    }
  }
}
