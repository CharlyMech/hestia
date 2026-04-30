import 'package:hestia/domain/entities/appointment.dart';

/// True when an appointment occupies the full day (midnight + ≥24 h duration).
bool isAllDayAppointment(Appointment a) =>
    a.startsAt.hour == 0 &&
    a.startsAt.minute == 0 &&
    a.duration.inMinutes >= 1440;

class PositionedEvent {
  final Appointment appointment;
  final int columnIndex;
  final int totalColumns;
  final int startMinute;
  final int durationMinutes;

  const PositionedEvent({
    required this.appointment,
    required this.columnIndex,
    required this.totalColumns,
    required this.startMinute,
    required this.durationMinutes,
  });

  double topOffset(double hourHeight) => startMinute / 60.0 * hourHeight;

  double blockHeight(double hourHeight, {double minHeight = 28.0}) =>
      (durationMinutes / 60.0 * hourHeight).clamp(minHeight, double.infinity);
}

/// Resolves timed appointments into positioned columns for the day grid.
/// All-day appointments (detected via [isAllDayAppointment]) are excluded.
List<PositionedEvent> resolveLayout(
    List<Appointment> appointments, Set<String> allDayIds) {
  final timed = appointments
      .where((a) => !isAllDayAppointment(a) && !allDayIds.contains(a.id))
      .toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  if (timed.isEmpty) return [];

  final result = <PositionedEvent>[];
  final clusters = <List<Appointment>>[];

  for (final appt in timed) {
    if (clusters.isEmpty) {
      clusters.add([appt]);
      continue;
    }
    final last = clusters.last;
    final clusterEnd = last
        .map((a) => a.endsAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    if (appt.startsAt.isBefore(clusterEnd)) {
      last.add(appt);
    } else {
      clusters.add([appt]);
    }
  }

  for (final cluster in clusters) {
    // Greedy column assignment: track when each column is free (endsAt minute)
    final columnEnds = <int>[];

    for (final appt in cluster) {
      final startMin =
          appt.startsAt.hour * 60 + appt.startsAt.minute;
      final endMin =
          appt.endsAt.hour * 60 + appt.endsAt.minute;
      final durMin = (endMin - startMin).clamp(1, 24 * 60);

      int col = columnEnds.indexWhere((end) => end <= startMin);
      if (col == -1) {
        col = columnEnds.length;
        columnEnds.add(endMin);
      } else {
        columnEnds[col] = endMin;
      }

      result.add(PositionedEvent(
        appointment: appt,
        columnIndex: col,
        totalColumns: 0, // patched below
        startMinute: startMin,
        durationMinutes: durMin,
      ));
    }

    // Patch totalColumns for all events in this cluster
    final total = columnEnds.length;
    for (var i = result.length - cluster.length; i < result.length; i++) {
      final e = result[i];
      result[i] = PositionedEvent(
        appointment: e.appointment,
        columnIndex: e.columnIndex,
        totalColumns: total,
        startMinute: e.startMinute,
        durationMinutes: e.durationMinutes,
      );
    }
  }

  return result;
}
