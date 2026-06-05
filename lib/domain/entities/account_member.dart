import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

class AccountMember extends Equatable {
  final String id;
  final String accountId;
  final String userId;
  final AccountMemberRole role;
  final DateTime joinedAt;

  // Joined fields
  final String? userName;
  final String? userAvatar;

  const AccountMember({
    required this.id,
    required this.accountId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.userName,
    this.userAvatar,
  });

  bool get isOwner => role == AccountMemberRole.owner;

  @override
  List<Object?> get props => [id, accountId, userId];
}
