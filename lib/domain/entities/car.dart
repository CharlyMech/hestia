import 'package:equatable/equatable.dart';

enum FuelType { gasoline, diesel, electric, hybrid }

enum CarStatus { active, sold, scrap }

class Car extends Equatable {
  final String id;
  final String householdId;
  final String name;
  final String? imageUrl;
  final String? make;
  final String? model;
  final int? year;
  final String? licensePlate;
  final FuelType fuelType;
  final double? tankCapacityLiters;
  final double? currentOdometerKm;
  final CarStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const Car({
    required this.id,
    required this.householdId,
    required this.name,
    this.imageUrl,
    this.make,
    this.model,
    this.year,
    this.licensePlate,
    this.fuelType = FuelType.gasoline,
    this.tankCapacityLiters,
    this.currentOdometerKm,
    this.status = CarStatus.active,
    required this.createdBy,
    required this.createdAt,
    required this.lastUpdate,
  });

  Car copyWith({
    String? id,
    String? householdId,
    String? name,
    String? imageUrl,
    bool clearImage = false,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    FuelType? fuelType,
    double? tankCapacityLiters,
    double? currentOdometerKm,
    bool clearOdometer = false,
    CarStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) {
    return Car(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      imageUrl: clearImage ? null : (imageUrl ?? this.imageUrl),
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      fuelType: fuelType ?? this.fuelType,
      tankCapacityLiters: tankCapacityLiters ?? this.tankCapacityLiters,
      currentOdometerKm:
          clearOdometer ? null : (currentOdometerKm ?? this.currentOdometerKm),
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  List<Object?> get props => [id, householdId, name, status, fuelType];
}
