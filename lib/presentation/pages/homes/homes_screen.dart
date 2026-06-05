import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/home.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/primary_button.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Trash, EditPencil, Plus;
import 'package:latlong2/latlong.dart';

class HomesScreen extends StatefulWidget {
  const HomesScreen({super.key});

  @override
  State<HomesScreen> createState() => _HomesScreenState();
}

class _HomesScreenState extends State<HomesScreen> {
  List<Home> _homes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (!mounted) return;
    if (household == null) {
      setState(() {
        _homes = const [];
        _loading = false;
      });
      return;
    }
    final (homes, _) = await AppDependencies.instance.homeRepository
        .getHomes(household.id, activeOnly: false);
    if (!mounted) return;
    setState(() {
      _homes = homes;
      _loading = false;
    });
  }

  Future<void> _delete(Home home) async {
    await AppDependencies.instance.homeRepository.deleteHome(home.id);
    setState(() => _homes.removeWhere((h) => h.id == home.id));
  }

  void _openAddSheet() {
    _openSheet(null);
  }

  void _openSheet(Home? existing) {
    showAppBottomSheet<void>(
      context: context,
      title: existing == null ? 'Add home' : 'Edit home',
      child: _HomeFormSheet(
        existing: existing,
        onSaved: (home) async {
          final deps = AppDependencies.instance;
          if (existing == null) {
            final (created, _) = await deps.homeRepository.createHome(home);
            if (created != null && mounted) {
              setState(() => _homes.add(created));
            }
          } else {
            await deps.homeRepository.updateHome(home);
            if (mounted) {
              setState(() {
                final i = _homes.indexWhere((h) => h.id == home.id);
                if (i >= 0) _homes[i] = home;
              });
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.foregroundColor);
    final muted = hexToColor(theme.mutedColor);
    final accent = hexToColor(theme.primaryColor);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Homes',
      trailing: GestureDetector(
        onTap: _openAddSheet,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Plus(width: 22, height: 22, color: accent),
        ),
      ),
      child: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : _homes.isEmpty
              ? _Empty(
                  muted: muted,
                  accent: accent,
                  onAdd: _openAddSheet,
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _homes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final home = _homes[i];
                    return SwipeableCard(
                      leftActions: [
                        SwipeAction(
                          color: CupertinoColors.destructiveRed,
                          icon: Trash(
                              width: 18,
                              height: 18,
                              color: CupertinoColors.white),
                          label: 'Delete',
                          onTap: () => _delete(home),
                        ),
                      ],
                      rightActions: [
                        SwipeAction(
                          color: CupertinoColors.activeBlue,
                          icon: EditPencil(
                              width: 18,
                              height: 18,
                              color: CupertinoColors.white),
                          label: 'Edit',
                          onTap: () => _openSheet(home),
                        ),
                      ],
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        // Open the full map to inspect / re-pick the location.
                        onTap: () => context.push(AppRoutes.globalMap),
                        child: Container(
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border, width: 0.8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Row(
                          children: [
                            // Mini-map
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: _MiniMap(
                                latitude: home.latitude,
                                longitude: home.longitude,
                                accent: accent,
                              ),
                            ),
                            // Info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      home.name,
                                      style: AppFonts.body(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: fg),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      home.address,
                                      style: AppFonts.body(
                                          fontSize: 12, color: muted),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ── Mini map (non-interactive) ────────────────────────────────────────────────

class _MiniMap extends StatefulWidget {
  final double latitude, longitude;
  final Color accent;

  const _MiniMap(
      {required this.latitude, required this.longitude, required this.accent});

  @override
  State<_MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<_MiniMap> {
  @override
  Widget build(BuildContext context) {
    final point = LatLng(widget.latitude, widget.longitude);
    return IgnorePointer(
      child: FlutterMap(
        options: MapOptions(
          initialCenter: point,
          initialZoom: 14,
          interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.none),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.charlymech.hestia',
            retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
          ),
          MarkerLayer(markers: [
            Marker(
              point: point,
              width: 32,
              height: 32,
              child: Icon(
                CupertinoIcons.location_solid,
                color: widget.accent,
                size: 28,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _Empty extends StatelessWidget {
  final Color muted, accent;
  final VoidCallback onAdd;

  const _Empty(
      {required this.muted, required this.accent, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text('No homes yet',
                style: AppFonts.body(fontSize: 16, color: muted)),
            Text('Add your home to associate it with transactions.',
                textAlign: TextAlign.center,
                style: AppFonts.body(fontSize: 13, color: muted)),
            PrimaryButton(
              label: 'Add home',
              onPressed: onAdd,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add/Edit sheet ────────────────────────────────────────────────────────────

class _HomeFormSheet extends StatefulWidget {
  final Home? existing;
  final void Function(Home) onSaved;

  const _HomeFormSheet({required this.onSaved, this.existing});

  @override
  State<_HomeFormSheet> createState() => _HomeFormSheetState();
}

class _HomeFormSheetState extends State<_HomeFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late double _lat;
  late double _lng;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _address = TextEditingController(text: widget.existing?.address ?? '');
    _lat = widget.existing?.latitude ?? 40.4168;
    _lng = widget.existing?.longitude ?? -3.7038;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _address.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final auth = context.read<AuthBloc>().state;
    final householdId = auth is AuthAuthenticated
        ? (await AppDependencies.instance.householdRepository
                .getCurrentHousehold(auth.profile.id))
            .$1
            ?.id
        : null;
    if (householdId == null) return;

    final home = Home(
      id: widget.existing?.id ?? '',
      householdId: householdId,
      name: _name.text.trim(),
      address: _address.text.trim(),
      latitude: _lat,
      longitude: _lng,
      description: widget.existing?.description,
      imageUrl: widget.existing?.imageUrl,
      isActive: widget.existing?.isActive ?? true,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    widget.onSaved(home);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final surface =
        Color(int.parse(theme.surfaceColor.replaceFirst('#', '0xff')));
    final border =
        Color(int.parse(theme.outlineColor.replaceFirst('#', '0xff')));
    final fg =
        Color(int.parse(theme.foregroundColor.replaceFirst('#', '0xff')));
    final muted = Color(int.parse(theme.mutedColor.replaceFirst('#', '0xff')));
    final accent =
        Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff')));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
        left: 20,
        right: 20,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          _field(_name, 'Name', 'e.g. Main Apartment',
              surface: surface, border: border, fg: fg, muted: muted),
          _field(_address, 'Address', 'Full street address',
              surface: surface, border: border, fg: fg, muted: muted),
          // Location note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              spacing: 8,
              children: [
                const Icon(CupertinoIcons.location_fill,
                    size: 14, color: CupertinoColors.activeBlue),
                Expanded(
                  child: Text(
                    'Coordinates: ${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}\n'
                    'Tap the map in the full map view to pick a precise location.',
                    style: AppFonts.body(fontSize: 11, color: muted),
                  ),
                ),
              ],
            ),
          ),
          PrimaryButton(
            label: widget.existing == null ? 'Add home' : 'Save changes',
            onPressed: _saving ? null : _save,
            loading: _saving,
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String placeholder, {
    required Color surface,
    required Color border,
    required Color fg,
    required Color muted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(label,
            style: AppFonts.body(
                fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
        CupertinoTextField(
          controller: ctrl,
          placeholder: placeholder,
          style: AppFonts.body(fontSize: 15, color: fg),
          placeholderStyle: AppFonts.body(fontSize: 15, color: muted),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 0.8),
          ),
        ),
      ],
    );
  }
}
