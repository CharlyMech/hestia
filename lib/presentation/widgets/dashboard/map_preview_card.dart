import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/presentation/blocs/map/map_bloc.dart';
import 'package:latlong2/latlong.dart';

/// Small non-interactive map preview on the dashboard.
///
/// Reads the shared [MapBloc] state so its camera position and the blue user
/// pin stay in sync with the full map screen. Tapping opens the full map.
class MapPreviewCard extends StatelessWidget {
  final Color surface;
  final Color border;

  const MapPreviewCard({
    super.key,
    required this.surface,
    required this.border,
  });

  static const _pinSize = 28.0;
  static const _userPinSize = 36.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        final center = LatLng(state.cameraLat, state.cameraLng);

        final homes = state is MapLoaded ? state.homes : const [];
        final transactions = state is MapLoaded ? state.transactions : const [];
        final vendors = state is MapLoaded ? state.nearbyVendors : const [];

        final markers = <Marker>[
          for (final h in homes)
            _pin(LatLng(h.latitude, h.longitude),
                'assets/map_pins/pin_home.svg'),
          for (final t in transactions.where((t) => t.hasLocation))
            _pin(
              LatLng(t.latitude!, t.longitude!),
              t.type == TransactionType.expense
                  ? 'assets/map_pins/pin_expense.svg'
                  : 'assets/map_pins/pin_income.svg',
            ),
          for (final v in vendors.where((v) => v.latitude != null))
            _pin(LatLng(v.latitude!, v.longitude!),
                'assets/map_pins/pin_vendor.svg'),
          if (state.hasUserLocation)
            Marker(
              point: LatLng(state.userLat!, state.userLng!),
              width: _userPinSize,
              height: _userPinSize,
              child: SvgPicture.asset('assets/map_pins/user.svg'),
            ),
        ];

        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 0.8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
                // Key on the camera so the preview re-centres when the shared
                // camera changes (e.g. after using the full map).
                key: ValueKey('${state.cameraLat},${state.cameraLng},'
                    '${state.cameraZoom}'),
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: state.cameraZoom,
                  interactionOptions:
                      const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.charlymech.hestia',
                    retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              // Transparent overlay — FlutterMap absorbs gestures even with
              // InteractiveFlag.none.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => context.push(AppRoutes.globalMap),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Marker _pin(LatLng point, String asset) => Marker(
        point: point,
        width: _pinSize,
        height: _pinSize,
        child: SvgPicture.asset(asset),
      );
}
