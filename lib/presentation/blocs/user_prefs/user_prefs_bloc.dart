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

class UserPrefsSetShowFuelModule extends UserPrefsEvent {
  final bool showFuelModule;
  const UserPrefsSetShowFuelModule(this.showFuelModule);
  @override
  List<Object?> get props => [showFuelModule];
}

class UserPrefsSetDateFormat extends UserPrefsEvent {
  final String dateFormat;
  const UserPrefsSetDateFormat(this.dateFormat);
  @override
  List<Object?> get props => [dateFormat];
}

class UserPrefsSetAllowNotifications extends UserPrefsEvent {
  final bool allowNotifications;
  const UserPrefsSetAllowNotifications(this.allowNotifications);
  @override
  List<Object?> get props => [allowNotifications];
}

class UserPrefsSetFaceIdUnlock extends UserPrefsEvent {
  final bool faceIdUnlock;
  const UserPrefsSetFaceIdUnlock(this.faceIdUnlock);
  @override
  List<Object?> get props => [faceIdUnlock];
}

// ── State ─────────────────────────────────────────────────────────────────────

class UserPrefsState extends Equatable {
  /// First day of week: DateTime.monday (1) … DateTime.sunday (7).
  final int startDay;

  /// Whether to show times in 24-hour format.
  final bool use24h;
  final ThemeType themeType;
  final String languageCode;

  /// Whether the Cars module is visible (tab + nav). Default: false.
  final bool showFuelModule;
  final String dateFormat;
  final bool allowNotifications;
  final bool faceIdUnlock;

  const UserPrefsState({
    this.startDay = DateTime.monday,
    this.use24h = true,
    this.themeType = ThemeType.dark,
    this.languageCode = 'en',
    this.showFuelModule = false,
    this.dateFormat = 'mdy',
    this.allowNotifications = false,
    this.faceIdUnlock = false,
  });

  UserPrefsState copyWith({
    int? startDay,
    bool? use24h,
    ThemeType? themeType,
    String? languageCode,
    bool? showFuelModule,
    String? dateFormat,
    bool? allowNotifications,
    bool? faceIdUnlock,
  }) =>
      UserPrefsState(
        startDay: startDay ?? this.startDay,
        use24h: use24h ?? this.use24h,
        themeType: themeType ?? this.themeType,
        languageCode: languageCode ?? this.languageCode,
        showFuelModule: showFuelModule ?? this.showFuelModule,
        dateFormat: dateFormat ?? this.dateFormat,
        allowNotifications: allowNotifications ?? this.allowNotifications,
        faceIdUnlock: faceIdUnlock ?? this.faceIdUnlock,
      );

  @override
  List<Object?> get props => [
        startDay,
        use24h,
        themeType,
        languageCode,
        showFuelModule,
        dateFormat,
        allowNotifications,
        faceIdUnlock,
      ];
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
    on<UserPrefsSetShowFuelModule>(_onSetShowFuelModule);
    on<UserPrefsSetDateFormat>(_onSetDateFormat);
    on<UserPrefsSetAllowNotifications>(_onSetAllowNotifications);
    on<UserPrefsSetFaceIdUnlock>(_onSetFaceIdUnlock);
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
      showFuelModule: _service.showFuelModule,
      dateFormat: _service.dateFormat,
      allowNotifications: _service.allowNotifications,
      faceIdUnlock: _service.faceIdUnlock,
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

  Future<void> _onSetShowFuelModule(
      UserPrefsSetShowFuelModule e, Emitter<UserPrefsState> emit) async {
    await _service.setShowFuelModule(e.showFuelModule);
    emit(state.copyWith(showFuelModule: e.showFuelModule));
  }

  Future<void> _onSetDateFormat(
      UserPrefsSetDateFormat e, Emitter<UserPrefsState> emit) async {
    await _service.setDateFormat(e.dateFormat);
    emit(state.copyWith(dateFormat: e.dateFormat));
  }

  Future<void> _onSetAllowNotifications(
      UserPrefsSetAllowNotifications e, Emitter<UserPrefsState> emit) async {
    await _service.setAllowNotifications(e.allowNotifications);
    emit(state.copyWith(allowNotifications: e.allowNotifications));
  }

  Future<void> _onSetFaceIdUnlock(
      UserPrefsSetFaceIdUnlock e, Emitter<UserPrefsState> emit) async {
    await _service.setFaceIdUnlock(e.faceIdUnlock);
    emit(state.copyWith(faceIdUnlock: e.faceIdUnlock));
  }
}
