import 'package:equatable/equatable.dart';

enum PetSpecies { dog, cat, bird, rabbit, fish, reptile, other }

enum PetGender { male, female, unknown }

class Pet extends Equatable {
  final String id;
  final String householdId;
  final String name;
  final PetSpecies species;
  final String? breed;
  final PetGender gender;
  final DateTime? birthDate;
  final double? weightKg;
  final String? imageUrl;
  final String? notes;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const Pet({
    required this.id,
    required this.householdId,
    required this.name,
    required this.species,
    this.breed,
    this.gender = PetGender.unknown,
    this.birthDate,
    this.weightKg,
    this.imageUrl,
    this.notes,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    required this.lastUpdate,
  });

  int? get ageYears {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  Pet copyWith({
    String? id,
    String? householdId,
    String? name,
    PetSpecies? species,
    String? breed,
    bool clearBreed = false,
    PetGender? gender,
    DateTime? birthDate,
    bool clearBirthDate = false,
    double? weightKg,
    bool clearWeight = false,
    String? imageUrl,
    bool clearImage = false,
    String? notes,
    bool clearNotes = false,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) {
    return Pet(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: clearBreed ? null : (breed ?? this.breed),
      gender: gender ?? this.gender,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      weightKg: clearWeight ? null : (weightKg ?? this.weightKg),
      imageUrl: clearImage ? null : (imageUrl ?? this.imageUrl),
      notes: clearNotes ? null : (notes ?? this.notes),
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  List<Object?> get props => [id, householdId, name, species, isActive];
}
