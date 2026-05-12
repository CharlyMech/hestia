import 'package:equatable/equatable.dart';

/// Counterparty of a transaction — the merchant, employer, subscription
/// service or platform that the money flows to or from. Visible household-wide
/// (regardless of who created it). Optional on a transaction.
///
/// Examples: Netflix, Spotify, Mercadona, Lidl, Esloogan (employer), Stripe,
/// Vinted, Anthropic.
class TransactionSource extends Equatable {
  final String id;
  final String householdId;
  final String name;
  final TransactionSourceKind kind;
  final String? color;
  final String? icon;
  final String? imageUrl;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const TransactionSource({
    required this.id,
    required this.householdId,
    required this.name,
    this.kind = TransactionSourceKind.other,
    this.color,
    this.icon,
    this.imageUrl,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    required this.lastUpdate,
  });

  TransactionSource copyWith({
    String? id,
    String? householdId,
    String? name,
    TransactionSourceKind? kind,
    String? color,
    bool clearColor = false,
    String? icon,
    bool clearIcon = false,
    String? imageUrl,
    bool clearImageUrl = false,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) =>
      TransactionSource(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        color: clearColor ? null : (color ?? this.color),
        icon: clearIcon ? null : (icon ?? this.icon),
        imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
        isActive: isActive ?? this.isActive,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );

  @override
  List<Object?> get props => [id, householdId, name, kind, imageUrl];
}

enum TransactionSourceKind {
  merchant,
  employer,
  service,
  platform,
  other;

  String get value => name;

  static TransactionSourceKind fromString(String v) =>
      TransactionSourceKind.values.firstWhere(
        (k) => k.name == v,
        orElse: () => TransactionSourceKind.other,
      );
}
