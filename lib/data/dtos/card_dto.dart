class CardDto {
  final String id;
  final String accountId;
  final String network;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final String cardholderName;
  final bool isVirtual;
  final bool isActive;
  final String? color;
  final int sortOrder;
  final int createdAt;
  final int lastUpdate;

  // Joined (populated when fetched with account relation)
  final Map<String, dynamic>? bankAccounts;

  const CardDto({
    required this.id,
    required this.accountId,
    required this.network,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    this.isVirtual = false,
    this.isActive = true,
    this.color,
    this.sortOrder = 0,
    required this.createdAt,
    required this.lastUpdate,
    this.bankAccounts,
  });

  factory CardDto.fromJson(Map<String, dynamic> json) {
    return CardDto(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      network: json['network'] as String,
      last4: json['last4'] as String,
      expiryMonth: json['expiry_month'] as int,
      expiryYear: json['expiry_year'] as int,
      cardholderName: json['cardholder_name'] as String,
      isVirtual: json['is_virtual'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      color: json['color'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] as int,
      lastUpdate: json['last_update'] as int,
      bankAccounts: json['bank_accounts'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'account_id': accountId,
        'network': network,
        'last4': last4,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'cardholder_name': cardholderName,
        'is_virtual': isVirtual,
        'is_active': isActive,
        'color': color,
        'sort_order': sortOrder,
        'created_at': createdAt,
        'last_update': lastUpdate,
      };

  Map<String, dynamic> toUpdateJson() => {
        'network': network,
        'last4': last4,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'cardholder_name': cardholderName,
        'is_virtual': isVirtual,
        'is_active': isActive,
        'color': color,
        'sort_order': sortOrder,
        'last_update': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
}
