import 'package:equatable/equatable.dart';

class FuelEntry extends Equatable {
  final String id;
  final String carId;
  final String? transactionId;
  final double odometerKm;
  final double liters;
  final double pricePerLiter;
  final double totalAmount;
  final bool isFullTank;
  final String? stationSourceId;
  final String? notes;
  final DateTime filledAt;
  final String createdBy;
  final DateTime createdAt;

  const FuelEntry({
    required this.id,
    required this.carId,
    this.transactionId,
    required this.odometerKm,
    required this.liters,
    required this.pricePerLiter,
    required this.totalAmount,
    this.isFullTank = true,
    this.stationSourceId,
    this.notes,
    required this.filledAt,
    required this.createdBy,
    required this.createdAt,
  });

  FuelEntry copyWith({
    String? id,
    String? carId,
    String? transactionId,
    double? odometerKm,
    double? liters,
    double? pricePerLiter,
    double? totalAmount,
    bool? isFullTank,
    String? stationSourceId,
    String? notes,
    DateTime? filledAt,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return FuelEntry(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      transactionId: transactionId ?? this.transactionId,
      odometerKm: odometerKm ?? this.odometerKm,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalAmount: totalAmount ?? this.totalAmount,
      isFullTank: isFullTank ?? this.isFullTank,
      stationSourceId: stationSourceId ?? this.stationSourceId,
      notes: notes ?? this.notes,
      filledAt: filledAt ?? this.filledAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, carId, filledAt, odometerKm, liters];
}
