import 'package:hestia/data/dtos/car_maintenance_record_dto.dart';
import 'package:hestia/domain/entities/car_maintenance_record.dart';

abstract final class CarMaintenanceRecordMapper {
  static CarMaintenanceRecord fromDto(CarMaintenanceRecordDto dto) {
    return CarMaintenanceRecord(
      id: dto.id,
      carId: dto.carId,
      type: MaintenanceType.values.firstWhere(
        (t) => t.name == dto.type,
        orElse: () => MaintenanceType.other,
      ),
      title: dto.title,
      workshop: dto.workshop,
      notes: dto.notes,
      recordedAt: dto.recordedAt,
      nextDueAt: dto.nextDueAt,
      odometerKm: dto.odometerKm,
      cost: dto.cost,
      transactionId: dto.transactionId,
      appointmentId: dto.appointmentId,
      createdBy: dto.createdBy,
      createdAt: dto.createdAt,
    );
  }

  static CarMaintenanceRecordDto toDto(CarMaintenanceRecord record) {
    return CarMaintenanceRecordDto(
      id: record.id,
      carId: record.carId,
      type: record.type.name,
      title: record.title,
      workshop: record.workshop,
      notes: record.notes,
      recordedAt: record.recordedAt,
      nextDueAt: record.nextDueAt,
      odometerKm: record.odometerKm,
      cost: record.cost,
      transactionId: record.transactionId,
      appointmentId: record.appointmentId,
      createdBy: record.createdBy,
      createdAt: record.createdAt,
    );
  }
}
