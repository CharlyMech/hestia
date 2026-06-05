import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/date_utils.dart';
import 'package:hestia/data/dtos/account_member_dto.dart';
import 'package:hestia/domain/entities/account_member.dart';

abstract final class AccountMemberMapper {
  static AccountMember toDomain(AccountMemberDto dto) {
    final profile = dto.profiles;
    return AccountMember(
      id: dto.id,
      accountId: dto.accountId,
      userId: dto.userId,
      role: AccountMemberRole.fromString(dto.role),
      joinedAt: dto.joinedAt.fromUnix,
      userName: profile?['display_name'] as String?,
      userAvatar: profile?['avatar_url'] as String?,
    );
  }

  static AccountMemberDto toDto(AccountMember entity) {
    return AccountMemberDto(
      id: entity.id,
      accountId: entity.accountId,
      userId: entity.userId,
      role: entity.role.value,
      joinedAt: entity.joinedAt.toUnix,
    );
  }

  static AccountMember fromJson(Map<String, dynamic> json) {
    return toDomain(AccountMemberDto.fromJson(json));
  }
}
