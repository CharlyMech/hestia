import 'package:hestia/core/audit/audit_logger.dart';

/// No-op until audit_* tables are provisioned in Supabase.
class SupabaseAuditLogger implements AuditLogger {
  @override
  Future<void> log(AuditEntry entry) async {}
}
