import 'package:equatable/equatable.dart';

enum HealthRecordType { vaccine, vet, medication, grooming, deworming, other }

class PetHealthRecord extends Equatable {
  final String id;
  final String petId;
  final HealthRecordType type;
  final String title;
  final String? notes;
  final DateTime recordedAt;
  final DateTime? nextDueAt;
  final double? cost;
  final String? vetName;
  final String createdBy;
  final DateTime createdAt;

  const PetHealthRecord({
    required this.id,
    required this.petId,
    required this.type,
    required this.title,
    this.notes,
    required this.recordedAt,
    this.nextDueAt,
    this.cost,
    this.vetName,
    required this.createdBy,
    required this.createdAt,
  });

  PetHealthRecord copyWith({
    String? id,
    String? petId,
    HealthRecordType? type,
    String? title,
    String? notes,
    bool clearNotes = false,
    DateTime? recordedAt,
    DateTime? nextDueAt,
    bool clearNextDue = false,
    double? cost,
    bool clearCost = false,
    String? vetName,
    bool clearVet = false,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return PetHealthRecord(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      title: title ?? this.title,
      notes: clearNotes ? null : (notes ?? this.notes),
      recordedAt: recordedAt ?? this.recordedAt,
      nextDueAt: clearNextDue ? null : (nextDueAt ?? this.nextDueAt),
      cost: clearCost ? null : (cost ?? this.cost),
      vetName: clearVet ? null : (vetName ?? this.vetName),
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, petId, type, recordedAt];
}
