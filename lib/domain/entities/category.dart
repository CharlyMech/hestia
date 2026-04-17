import 'package:equatable/equatable.dart';
import 'package:home_expenses/core/constants/enums.dart';

class Category extends Equatable {
  final String id;
  final String householdId;
  final String name;
  final TransactionType type;
  final String? color;
  final String? icon;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const Category({
    required this.id,
    required this.householdId,
    required this.name,
    required this.type,
    this.color,
    this.icon,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [id, householdId, name, type, isActive];
}
