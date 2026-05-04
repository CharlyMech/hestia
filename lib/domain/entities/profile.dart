import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String preferredCurrency;
  final String? calendarColor;
  final bool isSuperuser;
  final DateTime createdAt;
  final DateTime lastUpdate;

  const Profile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.preferredCurrency = 'EUR',
    this.calendarColor,
    this.isSuperuser = false,
    required this.createdAt,
    required this.lastUpdate,
  });

  Profile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? preferredCurrency,
    String? calendarColor,
    bool? isSuperuser,
    DateTime? createdAt,
    DateTime? lastUpdate,
  }) =>
      Profile(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        preferredCurrency: preferredCurrency ?? this.preferredCurrency,
        calendarColor: calendarColor ?? this.calendarColor,
        isSuperuser: isSuperuser ?? this.isSuperuser,
        createdAt: createdAt ?? this.createdAt,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        preferredCurrency,
        calendarColor,
        isSuperuser,
      ];
}
