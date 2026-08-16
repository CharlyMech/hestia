import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';

import 'supabase_service.dart';

class AccountMemberService extends SupabaseService {
  AccountMemberService({super.client});

  Future<List<Map<String, dynamic>>> getMembers(String accountId) async {
    try {
      final response = await from(SupabaseTables.accountMembers)
          .select('*, profiles:user_id(display_name, avatar_url)')
          .eq('account_id', accountId)
          .order('joined_at');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch account members: $e');
    }
  }

  Future<void> addMember(Map<String, dynamic> data) async {
    try {
      await from(SupabaseTables.accountMembers).insert(data);
    } catch (e) {
      throw ServerException('Failed to add account member: $e');
    }
  }

  Future<void> updateRole(String memberId, String role) async {
    try {
      await from(SupabaseTables.accountMembers)
          .update({'role': role}).eq('id', memberId);
    } catch (e) {
      throw ServerException('Failed to update member role: $e');
    }
  }

  Future<void> removeMember(String memberId) async {
    try {
      await from(SupabaseTables.accountMembers).delete().eq('id', memberId);
    } catch (e) {
      throw ServerException('Failed to remove account member: $e');
    }
  }
}
