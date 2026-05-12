import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Device location + permission helpers (iOS / Android).
///
/// Catches platform errors (including [MissingPluginException]) when the
/// native geolocator implementation is not registered (e.g. hot reload only,
/// web, or a failed pod install). In that case APIs degrade to "unavailable".
class LocationService {
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  /// Returns true when [LocationPermission.whileInUse] or `.always`.
  Future<bool> ensureWhenInUsePermission() async {
    try {
      var p = await checkPermission();
      if (p == LocationPermission.denied) {
        p = await requestPermission();
      }
      if (p == LocationPermission.deniedForever) return false;
      return p == LocationPermission.always ||
          p == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      if (!await ensureWhenInUsePermission()) return null;
      if (!await isLocationServiceEnabled()) return null;
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  Future<void> openSystemAppSettings() async {
    try {
      await ph.openAppSettings();
    } catch (_) {
      // Missing plugin or settings channel unavailable.
    }
  }
}
