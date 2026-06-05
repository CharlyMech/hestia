import 'package:equatable/equatable.dart';

enum FuelType { gasoline, diesel, electric, hybrid }

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
  final bool isActive;
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
    this.isActive = true,
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
    bool? isActive,
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
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  List<Object?> get props => [id, householdId, name, isActive, fuelType];
}
