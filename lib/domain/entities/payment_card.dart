import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

class PaymentCard extends Equatable {
  final String id;
  final String accountId;
  final String? ownerProfileId;
  final CardNetwork network;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final String cardholderName;
  final bool isVirtual;
  final bool isPrimary;
  final bool isActive;
  final String? color;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime lastUpdate;

  // Joined fields (resolved by repository)
  final String? institutionName;
  final String? institutionLogoAsset;
  final String? institutionBrandColor;
  final String? ownerName;

  const PaymentCard({
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
    this.institutionName,
    this.institutionLogoAsset,
    this.institutionBrandColor,
    this.ownerName,
  });

  String get networkLogoAsset => 'assets/networks/${network.value}.svg';

  String get maskedNumber => '**** **** **** $last4';

  String get expiryFormatted =>
      '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}';

  PaymentCard copyWith({
    String? id,
    String? accountId,
    String? ownerProfileId,
    bool clearOwnerProfileId = false,
    CardNetwork? network,
    String? last4,
    int? expiryMonth,
    int? expiryYear,
    String? cardholderName,
    bool? isVirtual,
    bool? isPrimary,
    bool? isActive,
    String? color,
    bool clearColor = false,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? lastUpdate,
    String? institutionName,
    String? institutionLogoAsset,
    String? institutionBrandColor,
    String? ownerName,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      ownerProfileId: clearOwnerProfileId
          ? null
          : (ownerProfileId ?? this.ownerProfileId),
      network: network ?? this.network,
      last4: last4 ?? this.last4,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardholderName: cardholderName ?? this.cardholderName,
      isVirtual: isVirtual ?? this.isVirtual,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      color: clearColor ? null : (color ?? this.color),
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      institutionName: institutionName ?? this.institutionName,
      institutionLogoAsset: institutionLogoAsset ?? this.institutionLogoAsset,
      institutionBrandColor:
          institutionBrandColor ?? this.institutionBrandColor,
      ownerName: ownerName ?? this.ownerName,
    );
  }

  @override
  List<Object?> get props => [id, accountId, network, last4];
}
