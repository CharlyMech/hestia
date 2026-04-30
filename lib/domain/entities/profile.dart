import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String preferredCurrency;
  final bool isSuperuser;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const Profile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.preferredCurrency = 'EUR',
    this.isSuperuser = false,
    required this.createdAt,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props =>
      [id, email, displayName, avatarUrl, preferredCurrency, isSuperuser];
}
