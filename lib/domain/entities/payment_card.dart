import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

class PaymentCard extends Equatable {
  final String id;
  final String accountId;
  final CardNetwork network;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final String cardholderName;
  final bool isVirtual;
  final bool isActive;
  final String? color;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime lastUpdate;

  // Joined fields (resolved by repository)
  final String? institutionName;
  final String? institutionLogoAsset;
  final String? institutionBrandColor;

  const PaymentCard({
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
    this.institutionName,
    this.institutionLogoAsset,
    this.institutionBrandColor,
  });

  String get networkLogoAsset => 'assets/networks/${network.value}.svg';

  String get maskedNumber => '**** **** **** $last4';

  String get expiryFormatted =>
      '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}';

  PaymentCard copyWith({
    String? id,
    String? accountId,
    CardNetwork? network,
    String? last4,
    int? expiryMonth,
    int? expiryYear,
    String? cardholderName,
    bool? isVirtual,
    bool? isActive,
    String? color,
    bool clearColor = false,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? lastUpdate,
    String? institutionName,
    String? institutionLogoAsset,
    String? institutionBrandColor,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      network: network ?? this.network,
      last4: last4 ?? this.last4,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardholderName: cardholderName ?? this.cardholderName,
      isVirtual: isVirtual ?? this.isVirtual,
      isActive: isActive ?? this.isActive,
      color: clearColor ? null : (color ?? this.color),
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      institutionName: institutionName ?? this.institutionName,
      institutionLogoAsset: institutionLogoAsset ?? this.institutionLogoAsset,
      institutionBrandColor:
          institutionBrandColor ?? this.institutionBrandColor,
    );
  }

  @override
  List<Object?> get props => [id, accountId, network, last4];
}
