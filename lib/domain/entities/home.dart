import 'package:equatable/equatable.dart';

/// A household home with a mandatory physical location.
/// Transactions can be associated with a home via [Transaction.homeId].
class Home extends Equatable {
  final String id;
  final String householdId;
  final String name;
  final String address;

  /// Mandatory GPS coordinates.
  final double latitude;
  final double longitude;

  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  const Home({
    required this.id,
    required this.householdId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  Home copyWith({
    String? id,
    String? householdId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    bool clearDescription = false,
    String? imageUrl,
    bool clearImageUrl = false,
    DateTime? createdAt,
  }) =>
      Home(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        name: name ?? this.name,
        address: address ?? this.address,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        description:
            clearDescription ? null : (description ?? this.description),
        imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props =>
      [id, householdId, name, address, latitude, longitude];
}
