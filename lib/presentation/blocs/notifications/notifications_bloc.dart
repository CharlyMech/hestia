import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/data/services/notification_realtime_service.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/domain/repositories/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => const [];
}

class NotificationsLoad extends NotificationsEvent {
  final String userId;
  const NotificationsLoad(this.userId);
  @override
  List<Object?> get props => [userId];
}

class NotificationsMarkRead extends NotificationsEvent {
  final String notificationId;
  const NotificationsMarkRead(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

class NotificationsMarkAllRead extends NotificationsEvent {
  final String userId;
  const NotificationsMarkAllRead(this.userId);
  @override
  List<Object?> get props => [userId];
}

class NotificationsToggleRead extends NotificationsEvent {
  final String notificationId;
  final bool currentlyRead;
  const NotificationsToggleRead(this.notificationId, this.currentlyRead);
  @override
  List<Object?> get props => [notificationId, currentlyRead];
}

class NotificationsDelete extends NotificationsEvent {
  final String notificationId;
  const NotificationsDelete(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => const [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> items;
  final int unreadCount;
  // Non-null only on the emit triggered by a realtime insert — used by the
  // BlocListener in app.dart to show the in-app banner exactly once.
  final AppNotification? incoming;

  const NotificationsLoaded({
    required this.items,
    required this.unreadCount,
    this.incoming,
  });

  @override
  List<Object?> get props => [items, unreadCount, incoming];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Internal event — fired by the realtime subscription.
class _NotificationReceived extends NotificationsEvent {
  final AppNotification notification;
  const _NotificationReceived(this.notification);
  @override
  List<Object?> get props => [notification];
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository _repo;
  final NotificationRealtimeService _realtime;
  RealtimeChannel? _channel;
  String? _userId;

  NotificationsBloc(this._repo, this._realtime)
      : super(const NotificationsInitial()) {
    on<NotificationsLoad>(_onLoad);
    on<NotificationsMarkRead>(_onMarkRead);
    on<NotificationsMarkAllRead>(_onMarkAllRead);
    on<NotificationsToggleRead>(_onToggleRead);
    on<NotificationsDelete>(_onDelete);
    on<_NotificationReceived>(_onReceived);
  }

  /// Start realtime subscription. Call once after authentication.
  void startListening(String userId) {
    _userId = userId;
    _channel = _realtime.subscribe(
      userId: userId,
      onNew: (n) => add(_NotificationReceived(n)),
    );
  }

  /// Stop subscription. Call on sign-out.
  Future<void> stopListening() async {
    await _realtime.unsubscribe(_channel);
    _channel = null;
  }

  @override
  Future<void> close() async {
    await stopListening();
    return super.close();
  }

  void _onReceived(
      _NotificationReceived e, Emitter<NotificationsState> emit) {
    final current = state;
    if (current is NotificationsLoaded) {
      final updated = [e.notification, ...current.items];
      emit(NotificationsLoaded(
        items: updated,
        unreadCount: current.unreadCount + 1,
        incoming: e.notification,
      ));
    } else {
      // Not loaded yet — just trigger a full reload.
      if (_userId != null) add(NotificationsLoad(_userId!));
    }
  }

  Future<void> _onLoad(
      NotificationsLoad e, Emitter<NotificationsState> emit) async {
    _userId = e.userId;
    emit(const NotificationsLoading());
    final (items, failure) = await _repo.getNotifications(userId: e.userId);
    if (failure != null) {
      emit(NotificationsError(failure.message));
      return;
    }
    final unread = items.where((n) => !n.isRead).length;
    emit(NotificationsLoaded(items: items, unreadCount: unread));
  }

  Future<void> _onMarkRead(
      NotificationsMarkRead e, Emitter<NotificationsState> emit) async {
    await _repo.markAsRead(e.notificationId);
    if (_userId != null) add(NotificationsLoad(_userId!));
  }

  Future<void> _onMarkAllRead(
      NotificationsMarkAllRead e, Emitter<NotificationsState> emit) async {
    await _repo.markAllAsRead(e.userId);
    add(NotificationsLoad(e.userId));
  }

  Future<void> _onToggleRead(
      NotificationsToggleRead e, Emitter<NotificationsState> emit) async {
    if (e.currentlyRead) {
      await _repo.markAsUnread(e.notificationId);
    } else {
      await _repo.markAsRead(e.notificationId);
    }
    if (_userId != null) add(NotificationsLoad(_userId!));
  }

  Future<void> _onDelete(
      NotificationsDelete e, Emitter<NotificationsState> emit) async {
    await _repo.delete(e.notificationId);
    if (_userId != null) add(NotificationsLoad(_userId!));
  }
}
