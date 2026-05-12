import 'package:flutter/foundation.dart';
import 'package:hestia/core/audit/audit_logger.dart';
import 'package:hestia/data/mock/mock_store.dart';

class MockAuditLogger implements AuditLogger {
  @override
  Future<void> log(AuditEntry entry) async {
    MockStore.instance.auditLog.add(entry);
    if (kDebugMode) {
      debugPrint(
        '[AUDIT] ${entry.action.name.toUpperCase()} '
        '${entry.entityType}:${entry.targetId} '
        'by ${entry.actionerId}',
      );
    }
  }
}
