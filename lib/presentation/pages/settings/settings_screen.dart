import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/app_info.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/widgets/common/app_toast.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/blocs/app_update/app_update_cubit.dart';
import 'package:hestia/presentation/widgets/common/app_update_dialog.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show
        HalfMoon,
        Globe,
        Fingerprint,
        Bell,
        Clock,
        CalendarPlus,
        Cart,
        Car,
        HomeSimpleDoor,
        Refresh;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _locationServiceEnabled = true;
  LocationPermission? _locationPermission;
  String? _gcalEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPermissions();
      _refreshGcal();
    });
  }

  Future<void> _refreshGcal() async {
    final gcal = AppDependencies.instance.googleCalendarService;
    if (gcal == null) return;
    try {
      final email = await gcal.linkedEmail();
      if (mounted) setState(() => _gcalEmail = email);
    } catch (_) {/* not linked */}
  }

  Future<void> _manageGoogleCalendar() async {
    final deps = AppDependencies.instance;
    final gcal = deps.googleCalendarService;
    if (gcal == null) {
      context.showToast(const AppToastConfig(
        type: ToastType.error,
        title: 'Calendar sync needs the Supabase build',
      ));
      return;
    }
    final auth = context.read<AuthBloc>().state;
    final userId = auth is AuthAuthenticated ? auth.profile.id : null;
    final calendarColor =
        auth is AuthAuthenticated ? auth.profile.calendarColor : null;

    final linked = await gcal.isLinked();
    if (!mounted) return;

    if (linked) {
      // Offer sync now / unlink.
      final action = await showCupertinoModalPopup<String>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          title: Text(_gcalEmail ?? 'Google Calendar'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, 'sync'),
              child: const Text('Sync now'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, 'unlink'),
              child: const Text('Disconnect'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ),
      );
      if (action == 'sync' && userId != null) {
        await deps.appointmentRepository.syncWithGoogle(
            userId: userId, defaultColor: calendarColor);
        if (mounted) {
          context.showToast(const AppToastConfig(
              type: ToastType.success, title: 'Calendar synced'));
        }
      } else if (action == 'unlink') {
        await gcal.unlink();
        if (mounted) setState(() => _gcalEmail = null);
      }
    } else {
      final ok = await gcal.link();
      if (ok) {
        await _refreshGcal();
        if (userId != null) {
          await deps.appointmentRepository.syncWithGoogle(
              userId: userId, defaultColor: calendarColor);
        }
        if (mounted) {
          context.showToast(const AppToastConfig(
              type: ToastType.success, title: 'Google Calendar connected'));
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    try {
      final loc = AppDependencies.instance.locationService;
      final svc = await loc.isLocationServiceEnabled();
      final perm = await loc.checkPermission();
      final notif = await Permission.notification.status;
      if (!mounted) return;
      setState(() {
        _locationServiceEnabled = svc;
        _locationPermission = perm;
      });
      // Sync notification pref with real device state.
      final allowed = notif.isGranted;
      final prefs = context.read<UserPrefsBloc>().state;
      if (prefs.allowNotifications != allowed && mounted) {
        context
            .read<UserPrefsBloc>()
            .add(UserPrefsSetAllowNotifications(allowed));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationServiceEnabled = false;
        _locationPermission = LocationPermission.denied;
      });
    }
  }

  Future<void> _pickStartDay(
      BuildContext context, UserPrefsState prefs, AppLocalizations l10n) async {
    final options = <({int v, String label})>[
      (v: DateTime.monday, label: 'Monday'),
      (v: DateTime.saturday, label: 'Saturday'),
      (v: DateTime.sunday, label: 'Sunday'),
    ];
    final picked = await _showOptionSheet<int>(
      context: context,
      title: l10n.settings_startDay,
      current: prefs.startDay,
      options: options,
    );
    if (picked != null && context.mounted) {
      context.read<UserPrefsBloc>().add(UserPrefsSetStartDay(picked));
    }
  }

  String _startDayLabel(int day) => switch (day) {
        DateTime.monday => 'Monday',
        DateTime.saturday => 'Saturday',
        DateTime.sunday => 'Sunday',
        _ => 'Monday',
      };

  Future<void> _pickLanguage(
      BuildContext context, UserPrefsState prefs, AppLocalizations l10n) async {
    final options = <({String v, String label})>[
      (v: 'en', label: l10n.settings_languageEn),
      (v: 'es', label: l10n.settings_languageEs),
    ];
    final picked = await _showOptionSheet<String>(
      context: context,
      title: l10n.settings_language,
      current: prefs.languageCode,
      options: options,
    );
    if (picked != null && context.mounted) {
      context.read<UserPrefsBloc>().add(UserPrefsSetLanguageCode(picked));
    }
  }

  Future<void> _pickTheme(
      BuildContext context, UserPrefsState prefs, AppLocalizations l10n) async {
    final options = <({ThemeType v, String label})>[
      (v: ThemeType.system, label: l10n.settings_themeSystem),
      (v: ThemeType.light, label: l10n.settings_themeLight),
      (v: ThemeType.dark, label: l10n.settings_themeDark),
    ];
    final picked = await _showOptionSheet<ThemeType>(
      context: context,
      title: l10n.settings_theme,
      current: prefs.themeType,
      options: options,
    );
    if (picked != null && context.mounted) {
      context.read<UserPrefsBloc>().add(UserPrefsSetThemeType(picked));
    }
  }

  Future<T?> _showOptionSheet<T>({
    required BuildContext context,
    required String title,
    required T current,
    required List<({T v, String label})> options,
  }) {
    final theme = context.myTheme;
    final fg = hexToColor(theme.onBackgroundColor);
    final accent = hexToColor(theme.primaryColor);
    final border = hexToColor(theme.borderColor);
    return showAppBottomSheet<T>(
      context: context,
      title: title,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < options.length; i++) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(options[i].v),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          options[i].label,
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: options[i].v == current
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: options[i].v == current ? accent : fg,
                          ),
                        ),
                      ),
                      if (options[i].v == current)
                        Icon(CupertinoIcons.check_mark,
                            size: 16, color: accent),
                    ],
                  ),
                ),
              ),
              if (i < options.length - 1) Container(height: 1, color: border),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateFormat(
      BuildContext context, UserPrefsState prefs, AppLocalizations l10n) async {
    final options = <({String v, String label})>[
      (v: 'mdy', label: l10n.settings_dateFormatMdy),
      (v: 'dmy', label: l10n.settings_dateFormatDmy),
      (v: 'ymd', label: l10n.settings_dateFormatYmd),
    ];
    final picked = await _showOptionSheet<String>(
      context: context,
      title: l10n.settings_dateFormat,
      current: prefs.dateFormat,
      options: options,
    );
    if (picked != null && context.mounted) {
      context.read<UserPrefsBloc>().add(UserPrefsSetDateFormat(picked));
    }
  }

  String _dateFormatLabel(String value, AppLocalizations l10n) =>
      switch (value) {
        'dmy' => l10n.settings_dateFormatDmy,
        'ymd' => l10n.settings_dateFormatYmd,
        _ => l10n.settings_dateFormatMdy,
      };

  bool _locationAllowed() {
    if (!_locationServiceEnabled) return false;
    final p = _locationPermission;
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  Future<void> _setLocationAllowed(BuildContext context, bool value) async {
    final loc = AppDependencies.instance.locationService;
    if (value) {
      final perm = await loc.checkPermission();
      if (perm == LocationPermission.deniedForever) {
        if (context.mounted) await _showOpenSettingsDialog(context, 'Location');
      } else {
        await loc.requestPermission();
      }
    } else {
      if (context.mounted) {
        await _showOpenSettingsDialog(context, 'Location',
            message:
                'To disable location access, open Settings → Hestia → Location and turn it off.');
      }
    }
    await _refreshPermissions();
  }

  Future<void> _setNotificationsAllowed(
      BuildContext context, bool value) async {
    // Capture before any async gap.
    final auth = context.read<AuthBloc>().state;
    final userId = auth is AuthAuthenticated ? auth.profile.id : null;
    if (value) {
      final status = await Permission.notification.status;
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showOpenSettingsDialog(context, 'Notifications');
        }
      } else {
        // Request via the push service so the FCM token is registered on grant.
        await AppDependencies.instance.pushNotificationService
            .requestPermission(userId: userId);
      }
    } else {
      if (context.mounted) {
        await _showOpenSettingsDialog(context, 'Notifications',
            message:
                'To disable notifications, open Settings → Hestia → Notifications and turn them off.');
      }
    }
    // Reconcile the toggle with the real device state (handles deny/cancel).
    await _refreshPermissions();
  }

  Future<void> _showOpenSettingsDialog(
    BuildContext context,
    String permission, {
    String? message,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('$permission access'),
        content: Text(message ??
            'Hestia needs $permission access. Tap "Open Settings" to enable it.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _setFaceIdUnlock(BuildContext context, bool value) async {
    if (value) {
      final auth = LocalAuthentication();
      final can = await auth.canCheckBiometrics;
      if (!can) return;
    }
    if (!context.mounted) return;
    context.read<UserPrefsBloc>().add(UserPrefsSetFaceIdUnlock(value));
  }

  String _themeLabel(ThemeType t, AppLocalizations l10n) => switch (t) {
        ThemeType.light => l10n.settings_themeLight,
        ThemeType.dark => l10n.settings_themeDark,
        ThemeType.system => l10n.settings_themeSystem,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<UserPrefsBloc>().state;
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final tints = theme.categoryTints.map(hexToColor).toList();

    final sections = <_Section>[
      _Section(l10n.settings_modules, [
        _Tile.toggle(
          icon: Car(width: 16, height: 16, color: tints[3]),
          color: tints[3],
          label: l10n.settings_carsModule,
          value: prefs.showFuelModule,
          onChanged: (v) =>
              context.read<UserPrefsBloc>().add(UserPrefsSetShowFuelModule(v)),
        ),
        if (!prefs.showFuelModule)
          _Tile.chevron(
            icon: Car(width: 16, height: 16, color: tints[3]),
            color: tints[3],
            label: l10n.settings_viewCarsData,
            sub: l10n.settings_carsSub,
            onTap: () => context.push(AppRoutes.cars),
          ),
      ]),
      _Section(l10n.settings_dataManagement, [
        _Tile.chevron(
          icon: Cart(width: 16, height: 16, color: tints[0]),
          color: tints[0],
          label: l10n.settings_dataManagement,
          sub: '${l10n.settings_categoriesTab} · ${l10n.settings_sourcesTab}',
          onTap: () => context.push(AppRoutes.dataManagement),
        ),
        _Tile.chevron(
          icon: HomeSimpleDoor(
              width: 16, height: 16, color: tints[4 % tints.length]),
          color: tints[4 % tints.length],
          label: 'Homes',
          sub: 'Manage household locations',
          onTap: () => context.push(AppRoutes.homes),
        ),
        _Tile.chevron(
          icon: CalendarPlus(width: 16, height: 16, color: tints[1]),
          color: tints[1],
          label: 'Google Calendar',
          sub: _gcalEmail ?? 'Connect a Google account to sync events',
          onTap: _manageGoogleCalendar,
        ),
      ]),
      _Section(l10n.settings_general, [
        _Tile.chevron(
          icon: HalfMoon(width: 16, height: 16, color: tints[2]),
          color: tints[2],
          label: l10n.settings_appearance,
          sub: _themeLabel(prefs.themeType, l10n),
          onTap: () => _pickTheme(context, prefs, l10n),
        ),
        _Tile.chevron(
          icon: Globe(width: 16, height: 16, color: tints[3]),
          color: tints[3],
          label: l10n.settings_language,
          sub: prefs.languageCode == 'es'
              ? l10n.settings_languageEs
              : l10n.settings_languageEn,
          onTap: () => _pickLanguage(context, prefs, l10n),
        ),
        _Tile.chevron(
          icon: CalendarPlus(width: 16, height: 16, color: tints[0]),
          color: tints[0],
          label: l10n.settings_startDay,
          sub: _startDayLabel(prefs.startDay),
          onTap: () => _pickStartDay(context, prefs, l10n),
        ),
        _Tile.toggle(
          icon: Clock(width: 16, height: 16, color: tints[1]),
          color: tints[1],
          label: l10n.settings_use24h,
          value: prefs.use24h,
          onChanged: (v) =>
              context.read<UserPrefsBloc>().add(UserPrefsSetUse24h(v)),
        ),
        _Tile.chevron(
          icon: CalendarPlus(
              width: 16, height: 16, color: tints[4 % tints.length]),
          color: tints[4 % tints.length],
          label: l10n.settings_dateFormat,
          sub: _dateFormatLabel(prefs.dateFormat, l10n),
          onTap: () => _pickDateFormat(context, prefs, l10n),
        ),
        _Tile.toggle(
          icon: Globe(width: 16, height: 16, color: tints[3]),
          color: tints[3],
          label: l10n.settings_allowLocation,
          value: _locationAllowed(),
          onChanged: (v) => _setLocationAllowed(context, v),
        ),
        _Tile.toggle(
          icon: Bell(width: 16, height: 16, color: tints[1]),
          color: tints[1],
          label: l10n.settings_allowNotifications,
          value: prefs.allowNotifications,
          onChanged: (v) => _setNotificationsAllowed(context, v),
        ),
        _Tile.toggle(
          icon: Fingerprint(width: 16, height: 16, color: tints[5]),
          color: tints[5],
          label: l10n.settings_faceIdUnlock,
          value: prefs.faceIdUnlock,
          onChanged: (v) => _setFaceIdUnlock(context, v),
        ),
      ]),
      // if (profile?.isSuperuser == true)
      //   _Section('Admin', [
      //     _Tile.chevron(
      //       icon: UserPlus(width: 16, height: 16, color: accent),
      //       color: accent,
      //       label: 'Create user',
      //       sub: 'Add a new household member',
      //       onTap: () => showAppBottomSheet<void>(
      //         context: context,
      //         title: 'Create user',
      //         heightFactor: 0.7,
      //         child: const CreateUserForm(),
      //       ),
      //     ),
      //   ]),
    ];

    Widget tileWidget(_Tile t, {required bool last}) => GestureDetector(
          onTap: t.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              border: last
                  ? null
                  : Border(bottom: BorderSide(color: border, width: 1)),
            ),
            child: Row(
              children: [
                CatTile(icon: t.icon, color: t.color, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.label,
                        style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: fg,
                        ),
                      ),
                      if (t.sub != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          t.sub!,
                          style: AppFonts.body(fontSize: 12, color: muted),
                        ),
                      ],
                    ],
                  ),
                ),
                if (t.kind == _TileKind.toggle)
                  CupertinoSwitch(
                    value: t.value!,
                    onChanged: t.onChanged!,
                    activeTrackColor: hexToColor(theme.primaryColor),
                    inactiveTrackColor: hexToColor(theme.backgroundColor),
                    thumbColor: CupertinoColors.white,
                  )
                else if (t.kind == _TileKind.chevron)
                  ChevronIcon(color: muted),
              ],
            ),
          ),
        );

    Widget sectionCard(_Section s) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < s.tiles.length; i++)
                tileWidget(s.tiles[i], last: i == s.tiles.length - 1),
            ],
          ),
        );

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: l10n.settings_title,
      child: ScreenShell(
        bg: bg,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          for (final s in sections) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            if (s.title.isNotEmpty)
              SliverToBoxAdapter(child: SectionLabel(s.title, color: muted)),
            if (s.title.isNotEmpty)
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: sectionCard(s)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: _UpdateTile(
              surface: surface,
              fg: fg,
              muted: muted,
              accent: hexToColor(theme.primaryColor),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Center(
              child: Text(
                AppInfo.display.isEmpty
                    ? 'Hestia'
                    : 'Hestia · v${AppInfo.display}',
                style: AppFonts.label(
                  fontSize: 11,
                  color: muted.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _TileKind { chevron, toggle }

class _Tile {
  final Widget icon;
  final Color color;
  final String label;
  final String? sub;
  final _TileKind kind;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  const _Tile._({
    required this.icon,
    required this.color,
    required this.label,
    this.sub,
    required this.kind,
    this.value,
    this.onChanged,
    this.onTap,
  });

  factory _Tile.chevron({
    required Widget icon,
    required Color color,
    required String label,
    String? sub,
    VoidCallback? onTap,
  }) =>
      _Tile._(
        icon: icon,
        color: color,
        label: label,
        sub: sub,
        kind: _TileKind.chevron,
        onTap: onTap,
      );

  factory _Tile.toggle({
    required Widget icon,
    required Color color,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      _Tile._(
        icon: icon,
        color: color,
        label: label,
        kind: _TileKind.toggle,
        value: value,
        onChanged: onChanged,
      );
}

class _Section {
  final String title;
  final List<_Tile> tiles;
  _Section(this.title, this.tiles);
}

class _UpdateTile extends StatelessWidget {
  final Color surface;
  final Color fg;
  final Color muted;
  final Color accent;
  const _UpdateTile({
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppUpdateCubit>().state;
    final hasUpdate = state.hasUpdate;
    final c = hasUpdate ? accent : muted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: hasUpdate
            ? () => showAppUpdateDialog(context, state.latest!)
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              CatTile(
                icon: hasUpdate
                    ? Refresh(width: 16, height: 16, color: c)
                    : Bell(width: 16, height: 16, color: c),
                color: c,
                size: 34,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profile_appUpdate,
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasUpdate
                          ? l10n.profile_updateAvailable
                          : l10n.profile_upToDate,
                      style: AppFonts.body(fontSize: 12, color: c),
                    ),
                  ],
                ),
              ),
              if (hasUpdate)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
