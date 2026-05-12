import 'package:equatable/equatable.dart';

class CarMember extends Equatable {
  final String id;
  final String carId;
  final String userId;
  final String role;
  final DateTime createdAt;

  const CarMember({
    required this.id,
    required this.carId,
    required this.userId,
    this.role = 'driver',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, carId, userId, role];
}
