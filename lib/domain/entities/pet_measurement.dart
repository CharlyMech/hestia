import 'package:equatable/equatable.dart';

/// A single weight measurement recorded for a pet.
/// [recordedAt] is a unix millisecond timestamp.
/// [ageMonths] is computed from [Pet.birthDate] at recording time.
class PetMeasurement extends Equatable {
  final String id;
  final String petId;
  final int recordedAt;
  final double weightKg;

  /// Age in months at time of measurement (null if pet has no birthDate).
  final int? ageMonths;

  const PetMeasurement({
    required this.id,
    required this.petId,
    required this.recordedAt,
    required this.weightKg,
    this.ageMonths,
  });

  DateTime get recordedAtDate =>
      DateTime.fromMillisecondsSinceEpoch(recordedAt);

  PetMeasurement copyWith({
    String? id,
    String? petId,
    int? recordedAt,
    double? weightKg,
    int? ageMonths,
    bool clearAgeMonths = false,
  }) =>
      PetMeasurement(
        id: id ?? this.id,
        petId: petId ?? this.petId,
        recordedAt: recordedAt ?? this.recordedAt,
        weightKg: weightKg ?? this.weightKg,
        ageMonths: clearAgeMonths ? null : (ageMonths ?? this.ageMonths),
      );

  @override
  List<Object?> get props => [id, petId, recordedAt, weightKg];
}
