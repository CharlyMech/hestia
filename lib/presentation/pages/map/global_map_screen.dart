import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/services/location_service.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/home.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/map/map_bloc.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/status_bar_blur_overlay.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:latlong2/latlong.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

const _kLocateZoom = 15.0;
const _kAnimDuration = Duration(milliseconds: 500);

/// Full-screen map. Consumes the app-level [MapBloc] (provided in app.dart) so
/// the camera position and loaded data stay in sync with the dashboard preview.
class GlobalMapScreen extends StatefulWidget {
  const GlobalMapScreen({super.key});

  @override
  State<GlobalMapScreen> createState() => _GlobalMapViewState();
}

class _GlobalMapViewState extends State<GlobalMapScreen>
    with TickerProviderStateMixin {
  late AnimatedMapController _mapCtrl;

  bool _showTransactions = true;
  bool _showHomes = true;
  bool _showVendors = true;

  List<Transaction> _transactions = [];
  List<Home> _homes = [];
  List<TransactionSource> _vendors = [];

  LatLng? _userLocation;
  StreamSubscription<Position>? _locationSub;

  Object? _selectedItem;
  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _mapCtrl = AnimatedMapController(vsync: this);
    _sheetCtrl.addListener(_onSheetScroll);
    // Seed render cache from whatever the shared bloc already has.
    _onMapData(context.read<MapBloc>().state);
    _maybeStartLocationStream();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _mapCtrl.dispose();
    _sheetCtrl.removeListener(_onSheetScroll);
    _sheetCtrl.dispose();
    super.dispose();
  }

  // ── Sheet ───────────────────────────────────────────────────────────────────

  void _onSheetScroll() {
    final isOpen = _sheetCtrl.isAttached && _sheetCtrl.size > 0.15;
    if (isOpen != _sheetOpen && mounted) setState(() => _sheetOpen = isOpen);
  }

  void _clearSelection() {
    setState(() => _selectedItem = null);
    _sheetCtrl.animateTo(0.12,
        duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
  }

  // ── Location stream ─────────────────────────────────────────────────────────

  Future<void> _maybeStartLocationStream() async {
    final granted = await LocationService().hasPermission();
    if (!granted || !mounted) return;
    _startLocationStream();
  }

  void _startLocationStream() {
    _locationSub?.cancel();
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      if (!mounted) return;
      setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
      // Share device location with the rest of the app (dashboard pin).
      context
          .read<MapBloc>()
          .add(MapUserLocationUpdated(pos.latitude, pos.longitude));
    });
  }

  // ── Data from bloc ──────────────────────────────────────────────────────────

  void _onMapData(MapState s) {
    if (s is MapLoaded) {
      _transactions = s.transactions;
      _homes = s.homes;
      _vendors = s.nearbyVendors;
    }
    if (s.hasUserLocation) {
      _userLocation = LatLng(s.userLat!, s.userLng!);
    }
  }

  // ── Location button ─────────────────────────────────────────────────────────

  Future<void> _centerOnUser() async {
    final loc = _userLocation;
    if (loc != null) {
      _mapCtrl.animateTo(dest: loc, zoom: _kLocateZoom);
      _emitCamera(loc.latitude, loc.longitude, _kLocateZoom);
      return;
    }

    final svc = LocationService();
    final granted = await svc.ensureWhenInUsePermission();
    if (!granted) {
      await svc.openSystemAppSettings();
      return;
    }
    if (!mounted) return;
    _startLocationStream();

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 5));
      if (!mounted) return;
      final newLoc = LatLng(pos.latitude, pos.longitude);
      setState(() => _userLocation = newLoc);
      _mapCtrl.animateTo(dest: newLoc, zoom: _kLocateZoom);
      // Persist as the user location AND recentre the shared camera.
      context.read<MapBloc>().add(
            MapUserLocationUpdated(pos.latitude, pos.longitude, recenter: true),
          );
    } catch (_) {
      // Timeout — stay put.
    }
  }

  // ── Map-move → persist camera + re-filter vendors ────────────────────────────

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    final c = camera.center;
    _emitCamera(c.latitude, c.longitude, camera.zoom);
  }

  void _emitCamera(double lat, double lng, double zoom) {
    context.read<MapBloc>().add(MapCameraMoved(lat, lng, zoom));
  }

  // ── Marker tap ──────────────────────────────────────────────────────────────

  void _onMarkerTap(Object item) {
    setState(() => _selectedItem = item);
    _sheetCtrl.animateTo(0.40,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final neutralColor = hexToColor(theme.neutralColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final onStatus = hexToColor(theme.onStatusColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final errorColor = hexToColor(theme.errorColor);
    final successColor = hexToColor(theme.successColor);
    final top = MediaQuery.viewPaddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final l10n = AppLocalizations.of(context);

    final markers = _buildMarkers(accent, errorColor, successColor);

    // Open at the last shared camera position (set by the dashboard preview
    // or a previous map session).
    final initialState = context.read<MapBloc>().state;
    final initialCenter =
        LatLng(initialState.cameraLat, initialState.cameraLng);

    return BlocListener<MapBloc, MapState>(
      listener: (_, state) => setState(() => _onMapData(state)),
      child: Material(
        color: surface,
        child: Stack(
          children: [
            // ── Map ──────────────────────────────────────────────────────────
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapCtrl.mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: initialState.cameraZoom,
                  onPositionChanged: _onPositionChanged,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.charlymech.hestia',
                    retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
                  ),
                  if (markers.isNotEmpty) MarkerLayer(markers: markers),
                  // User position dot
                  if (_userLocation != null)
                    MarkerLayer(markers: [
                      Marker(
                        point: _userLocation!,
                        width: 36,
                        height: 36,
                        child: SvgPicture.asset('assets/map_pins/user.svg'),
                      ),
                    ]),
                  // OSM + CARTO attribution (required by their terms)
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                      TextSourceAttribution('© CARTO'),
                    ],
                  ),
                ],
              ),
            ),

            StatusBarBlurOverlay(
                tint: surface, peakOpacity: 0.92, fadeExtent: 20),

            // ── Back ─────────────────────────────────────────────────────────
            Positioned(
              top: top + 12,
              left: 12,
              child: AnimatedButton(
                onTap: () => context.pop(),
                borderRadius: AppRadii.full,
                backgroundColor: surface.withValues(alpha: 0.82),
                borderColor: border,
                borderWidth: 0.8,
                padding: const EdgeInsets.all(10),
                child: iconoir.NavArrowLeft(width: 18, height: 18, color: fg),
              ),
            ),

            // ── Layer toggles ─────────────────────────────────────────────────
            Positioned(
              top: top + 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  _LayerBadge(
                    active: _showTransactions,
                    label: l10n.map_toggleTransactions,
                    icon: (color) =>
                        iconoir.CoinsSwap(width: 20, height: 20, color: color),
                    activeColor: neutralColor,
                    surface: surface,
                    border: border,
                    fg: onStatus,
                    muted: muted,
                    onTap: () =>
                        setState(() => _showTransactions = !_showTransactions),
                  ),
                  _LayerBadge(
                    active: _showHomes,
                    label: l10n.map_toggleHomes,
                    icon: (color) =>
                        iconoir.Home(width: 20, height: 20, color: color),
                    activeColor: accent,
                    surface: surface,
                    border: border,
                    fg: onStatus,
                    muted: muted,
                    onTap: () => setState(() => _showHomes = !_showHomes),
                  ),
                  _LayerBadge(
                    active: _showVendors,
                    label: l10n.map_toggleVendors,
                    icon: (color) =>
                        iconoir.Shop(width: 20, height: 20, color: color),
                    activeColor: const Color(0xFFE91E8C),
                    surface: surface,
                    border: border,
                    fg: onStatus,
                    muted: muted,
                    onTap: () => setState(() => _showVendors = !_showVendors),
                  ),
                ],
              ),
            ),

            // ── Right side: locate + zoom ─────────────────────────────────────
            if (!_sheetOpen)
              Positioned(
                  right: 12,
                  bottom: bottom + 90,
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedButton(
                        size: 45,
                        onTap: () => _mapCtrl.animatedZoomIn(
                            customId: 'zoom', duration: _kAnimDuration),
                        child: iconoir.Plus(width: 20, height: 20, color: fg),
                      ),
                      AnimatedButton(
                        size: 45,
                        onTap: () => _mapCtrl.animatedZoomOut(
                            customId: 'zoom', duration: _kAnimDuration),
                        child: iconoir.Minus(width: 20, height: 20, color: fg),
                      ),
                      AnimatedButton(
                        onTap: _centerOnUser,
                        size: 65,
                        child:
                            iconoir.Position(width: 40, height: 40, color: fg),
                      ),
                    ],
                  )
                  // child: Column(
                  //   spacing: 8,
                  //   children: [
                  //     AnimatedButton(
                  //       onTap: _centerOnUser,
                  //       borderRadius: 14,
                  //       backgroundColor: surface.withValues(alpha: 0.82),
                  //       borderColor: border,
                  //       borderWidth: 0.8,
                  //       padding: const EdgeInsets.all(10),
                  //       child: iconoir.Position(width: 20, height: 20, color: fg),
                  //     ),
                  //     AnimatedButton(
                  //       onTap: () => _mapCtrl.animatedZoomIn(
                  //           customId: 'zoom', duration: _kAnimDuration),
                  //       borderRadius: 14,
                  //       backgroundColor: surface.withValues(alpha: 0.82),
                  //       borderColor: border,
                  //       borderWidth: 0.8,
                  //       padding: const EdgeInsets.all(10),
                  //       child: iconoir.Plus(width: 20, height: 20, color: fg),
                  //     ),
                  //     AnimatedButton(
                  //       onTap: () => _mapCtrl.animatedZoomOut(
                  //           customId: 'zoom', duration: _kAnimDuration),
                  //       borderRadius: 14,
                  //       backgroundColor: surface.withValues(alpha: 0.82),
                  //       borderColor: border,
                  //       borderWidth: 0.8,
                  //       padding: const EdgeInsets.all(10),
                  //       child: iconoir.Minus(width: 20, height: 20, color: fg),
                  //     ),
                  //   ],
                  // ),
                  ),

            // ── Bottom sheet ──────────────────────────────────────────────────
            DraggableScrollableSheet(
              controller: _sheetCtrl,
              initialChildSize: 0.12,
              minChildSize: 0.12,
              maxChildSize: 0.55,
              snap: true,
              snapSizes: const [0.12, 0.40],
              builder: (ctx, scrollCtrl) => _BottomPanel(
                scrollController: scrollCtrl,
                selected: _selectedItem,
                onDismiss: _clearSelection,
                surface: surface,
                fg: fg,
                muted: muted,
                accent: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Marker builder ───────────────────────────────────────────────────────────

  List<Marker> _buildMarkers(
      Color accent, Color errorColor, Color successColor) {
    final markers = <Marker>[];

    if (_showHomes) {
      for (final h in _homes) {
        markers.add(Marker(
          point: LatLng(h.latitude, h.longitude),
          width: 52,
          height: 52,
          child: GestureDetector(
            onTap: () => _onMarkerTap(h),
            child: SvgPicture.asset('assets/map_pins/pin_home.svg'),
          ),
        ));
      }
    }

    if (_showTransactions) {
      for (final t in _transactions) {
        final isExpense = t.type == TransactionType.expense;
        markers.add(Marker(
          point: LatLng(t.latitude!, t.longitude!),
          width: 52,
          height: 52,
          child: GestureDetector(
            onTap: () => _onMarkerTap(t),
            child: SvgPicture.asset(
              isExpense
                  ? 'assets/map_pins/pin_expense.svg'
                  : 'assets/map_pins/pin_income.svg',
            ),
          ),
        ));
      }
    }

    if (_showVendors) {
      for (final v in _vendors) {
        markers.add(Marker(
          point: LatLng(v.latitude!, v.longitude!),
          width: 52,
          height: 52,
          child: GestureDetector(
            onTap: () => _onMarkerTap(v),
            child: SvgPicture.asset('assets/map_pins/pin_vendor.svg'),
          ),
        ));
      }
    }

    return markers;
  }
}

// ── Layer badge ───────────────────────────────────────────────────────────────

class _LayerBadge extends StatelessWidget {
  final bool active;
  final String label;
  final Widget Function(Color color) icon;
  final Color activeColor, surface, border, fg, muted;
  final VoidCallback onTap;

  const _LayerBadge({
    required this.active,
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.80)
              : surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            icon(active ? fg : fg.withValues(alpha: 0.80)),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? fg : fg.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom panel ──────────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  final ScrollController scrollController;
  final Object? selected;
  final VoidCallback onDismiss;
  final Color surface, fg, muted, accent;

  const _BottomPanel({
    required this.scrollController,
    required this.selected,
    required this.onDismiss,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: MediaQuery.paddingOf(context).bottom + 40,
          child: ColoredBox(color: surface),
        ),
        AppSheetShell(
          expand: true,
          scrollController: scrollController,
          child: selected == null
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    'Tap a pin for details',
                    style: AppFonts.body(fontSize: 13, color: muted),
                    textAlign: TextAlign.center,
                  ),
                )
              : _SelectedContent(
                  item: selected!,
                  onDismiss: onDismiss,
                  fg: fg,
                  muted: muted,
                  accent: accent,
                ),
        ),
      ],
    );
  }
}

