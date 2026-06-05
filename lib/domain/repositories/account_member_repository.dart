import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/account_member.dart';

abstract class AccountMemberRepository {
  Future<(List<AccountMember>, Failure?)> getMembers(String accountId);

  Future<Failure?> addMember({
    required String accountId,
    required String userId,
    required AccountMemberRole role,
  });

  Future<Failure?> updateRole(String memberId, AccountMemberRole role);

  Future<Failure?> removeMember(String memberId);
}
