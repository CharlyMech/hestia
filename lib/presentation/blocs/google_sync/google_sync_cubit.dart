import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/data/services/google_calendar_service.dart';
import 'package:hestia/domain/repositories/appointment_repository.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class GoogleSyncState extends Equatable {
  const GoogleSyncState();
  @override
  List<Object?> get props => const [];
}

class GoogleSyncIdle extends GoogleSyncState {
  const GoogleSyncIdle();
}

class GoogleSyncLoading extends GoogleSyncState {
  const GoogleSyncLoading();
}

class GoogleSyncLinked extends GoogleSyncState {
  final String email;
  final DateTime? lastSyncedAt;
  const GoogleSyncLinked({required this.email, this.lastSyncedAt});
  @override
  List<Object?> get props => [email, lastSyncedAt];
}

class GoogleSyncError extends GoogleSyncState {
  final String message;
  const GoogleSyncError(this.message);
  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class GoogleSyncCubit extends Cubit<GoogleSyncState> {
  final GoogleCalendarService _gcal;
  final AppointmentRepository _appointmentRepo;

  GoogleSyncCubit({
    required GoogleCalendarService gcal,
    required AppointmentRepository appointmentRepo,
  })  : _gcal = gcal,
        _appointmentRepo = appointmentRepo,
        super(const GoogleSyncIdle());

  /// Check current link status. Emits [GoogleSyncLinked] if an account is
  /// linked server-side (detected via isGoogleLinked on the repo) or
  /// [GoogleSyncIdle] if not linked.
  Future<void> checkStatus(String userId) async {
    emit(const GoogleSyncLoading());
    try {
      final linked = await _appointmentRepo.isGoogleLinked();
      if (linked) {
        final email = await _gcal.currentEmail() ?? '';
        emit(GoogleSyncLinked(email: email));
      } else {
        emit(const GoogleSyncIdle());
      }
    } catch (e) {
      emit(GoogleSyncError(e.toString()));
    }
  }

  /// Initiates the Google OAuth flow, exchanges the serverAuthCode server-side
  /// via the google-oauth-exchange edge function, then syncs.
  Future<void> link(String userId) async {
    emit(const GoogleSyncLoading());
    try {
      final failure = await _appointmentRepo.linkGoogle();
      if (failure != null) {
        emit(GoogleSyncError(failure.message));
        return;
      }
      final email = await _gcal.currentEmail() ?? '';
      emit(GoogleSyncLinked(email: email));
      // Immediately pull remote events.
      await _appointmentRepo.syncWithGoogle(userId: userId);
    } catch (e) {
      emit(GoogleSyncError(e.toString()));
    }
  }

  /// Revokes the Google link: signs out device + calls edge fn to clear
  /// server-side credentials.
  Future<void> unlink(String userId) async {
    emit(const GoogleSyncLoading());
    try {
      final failure = await _appointmentRepo.unlinkGoogle();
      if (failure != null) {
        emit(GoogleSyncError(failure.message));
        return;
      }
      emit(const GoogleSyncIdle());
    } catch (e) {
      emit(GoogleSyncError(e.toString()));
    }
  }

  /// Triggers an on-demand pull of Google Calendar events for [userId].
  Future<void> syncNow(String userId) async {
    final prev = state;
    emit(const GoogleSyncLoading());
    try {
      final failure =
          await _appointmentRepo.syncWithGoogle(userId: userId);
      if (failure != null) {
        emit(prev); // restore previous linked state
        emit(GoogleSyncError(failure.message));
        return;
      }
      if (prev is GoogleSyncLinked) {
        emit(GoogleSyncLinked(
          email: prev.email,
          lastSyncedAt: DateTime.now(),
        ));
      } else {
        emit(const GoogleSyncIdle());
      }
    } catch (e) {
      emit(prev);
      emit(GoogleSyncError(e.toString()));
    }
  }
}