// ── Selected item content ─────────────────────────────────────────────────────

class _SelectedContent extends StatelessWidget {
  final Object item;
  final VoidCallback onDismiss;
  final Color fg, muted, accent;

  const _SelectedContent({
    required this.item,
    required this.onDismiss,
    required this.fg,
    required this.muted,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              _TypeChip(item: item, accent: accent, muted: muted),
              const Spacer(),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(CupertinoIcons.xmark, size: 18, color: muted),
              ),
            ],
          ),
          ..._buildBody(),
        ],
      ),
    );
  }

  List<Widget> _buildBody() {
    if (item is Transaction) {
      final tx = item as Transaction;
      final isIncome = tx.type == TransactionType.income;
      return [
        Text(tx.note ?? tx.categoryName ?? 'Transaction',
            style: AppFonts.body(
                fontSize: 16, fontWeight: FontWeight.w600, color: fg)),
        Text(
          '${isIncome ? '+' : '-'}${tx.amount.abs().toStringAsFixed(2)}',
          style: AppFonts.body(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isIncome ? const Color(0xFF4CB782) : const Color(0xFFE53935),
          ),
        ),
        if (tx.categoryName != null)
          _InfoRow(
              label: 'Category', value: tx.categoryName!, muted: muted, fg: fg),
        _InfoRow(
          label: 'Date',
          value: '${tx.date.day}/${tx.date.month}/${tx.date.year}',
          muted: muted,
          fg: fg,
        ),
        if (tx.bankAccountName != null)
          _InfoRow(
              label: 'Account',
              value: tx.bankAccountName!,
              muted: muted,
              fg: fg),
      ];
    } else if (item is Home) {
      final home = item as Home;
      return [
        Text(home.name,
            style: AppFonts.body(
                fontSize: 16, fontWeight: FontWeight.w600, color: fg)),
        _InfoRow(label: 'Address', value: home.address, muted: muted, fg: fg),
        if (home.description != null && home.description!.isNotEmpty)
          _InfoRow(
              label: 'Notes', value: home.description!, muted: muted, fg: fg),
      ];
    } else if (item is TransactionSource) {
      final vendor = item as TransactionSource;
      return [
        Text(vendor.name,
            style: AppFonts.body(
                fontSize: 16, fontWeight: FontWeight.w600, color: fg)),
        _InfoRow(label: 'Type', value: vendor.kind.name, muted: muted, fg: fg),
        if (vendor.address != null)
          _InfoRow(
              label: 'Address', value: vendor.address!, muted: muted, fg: fg),
      ];
    }
    return [];
  }
}

class _TypeChip extends StatelessWidget {
  final Object item;
  final Color accent, muted;

  const _TypeChip(
      {required this.item, required this.accent, required this.muted});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (item) {
      Transaction() => ('Transaction', accent),
      Home() => ('Home', accent),
      TransactionSource() => ('Vendor', const Color(0xFFE91E8C)),
      _ => ('Item', muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppFonts.body(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color muted, fg;

  const _InfoRow(
      {required this.label,
      required this.value,
      required this.muted,
      required this.fg});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(label, style: AppFonts.body(fontSize: 13, color: muted)),
        Expanded(
          child: Text(value,
              style: AppFonts.body(
                  fontSize: 13, color: fg, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
