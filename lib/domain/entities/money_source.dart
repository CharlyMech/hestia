import 'package:equatable/equatable.dart';
import 'package:home_expenses/core/constants/enums.dart';

class MoneySource extends Equatable {
  final String id;
  final String householdId;
  final OwnerType ownerType;
  final String? ownerId;
  final String name;
  final String? institution;
  final AccountType accountType;
  final String currency;
  final double initialBalance;
  final double currentBalance;
  final bool isPrimary;
  final bool isActive;
  final String? color;
  final String? icon;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const MoneySource({
    required this.id,
    required this.householdId,
    required this.ownerType,
    this.ownerId,
    required this.name,
    this.institution,
    required this.accountType,
    this.currency = 'EUR',
    required this.initialBalance,
    required this.currentBalance,
    this.isPrimary = false,
    this.isActive = true,
    this.color,
    this.icon,
    this.sortOrder = 0,
    required this.createdAt,
    required this.lastUpdate,
  });

  /// Whether this is a personal account belonging to a specific user
  bool get isPersonal => ownerType == OwnerType.personal;

  /// Whether this is a shared household account
  bool get isShared => ownerType == OwnerType.shared;

  @override
  List<Object?> get props => [id, householdId, name, ownerType, accountType];
}
