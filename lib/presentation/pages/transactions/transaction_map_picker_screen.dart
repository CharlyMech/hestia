import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:latlong2/latlong.dart';

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

class _TransactionMapPickerScreenState extends State<TransactionMapPickerScreen>
    with TickerProviderStateMixin {
  late AnimatedMapController _mapCtrl;
  late double _lat;
  late double _lng;
  bool _placed = false;

  static const _kMadrid = LatLng(40.415371, -3.707364);

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLatitude ?? _kMadrid.latitude;
    _lng = widget.initialLongitude ?? _kMadrid.longitude;
    _placed = widget.initialLatitude != null;
    _mapCtrl = AnimatedMapController(vsync: this);
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  void _onTap(_, LatLng point) {
    setState(() {
      _lat = point.latitude;
      _lng = point.longitude;
      _placed = true;
    });
    _mapCtrl.animateTo(dest: point);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg =
        Color(int.parse(theme.backgroundColor.replaceFirst('#', '0xff')));
    final fg =
        Color(int.parse(theme.foregroundColor.replaceFirst('#', '0xff')));
    final accent =
        Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff')));
    final muted = Color(int.parse(theme.mutedColor.replaceFirst('#', '0xff')));
    final pinCoord = LatLng(_lat, _lng);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: bg.withValues(alpha: 0.85),
        middle: Text('Pick location',
            style: AppFonts.body(
                fontSize: 17, fontWeight: FontWeight.w600, color: fg)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop((_lat, _lng)),
          child: Text('Done',
              style: AppFonts.body(
                  fontSize: 15, fontWeight: FontWeight.w600, color: accent)),
        ),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl.mapController,
            options: MapOptions(
              initialCenter: pinCoord,
              initialZoom: 15,
              onTap: _onTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.charlymech.hestia',
                retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
              ),
              if (_placed)
                MarkerLayer(markers: [
                  Marker(
                    point: pinCoord,
                    width: 36,
                    height: 36,
                    child: Icon(
                      CupertinoIcons.location_solid,
                      color: accent,
                      size: 36,
                    ),
                  ),
                ]),
            ],
          ),
          // Coordinates label
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: bg.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1F000000), blurRadius: 8),
                  ],
                ),
                child: Text(
                  _placed
                      ? '${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)}'
                      : 'Tap to place pin',
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
