import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/notification.dart';
import 'package:hestia/domain/repositories/notification_repository.dart';

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
  const NotificationsLoaded({required this.items, required this.unreadCount});
  @override
  List<Object?> get props => [items, unreadCount];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository _repo;
  String? _userId;

  NotificationsBloc(this._repo) : super(const NotificationsInitial()) {
    on<NotificationsLoad>(_onLoad);
    on<NotificationsMarkRead>(_onMarkRead);
    on<NotificationsMarkAllRead>(_onMarkAllRead);
    on<NotificationsToggleRead>(_onToggleRead);
    on<NotificationsDelete>(_onDelete);
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
}
