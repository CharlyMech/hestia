import 'package:equatable/equatable.dart';

enum MaintenanceType { mechanic, itv, tires, oil, insurance, other }

class CarMaintenanceRecord extends Equatable {
  final String id;
  final String carId;
  final MaintenanceType type;
  final String title;
  final String? workshop;
  final String? notes;
  final DateTime recordedAt;
  final DateTime? nextDueAt;
  final int? odometerKm;
  final double? cost;
  final String? transactionId;
  final String? appointmentId;
  final String createdBy;
  final DateTime createdAt;

  const CarMaintenanceRecord({
    required this.id,
    required this.carId,
    required this.type,
    required this.title,
    this.workshop,
    this.notes,
    required this.recordedAt,
    this.nextDueAt,
    this.odometerKm,
    this.cost,
    this.transactionId,
    this.appointmentId,
    required this.createdBy,
    required this.createdAt,
  });

  CarMaintenanceRecord copyWith({
    String? id,
    String? carId,
    MaintenanceType? type,
    String? title,
    String? workshop,
    bool clearWorkshop = false,
    String? notes,
    bool clearNotes = false,
    DateTime? recordedAt,
    DateTime? nextDueAt,
    bool clearNextDueAt = false,
    int? odometerKm,
    bool clearOdometerKm = false,
    double? cost,
    bool clearCost = false,
    String? transactionId,
    bool clearTransactionId = false,
    String? appointmentId,
    bool clearAppointmentId = false,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CarMaintenanceRecord(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      type: type ?? this.type,
      title: title ?? this.title,
      workshop: clearWorkshop ? null : (workshop ?? this.workshop),
      notes: clearNotes ? null : (notes ?? this.notes),
      recordedAt: recordedAt ?? this.recordedAt,
      nextDueAt: clearNextDueAt ? null : (nextDueAt ?? this.nextDueAt),
      odometerKm: clearOdometerKm ? null : (odometerKm ?? this.odometerKm),
      cost: clearCost ? null : (cost ?? this.cost),
      transactionId:
          clearTransactionId ? null : (transactionId ?? this.transactionId),
      appointmentId:
          clearAppointmentId ? null : (appointmentId ?? this.appointmentId),
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, carId, type, recordedAt];
}
