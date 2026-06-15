import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/home.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/layout/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:hestia/presentation/widgets/homes/add_edit_home_sheet_form.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Trash, EditPencil, Plus;
import 'package:iconoir_flutter/regular/home.dart' as icon_home;
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
    final l10n = AppLocalizations.of(context);
    showAppBottomSheet<void>(
      context: context,
      title: existing == null ? l10n.homes_addHome : l10n.homes_editHome,
      child: AddEditHomeSheetForm(
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
    final primary = hexToColor(theme.primaryColor);
    final onPrimary = hexToColor(theme.onPrimaryColor);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: AppLocalizations.of(context).homes_title,
      onRefresh: _load,
      // Pull-to-refresh ⇒ shell-owned Skeletonizer shimmer (no bare spinner).
      isLoading: _loading,
      trailing: AnimatedButton(
        onTap: _openAddSheet,
        padding: const EdgeInsets.all(4),
        borderRadius: AppRadii.full,
        backgroundColor: primary,
        child: Plus(width: 22, height: 22, color: onPrimary),
      ),
      child: _loading
          // Placeholder cards give the Skeletonizer shimmer a real shape.
          ? ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => Container(
                height: 90,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 0.8),
                ),
              ),
            )
          : _homes.isEmpty
              ? _Empty(
                  muted: muted,
                  accent: accent,
                  onPrimary: onPrimary,
                  onAdd: _openAddSheet,
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
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
                          label: AppLocalizations.of(context).homes_deleteLabel,
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
                          label: AppLocalizations.of(context).homes_editLabel,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
  final Color muted, accent, onPrimary;
  final VoidCallback onAdd;

  const _Empty({
    required this.muted,
    required this.accent,
    required this.onPrimary,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            icon_home.Home(width: 48, height: 48, color: muted),
            Text(l10n.homes_noHomesYet,
                style: AppFonts.body(
                    fontSize: 16, fontWeight: FontWeight.w600, color: muted)),
            Text(l10n.homes_addHomeDescription,
                textAlign: TextAlign.center,
                style: AppFonts.body(fontSize: 13, color: muted)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Text(l10n.homes_addHomeHint,
                    style: AppFonts.body(fontSize: 12, color: muted)),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Plus(width: 14, height: 14, color: onPrimary),
                  ),
                ),
                Text(l10n.homes_addHomeHintSuffix,
                    style: AppFonts.body(fontSize: 12, color: muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

