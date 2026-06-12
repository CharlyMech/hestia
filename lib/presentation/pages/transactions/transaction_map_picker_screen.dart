import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:latlong2/latlong.dart';

/// Fixed-center-pin location picker (bug #2/#12).
///
/// The pin stays pinned to the centre of the screen; the user pans the map
/// underneath it. The selected coordinate is always the map's current centre,
/// read on camera move-end. Returns `(lat, lng)` via `Navigator.pop`.
class TransactionMapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const TransactionMapPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<TransactionMapPickerScreen> createState() =>
      _TransactionMapPickerScreenState();
}

class _TransactionMapPickerScreenState
    extends State<TransactionMapPickerScreen> {
  final _mapController = MapController();
  late LatLng _center;

  static const _kMadrid = LatLng(40.415371, -3.707364);

  @override
  void initState() {
    super.initState();
    _center = LatLng(
      widget.initialLatitude ?? _kMadrid.latitude,
      widget.initialLongitude ?? _kMadrid.longitude,
    );
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    // Track the centre continuously; cheap setState only updates the readout.
    setState(() => _center = camera.center);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.foregroundColor);
    final accent = hexToColor(theme.primaryColor);
    final muted = hexToColor(theme.mutedColor);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Pick location',
      trailing: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () =>
              Navigator.of(context).pop((_center.latitude, _center.longitude)),
          child: Text(
            'Done',
            style: AppFonts.body(
                fontSize: 15, fontWeight: FontWeight.w600, color: accent),
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.charlymech.hestia',
                retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
              ),
            ],
          ),
          // Fixed centre pin — sits above the map, offset up so the tip points
          // at the exact centre.
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Icon(
                CupertinoIcons.location_solid,
                color: accent,
                size: 36,
              ),
            ),
          ),
          // Coordinate readout.
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Text(
                  '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}',
                  style: AppFonts.body(fontSize: 12, color: muted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
