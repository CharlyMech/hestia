import 'package:equatable/equatable.dart';

class Household extends Equatable {
  final String id;
  final String name;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const Household({
    required this.id,
    required this.name,
    this.createdBy,
    required this.createdAt,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [id, name];
}

class HouseholdMember extends Equatable {
  final String id;
  final String userId;
  final String householdId;
  final String role;
  final DateTime createdAt;

  const HouseholdMember({
    required this.id,
    required this.userId,
    required this.householdId,
    required this.role,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, householdId, role];
}
