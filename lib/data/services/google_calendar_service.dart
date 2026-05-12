import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:hestia/domain/entities/appointment.dart';

/// Bidirectional Google Calendar sync. Used by the prod appointment
/// repository. Mock flavor never instantiates this.
///
/// Auth flow uses google_sign_in (silent on subsequent launches) with the
/// `https://www.googleapis.com/auth/calendar.events` scope. The calendar
/// API client is built via the
/// `extension_google_sign_in_as_googleapis_auth` extension.
class GoogleCalendarService {
  GoogleCalendarService();

  static const _scopes = [gcal.CalendarApi.calendarEventsScope];
  final GoogleSignIn _signIn = GoogleSignIn(scopes: _scopes);

  /// Returns true if a Google account is currently linked.
  Future<bool> isLinked() async => _signIn.currentUser != null;

  /// Starts the OAuth flow. Idempotent — does nothing if already linked.
  Future<bool> link() async {
    final account = await _signIn.signIn();
    return account != null;
  }

  /// Sign out (does NOT revoke the OAuth grant — call [revoke] for that).
  Future<void> unlink() => _signIn.signOut();

  Future<void> revoke() => _signIn.disconnect();

  Future<gcal.CalendarApi?> _api() async {
    final account = _signIn.currentUser ?? await _signIn.signInSilently();
    if (account == null) return null;
    final client = await _signIn.authenticatedClient();
    if (client == null) return null;
    return gcal.CalendarApi(client);
  }

  /// Pushes an appointment as a calendar event. Returns the created
  /// google event id.
  Future<String?> createEvent(Appointment a) async {
    final api = await _api();
    if (api == null) return null;
    final event = _toEvent(a);
    final created = await api.events.insert(event, 'primary');
    return created.id;
  }

  Future<void> updateEvent(Appointment a) async {
    final api = await _api();
    if (api == null || a.googleEventId == null) return;
    await api.events.update(_toEvent(a), 'primary', a.googleEventId!);
  }

  Future<void> deleteEvent(String googleEventId) async {
    final api = await _api();
    if (api == null) return;
    await api.events.delete('primary', googleEventId);
  }

  /// Pulls events overlapping [from, to] from primary calendar.
  Future<List<gcal.Event>> listRange(DateTime from, DateTime to) async {
    final api = await _api();
    if (api == null) return const [];
    final events = await api.events.list(
      'primary',
      timeMin: from.toUtc(),
      timeMax: to.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );
    return events.items ?? const [];
  }

  gcal.Event _toEvent(Appointment a) {
    return gcal.Event()
      ..summary = a.title
      ..description = a.notes
      ..location = a.location
      ..start = gcal.EventDateTime(dateTime: a.startsAt.toUtc())
      ..end = gcal.EventDateTime(dateTime: a.endsAt.toUtc())
      ..reminders = gcal.EventReminders(
        useDefault: false,
        overrides: a.reminderOffsets
            .map((d) =>
                gcal.EventReminder(method: 'popup', minutes: d.inMinutes))
            .toList(),
      );
  }
}
