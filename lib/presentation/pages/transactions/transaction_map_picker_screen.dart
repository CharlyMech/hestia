import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:latlong2/latlong.dart';

/// Full-screen map: tap to move pin, then Done to return [LatLng].
class TransactionMapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;

  const TransactionMapPickerScreen({super.key, this.initialPosition});

  @override
  State<TransactionMapPickerScreen> createState() =>
      _TransactionMapPickerScreenState();
}

class _TransactionMapPickerScreenState
    extends State<TransactionMapPickerScreen> {
  late LatLng _pin;

  @override
  void initState() {
    super.initState();
    _pin = widget.initialPosition ?? const LatLng(40.4168, -3.7038);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final fg = _c(theme.onBackgroundColor);
    final accent = _c(theme.primaryColor);
    final l10n = AppLocalizations.of(context);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: bg,
        border: null,
        middle: Text(
          l10n.transactionLocation_mapTitle,
          style: AppFonts.body(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
        leading: CupertinoNavigationBarBackButton(
          color: accent,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(_pin),
          child: Text(
            l10n.common_done,
            style: AppFonts.body(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _pin,
                initialZoom: 15,
                onTap: (_, point) => setState(() => _pin = point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.hestia.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pin,
                      width: 44,
                      height: 44,
                      alignment: Alignment.bottomCenter,
                      child: Icon(
                        CupertinoIcons.location_solid,
                        size: 40,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bg.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Text(
                '${_pin.latitude.toStringAsFixed(5)}, ${_pin.longitude.toStringAsFixed(5)}',
                style: AppFonts.body(fontSize: 13, color: fg),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 72,
            child: Text(
              '© OpenStreetMap',
              style: AppFonts.body(
                  fontSize: 10, color: fg.withValues(alpha: 0.55)),
            ),
          ),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
