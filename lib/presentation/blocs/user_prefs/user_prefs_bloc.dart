import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/services/user_preferences_service.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class UserPrefsEvent extends Equatable {
  const UserPrefsEvent();
  @override
  List<Object?> get props => const [];
}

class UserPrefsLoad extends UserPrefsEvent {
  const UserPrefsLoad();
}

class UserPrefsSetStartDay extends UserPrefsEvent {
  final int day;
  const UserPrefsSetStartDay(this.day);
  @override
  List<Object?> get props => [day];
}

class UserPrefsSetUse24h extends UserPrefsEvent {
  final bool use24h;
  const UserPrefsSetUse24h(this.use24h);
  @override
  List<Object?> get props => [use24h];
}

class UserPrefsSetThemeType extends UserPrefsEvent {
  final ThemeType themeType;
  const UserPrefsSetThemeType(this.themeType);
  @override
  List<Object?> get props => [themeType];
}

class UserPrefsSetLanguageCode extends UserPrefsEvent {
  final String languageCode;
  const UserPrefsSetLanguageCode(this.languageCode);
  @override
  List<Object?> get props => [languageCode];
}

// ── State ─────────────────────────────────────────────────────────────────────

class UserPrefsState extends Equatable {
  /// First day of week: DateTime.monday (1) … DateTime.sunday (7).
  final int startDay;

  /// Whether to show times in 24-hour format.
  final bool use24h;
  final ThemeType themeType;
  final String languageCode;

  const UserPrefsState({
    this.startDay = DateTime.monday,
    this.use24h = true,
    this.themeType = ThemeType.dark,
    this.languageCode = 'en',
  });

  UserPrefsState copyWith({
    int? startDay,
    bool? use24h,
    ThemeType? themeType,
    String? languageCode,
  }) =>
      UserPrefsState(
        startDay: startDay ?? this.startDay,
        use24h: use24h ?? this.use24h,
        themeType: themeType ?? this.themeType,
        languageCode: languageCode ?? this.languageCode,
      );

  @override
  List<Object?> get props => [startDay, use24h, themeType, languageCode];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class UserPrefsBloc extends Bloc<UserPrefsEvent, UserPrefsState> {
  final UserPreferencesService _service;

  UserPrefsBloc(this._service) : super(const UserPrefsState()) {
    on<UserPrefsLoad>(_onLoad);
    on<UserPrefsSetStartDay>(_onSetStartDay);
    on<UserPrefsSetUse24h>(_onSetUse24h);
    on<UserPrefsSetThemeType>(_onSetThemeType);
    on<UserPrefsSetLanguageCode>(_onSetLanguageCode);
  }

  void _onLoad(UserPrefsLoad e, Emitter<UserPrefsState> emit) {
    emit(UserPrefsState(
      startDay: _service.startDay,
      use24h: _service.use24h,
      themeType: ThemeType.values.firstWhere(
        (t) => t.name == _service.themeType,
        orElse: () => ThemeType.dark,
      ),
      languageCode: _service.languageCode,
    ));
  }

  Future<void> _onSetStartDay(
      UserPrefsSetStartDay e, Emitter<UserPrefsState> emit) async {
    await _service.setStartDay(e.day);
    emit(state.copyWith(startDay: e.day));
  }

  Future<void> _onSetUse24h(
      UserPrefsSetUse24h e, Emitter<UserPrefsState> emit) async {
    await _service.setUse24h(e.use24h);
    emit(state.copyWith(use24h: e.use24h));
  }

  Future<void> _onSetThemeType(
      UserPrefsSetThemeType e, Emitter<UserPrefsState> emit) async {
    await _service.setThemeType(e.themeType.name);
    emit(state.copyWith(themeType: e.themeType));
  }

  Future<void> _onSetLanguageCode(
      UserPrefsSetLanguageCode e, Emitter<UserPrefsState> emit) async {
    await _service.setLanguageCode(e.languageCode);
    emit(state.copyWith(languageCode: e.languageCode));
  }
}
