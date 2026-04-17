import 'package:equatable/equatable.dart';

class Transfer extends Equatable {
  final String id;
  final String householdId;
  final String userId;
  final String fromSourceId;
  final String toSourceId;
  final double amount;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime lastUpdate;

  // Joined
  final String? fromSourceName;
  final String? toSourceName;

  const Transfer({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.fromSourceId,
    required this.toSourceId,
    required this.amount,
    this.note,
    required this.date,
    required this.createdAt,
    required this.lastUpdate,
    this.fromSourceName,
    this.toSourceName,
  });

  @override
  List<Object?> get props => [id, fromSourceId, toSourceId, amount, date];
}
