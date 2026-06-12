class CardDto {
  final String id;
  final String accountId;
  final String? ownerProfileId;
  final String network;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final String cardholderName;
  final bool isVirtual;
  final bool isPrimary;
  final bool isActive;
  final String? color;
  final int sortOrder;
  final int createdAt;
  final int lastUpdate;

  // Joined (populated when fetched with relations)
  final Map<String, dynamic>? bankAccounts;
  final Map<String, dynamic>? ownerProfile;

  const CardDto({
    required this.id,
    required this.accountId,
    this.ownerProfileId,
    required this.network,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    this.isVirtual = false,
    this.isPrimary = false,
    this.isActive = true,
    this.color,
    this.sortOrder = 0,
    required this.createdAt,
    required this.lastUpdate,
    this.bankAccounts,
    this.ownerProfile,
  });

  factory CardDto.fromJson(Map<String, dynamic> json) {
    return CardDto(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      ownerProfileId: json['owner_profile_id'] as String?,
      network: json['network'] as String,
      last4: json['last4'] as String,
      expiryMonth: json['expiry_month'] as int,
      expiryYear: json['expiry_year'] as int,
      cardholderName: json['cardholder_name'] as String,
      isVirtual: json['is_virtual'] as bool? ?? false,
      isPrimary: json['is_primary'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      color: json['color'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] as int,
      lastUpdate: json['last_update'] as int,
      bankAccounts: json['bank_accounts'] as Map<String, dynamic>?,
      ownerProfile: json['profiles'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'account_id': accountId,
        if (ownerProfileId != null) 'owner_profile_id': ownerProfileId,
        'network': network,
        'last4': last4,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'cardholder_name': cardholderName,
        'is_virtual': isVirtual,
        'is_primary': isPrimary,
        'is_active': isActive,
        'color': color,
        'sort_order': sortOrder,
        'created_at': createdAt,
        'last_update': lastUpdate,
      };

  Map<String, dynamic> toUpdateJson() => {
        'owner_profile_id': ownerProfileId,
        'network': network,
        'last4': last4,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'cardholder_name': cardholderName,
        'is_virtual': isVirtual,
        'is_primary': isPrimary,
        'is_active': isActive,
        'color': color,
        'sort_order': sortOrder,
        'last_update': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
}
