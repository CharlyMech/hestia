import 'package:hestia/domain/entities/app_version.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class AppUpdateLauncher {
  static const fallbackUrl = 'https://testflight.apple.com/';

  static Future<void> open(AppVersion version) async {
    final raw = version.testflightUrl?.trim();
    final uri = Uri.parse(raw == null || raw.isEmpty ? fallbackUrl : raw);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
