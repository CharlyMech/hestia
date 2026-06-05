import 'package:package_info_plus/package_info_plus.dart';

/// Exposes the running app's version/build. Loaded once in bootstrap so the
/// in-app version label (settings) tracks the CI-bumped values.
abstract final class AppInfo {
  static String _version = '';
  static String _buildNumber = '';

  /// Call once at startup (bootstrap) before the UI reads [display].
  static Future<void> load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _version = info.version;
      _buildNumber = info.buildNumber;
    } catch (_) {
      // Leave empty — the label simply hides.
    }
  }

  static String get version => _version;
  static String get buildNumber => _buildNumber;

  /// e.g. "1.0.0 (42)". Empty when not loaded.
  static String get display =>
      _version.isEmpty ? '' : '$_version ($_buildNumber)';
}
