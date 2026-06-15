import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/status_bar_blur_overlay.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show NavArrowLeft;
import 'package:iconoir_flutter/regular/position.dart' as icon_position;
import 'package:latlong2/latlong.dart';

/// Agnostic full-screen location picker.
///
/// Fullscreen map with a fixed centre pin. The marked coordinate is always the
/// map's current centre. Tapping the map re-centres on the tapped point and
/// updates the marked coordinate. The top-left back button dismisses WITHOUT a
/// result (cancel); the bottom floating "Set location" button pops `(lat, lng)`.
///
/// Reuse anywhere a coordinate must be picked (homes, transactions, …).
class SelectLocationScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const SelectLocationScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final _mapController = MapController();
  late LatLng _center;
  bool _ready = false;

  static const _kMadrid = LatLng(40.415371, -3.707364);

  @override
  void initState() {
    super.initState();
    _center = LatLng(
      widget.initialLatitude ?? _kMadrid.latitude,
      widget.initialLongitude ?? _kMadrid.longitude,
    );
    _resolveInitial();
  }

  Future<void> _resolveInitial() async {
    if (widget.initialLatitude == null || widget.initialLongitude == null) {
      final pos =
          await AppDependencies.instance.locationService.getCurrentPosition();
      if (pos != null && mounted) {
        _center = LatLng(pos.latitude, pos.longitude);
        _mapController.move(_center, 15);
      }
    }
    if (mounted) setState(() => _ready = true);
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    setState(() => _center = camera.center);
  }

  void _onTap(TapPosition _, LatLng point) {
    _mapController.move(point, _mapController.camera.zoom);
    setState(() => _center = point);
  }

  Future<void> _goToDeviceLocation() async {
    final svc = AppDependencies.instance.locationService;
    final hasPerm = await svc.hasPermission();
    if (!hasPerm) {
      final granted = await svc.ensureWhenInUsePermission();
      if (!granted) {
        await svc.openSystemAppSettings();
        return;
      }
    }
    final pos = await svc.getCurrentPosition();
    if (pos != null && mounted) {
      final point = LatLng(pos.latitude, pos.longitude);
      _mapController.move(point, _mapController.camera.zoom);
      setState(() => _center = point);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.foregroundColor);
    final accent = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);
    final l10n = AppLocalizations.of(context);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Stack(
        children: [
          // Full-bleed map.
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 15,
                onPositionChanged: _onPositionChanged,
                onTap: _onTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.charlymech.hestia',
                  retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
                ),
              ],
            ),
          ),

          // Fixed centre pin — tip points at the exact centre.
          if (_ready)
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: SvgPicture.asset(
                    'assets/map_pins/pin_home_add.svg',
                    width: 48,
                    height: 48,
                  ),
                ),
              ),
            ),

          // Status bar gradient.
          StatusBarBlurOverlay(tint: bg),

          // Top-left back (cancel — no result).
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: AnimatedButton(
                  onTap: () => Navigator.of(context).pop(),
                  size: 40,
                  backgroundColor: surface.withValues(alpha: 0.9),
                  borderColor: border,
                  borderWidth: 0.8,
                  borderRadius: AppRadii.full,
                  child: Center(
                    child: NavArrowLeft(width: 20, height: 20, color: fg),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: Stack(alignment: Alignment.center, children: [
                        Container(
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: border, width: 0.8),
                          ),
                          child: Text(
                            '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}',
                            style: AppFonts.body(fontSize: 14, color: fg),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: AnimatedButton(
                            onTap: _goToDeviceLocation,
                            size: 42,
                            backgroundColor: surface.withValues(alpha: 0.9),
                            borderColor: border,
                            borderWidth: 0.8,
                            borderRadius: AppRadii.full,
                            child: Center(
                              child: icon_position.Position(
                                  width: 24, height: 24, color: fg),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedButton(
                        onTap: () => Navigator.of(context)
                            .pop((_center.latitude, _center.longitude)),
                        backgroundColor: accent,
                        borderRadius: AppRadii.lg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            l10n.selectLocation_setButton,
                            style: AppFonts.body(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
