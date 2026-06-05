import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/data/mappers/account_member_mapper.dart';
import 'package:hestia/data/services/account_member_service.dart';
import 'package:hestia/domain/entities/account_member.dart';
import 'package:hestia/domain/repositories/account_member_repository.dart';

class AccountMemberRepositoryImpl implements AccountMemberRepository {
  final AccountMemberService _service;

  AccountMemberRepositoryImpl(this._service);

  @override
  Future<(List<AccountMember>, Failure?)> getMembers(String accountId) async {
    try {
      final data = await _service.getMembers(accountId);
      final members = data.map(AccountMemberMapper.fromJson).toList();
      return (members, null);
    } catch (e) {
      return (const <AccountMember>[], mapExceptionToFailure(e));
    }
  }

  @override
  Future<Failure?> addMember({
    required String accountId,
    required String userId,
    required AccountMemberRole role,
  }) async {
    try {
      await _service.addMember({
        'account_id': accountId,
        'user_id': userId,
        'role': role.value,
        'joined_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> updateRole(String memberId, AccountMemberRole role) async {
    try {
      await _service.updateRole(memberId, role.value);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Failure?> removeMember(String memberId) async {
    try {
      await _service.removeMember(memberId);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}
