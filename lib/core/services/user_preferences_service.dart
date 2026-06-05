import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

const _kStartDay = 'pref_start_day';
const _kUse24h = 'pref_use24h';
const _kThemeType = 'pref_theme_type';
const _kLanguageCode = 'pref_language_code';
const _kShowFuelModule = 'pref_show_fuel_module';
const _kDateFormat = 'pref_date_format';
const _kAllowNotifications = 'pref_allow_notifications';
const _kFaceIdUnlock = 'pref_face_id_unlock';

class UserPreferencesService {
  final SharedPreferences _prefs;

  UserPreferencesService(this._prefs);

  static const _kOnboardingSeen = 'pref_onboarding_seen';
  static const _supportedLocales = ['en', 'es'];

  static Future<UserPreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final svc = UserPreferencesService(prefs);
    await svc._applyFirstRunDefaults();
    return svc;
  }

  Future<void> _applyFirstRunDefaults() async {
    if (!_prefs.containsKey(_kThemeType)) {
      await _prefs.setString(_kThemeType, 'system');
    }
    if (!_prefs.containsKey(_kLanguageCode)) {
      final locale = Platform.localeName.split('_').first.toLowerCase();
      final code = _supportedLocales.contains(locale) ? locale : 'en';
      await _prefs.setString(_kLanguageCode, code);
    }
  }

  bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;

  Future<void> setOnboardingSeen(bool value) async {
    await _prefs.setBool(_kOnboardingSeen, value);
  }

  /// First day of week: DateTime.monday (1) … DateTime.sunday (7). Default: Monday.
  int get startDay => _prefs.getInt(_kStartDay) ?? DateTime.monday;

  Future<void> setStartDay(int day) async {
    assert(day >= DateTime.monday && day <= DateTime.sunday);
    await _prefs.setInt(_kStartDay, day);
  }

  /// Whether to display times in 24-hour format. Default: true.
  bool get use24h => _prefs.getBool(_kUse24h) ?? true;

  Future<void> setUse24h(bool value) async {
    await _prefs.setBool(_kUse24h, value);
  }

  String get themeType => _prefs.getString(_kThemeType) ?? 'dark';

  Future<void> setThemeType(String value) async {
    await _prefs.setString(_kThemeType, value);
  }

  String get languageCode => _prefs.getString(_kLanguageCode) ?? 'en';

  Future<void> setLanguageCode(String value) async {
    await _prefs.setString(_kLanguageCode, value);
  }

  /// Whether the Fuel module is visible (tab + nav). Default: false.
  /// Pets module is always visible (no flag).
  bool get showFuelModule => _prefs.getBool(_kShowFuelModule) ?? false;

  Future<void> setShowFuelModule(bool value) async {
    await _prefs.setBool(_kShowFuelModule, value);
  }

  /// Short date pattern: `mdy`, `dmy`, or `ymd`.
  String get dateFormat => _prefs.getString(_kDateFormat) ?? 'mdy';

  Future<void> setDateFormat(String value) async {
    await _prefs.setString(_kDateFormat, value);
  }

  bool get allowNotifications => _prefs.getBool(_kAllowNotifications) ?? false;

  Future<void> setAllowNotifications(bool value) async {
    await _prefs.setBool(_kAllowNotifications, value);
  }

  bool get faceIdUnlock => _prefs.getBool(_kFaceIdUnlock) ?? false;

  Future<void> setFaceIdUnlock(bool value) async {
    await _prefs.setBool(_kFaceIdUnlock, value);
  }
}
