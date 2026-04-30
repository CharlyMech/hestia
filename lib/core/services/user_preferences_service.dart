import 'package:shared_preferences/shared_preferences.dart';

const _kStartDay = 'pref_start_day';
const _kUse24h = 'pref_use24h';
const _kThemeType = 'pref_theme_type';
const _kLanguageCode = 'pref_language_code';

class UserPreferencesService {
  final SharedPreferences _prefs;

  UserPreferencesService(this._prefs);

  static Future<UserPreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferencesService(prefs);
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
}
