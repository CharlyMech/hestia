import 'package:hestia/core/error/failures.dart';
import 'package:hestia/domain/entities/pet.dart';
import 'package:hestia/domain/entities/pet_health_record.dart';

abstract class PetRepository {
  Future<(List<Pet>, Failure?)> getPets({
    required String householdId,
    bool activeOnly = true,
  });

  Future<(Pet?, Failure?)> getPet(String id);

  Future<(Pet?, Failure?)> createPet(Pet pet);

  Future<Failure?> updatePet(Pet pet);

  Future<Failure?> deletePet(String id);

  Future<(List<PetHealthRecord>, Failure?)> getHealthRecords(String petId);

  Future<(PetHealthRecord?, Failure?)> createHealthRecord(
      PetHealthRecord record);

  Future<Failure?> updateHealthRecord(PetHealthRecord record);

  Future<Failure?> deleteHealthRecord(String id);
}
