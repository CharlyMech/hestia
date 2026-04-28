import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String householdId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.householdId,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, isRead];
}
