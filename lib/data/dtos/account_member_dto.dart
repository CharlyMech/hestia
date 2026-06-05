class AccountMemberDto {
  final String id;
  final String accountId;
  final String userId;
  final String role;
  final int joinedAt;

  // Joined
  final Map<String, dynamic>? profiles;

  const AccountMemberDto({
    required this.id,
    required this.accountId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.profiles,
  });

  factory AccountMemberDto.fromJson(Map<String, dynamic> json) {
    return AccountMemberDto(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'owner',
      joinedAt: json['joined_at'] as int,
      profiles: json['profiles'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'account_id': accountId,
        'user_id': userId,
        'role': role,
        'joined_at': joinedAt,
      };

  Map<String, dynamic> toUpdateJson() => {
        'role': role,
      };
}
