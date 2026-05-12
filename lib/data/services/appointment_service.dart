import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/constants/supabase_tables.dart';
import 'package:hestia/core/error/exceptions.dart';
import 'package:hestia/domain/entities/appointment.dart';

import 'supabase_service.dart';

class AppointmentService extends SupabaseService {
  AppointmentService({super.client});

  Future<List<Map<String, dynamic>>> getRange({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final response = await from(SupabaseTables.appointments)
          .select()
          .eq('user_id', userId)
          .gte('starts_at', fromDate.toIso8601String())
          .lte('starts_at', toDate.toIso8601String())
          .order('starts_at');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to fetch appointments: $e');
    }
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final response = await from(SupabaseTables.appointments)
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      throw ServerException('Failed to fetch appointment: $e');
    }
  }

  Future<Map<String, dynamic>> create(Appointment a) async {
    try {
      final inserted = await from(SupabaseTables.appointments)
          .insert(_toRow(a, isCreate: true))
          .select()
          .single();
      return inserted;
    } catch (e) {
      throw ServerException('Failed to create appointment: $e');
    }
  }

  Future<Map<String, dynamic>> update(Appointment a) async {
    try {
      final updated = await from(SupabaseTables.appointments)
          .update(_toRow(a, isCreate: false))
          .eq('id', a.id)
          .select()
          .single();
      return updated;
    } catch (e) {
      throw ServerException('Failed to update appointment: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await from(SupabaseTables.appointments).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete appointment: $e');
    }
  }

  Future<void> upsertGoogleEventId(String id, String? googleEventId) async {
    try {
      await from(SupabaseTables.appointments)
          .update({'google_event_id': googleEventId}).eq('id', id);
    } catch (e) {
      throw ServerException('Failed to update google_event_id: $e');
    }
  }

  Map<String, dynamic> _toRow(Appointment a, {required bool isCreate}) {
    final row = <String, dynamic>{
      'user_id': a.userId,
      'household_id': a.householdId,
      'title': a.title,
      'notes': a.notes,
      'location': a.location,
      'starts_at': a.startsAt.toIso8601String(),
      'duration_minutes': a.duration.inMinutes,
      'category': a.category.name,
      'reminder_offsets_minutes':
          a.reminderOffsets.map((d) => d.inMinutes).toList(),
      'google_event_id': a.googleEventId,
    };
    if (isCreate) {
      row['id'] = a.id.isEmpty ? null : a.id;
      row['created_at'] = a.createdAt.toIso8601String();
    } else {
      row['last_update'] = DateTime.now().toIso8601String();
    }
    row.removeWhere((_, v) => v == null);
    return row;
  }
}

extension AppointmentRowMapper on Map<String, dynamic> {
  Appointment toAppointment() {
    return Appointment(
      id: this['id'] as String,
      userId: this['user_id'] as String,
      householdId: this['household_id'] as String?,
      title: this['title'] as String,
      notes: this['notes'] as String?,
      location: this['location'] as String?,
      startsAt: DateTime.parse(this['starts_at'] as String),
      duration:
          Duration(minutes: (this['duration_minutes'] as num?)?.toInt() ?? 60),
      category: _categoryFromName(this['category'] as String?),
      reminderOffsets: ((this['reminder_offsets_minutes'] as List?) ?? const [])
          .map((m) => Duration(minutes: (m as num).toInt()))
          .toList(),
      googleEventId: this['google_event_id'] as String?,
      createdAt: DateTime.parse(this['created_at'] as String),
      lastUpdate: this['last_update'] == null
          ? null
          : DateTime.parse(this['last_update'] as String),
    );
  }

  AppointmentCategory _categoryFromName(String? name) {
    if (name == null) return AppointmentCategory.other;
    return AppointmentCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => AppointmentCategory.other,
    );
  }

  // Avoid warning that ViewMode import is unused if a future helper needs it.
  // ignore: unused_element
  ViewMode get _vm => ViewMode.personal;
}
