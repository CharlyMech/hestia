class CarMaintenanceRecordDto {
  final String id;
  final String carId;
  final String type;
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

  const CarMaintenanceRecordDto({
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

  factory CarMaintenanceRecordDto.fromJson(Map<String, dynamic> json) {
    return CarMaintenanceRecordDto(
      id: json['id'] as String,
      carId: json['car_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      workshop: json['workshop'] as String?,
      notes: json['notes'] as String?,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(
          (json['recorded_at'] as int) * 1000),
      nextDueAt: json['next_due_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['next_due_at'] as int) * 1000)
          : null,
      odometerKm: (json['odometer_km'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toDouble(),
      transactionId: json['transaction_id'] as String?,
      appointmentId: json['appointment_id'] as String?,
      createdBy: json['created_by'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (json['created_at'] as int) * 1000),
    );
  }

  /// Used for insert — omits id, createdAt, lastUpdate (handled server-side).
  Map<String, dynamic> toInsertJson() => {
        'car_id': carId,
        'type': type,
        'title': title,
        if (workshop != null) 'workshop': workshop,
        if (notes != null) 'notes': notes,
        'recorded_at': recordedAt.millisecondsSinceEpoch ~/ 1000,
        if (nextDueAt != null)
          'next_due_at': nextDueAt!.millisecondsSinceEpoch ~/ 1000,
        if (odometerKm != null) 'odometer_km': odometerKm,
        if (cost != null) 'cost': cost,
        if (transactionId != null) 'transaction_id': transactionId,
        if (appointmentId != null) 'appointment_id': appointmentId,
        'created_by': createdBy,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'car_id': carId,
        'type': type,
        'title': title,
        'workshop': workshop,
        'notes': notes,
        'recorded_at': recordedAt.millisecondsSinceEpoch ~/ 1000,
        'next_due_at': nextDueAt != null
            ? nextDueAt!.millisecondsSinceEpoch ~/ 1000
            : null,
        'odometer_km': odometerKm,
        'cost': cost,
        'transaction_id': transactionId,
        'appointment_id': appointmentId,
        'created_by': createdBy,
        'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      };
}
