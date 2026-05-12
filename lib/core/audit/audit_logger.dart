import 'package:equatable/equatable.dart';

enum AuditAction { create, update, delete, deactivate }

class AuditEntry extends Equatable {
  final String actionerId;
  final AuditAction action;
  final String targetId;
  final String entityType;
  final int timestamp;
  final Map<String, dynamic>? snapshot;

  const AuditEntry({
    required this.actionerId,
    required this.action,
    required this.targetId,
    required this.entityType,
    required this.timestamp,
    this.snapshot,
  });

  @override
  List<Object?> get props =>
      [actionerId, action, targetId, entityType, timestamp];
}

abstract class AuditLogger {
  Future<void> log(AuditEntry entry);
}
