import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/widgets/admin/create_user_form.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/member_avatar.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show
        Group,
        Home,
        Mail,
        HalfMoon,
        ColorPicker,
        Globe,
        Fingerprint,
        Bell,
        Shield,
        LogOut,
        UserPlus,
        Clock,
        CalendarPlus,
        Cart,
        Shop;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _faceId = true;

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
    final fg = _c(theme.onBackgroundColor);
    final accent = _c(theme.primaryColor);
    final border = _c(theme.borderColor);
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
              if (i < options.length - 1)
                Container(height: 1, color: border),
            ],
          ],
        ),
      ),
    );
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
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final tints = theme.categoryTints.map(_c).toList();
    final expense = _c(theme.colorRed);
    final income = _c(theme.colorGreen);

    final profile = (context.watch<AuthBloc>().state is AuthAuthenticated)
        ? (context.watch<AuthBloc>().state as AuthAuthenticated).profile
        : null;

    final name = profile?.displayName ?? 'Ana Ruiz';
    final email = profile?.email ?? 'ana@ruiz.es';

    final sections = <_Section>[
      _Section('Household', [
        _Tile.chevron(
          icon: Group(width: 16, height: 16, color: tints[0]),
          color: tints[0],
          label: 'Members',
          sub: 'Ana, Luis',
        ),
        _Tile.chevron(
          icon: Home(width: 16, height: 16, color: tints[2]),
          color: tints[2],
          label: 'Household',
          sub: 'Ruiz-Rodríguez',
        ),
        _Tile.chevron(
          icon: Mail(width: 16, height: 16, color: income),
          color: income,
          label: 'Invite member',
          sub: 'Send invite link',
        ),
      ]),
      _Section('Data management', [
        _Tile.chevron(
          icon: Cart(width: 16, height: 16, color: tints[0]),
          color: tints[0],
          label: 'Categories',
          sub: 'Expense & income',
          onTap: () => context.push(AppRoutes.categories),
        ),
        _Tile.chevron(
          icon: Shop(width: 16, height: 16, color: tints[2]),
          color: tints[2],
          label: 'Sources',
          sub: 'Merchants, employers, services',
          onTap: () => context.push(AppRoutes.transactionSources),
        ),
      ]),
      _Section('Preferences', [
        _Tile.chevron(
          icon: HalfMoon(width: 16, height: 16, color: tints[2]),
          color: tints[2],
          label: l10n.settings_appearance,
          sub: _themeLabel(prefs.themeType, l10n),
          onTap: () => _pickTheme(context, prefs, l10n),
        ),
        _Tile.swatch(
          icon: ColorPicker(width: 16, height: 16, color: tints[4]),
          color: tints[4],
          label: 'Accent color',
          swatchColor: accent,
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
      ]),
      _Section('Security', [
        _Tile.toggle(
          icon: Fingerprint(width: 16, height: 16, color: tints[5]),
          color: tints[5],
          label: 'Face ID unlock',
          value: _faceId,
          onChanged: (v) => setState(() => _faceId = v),
        ),
        _Tile.chevron(
          icon: Bell(width: 16, height: 16, color: tints[1]),
          color: tints[1],
          label: 'Notifications',
          sub: 'Push, recurring, alerts',
          onTap: () => context.push(AppRoutes.notifications),
        ),
        _Tile.chevron(
          icon: Shield(width: 16, height: 16, color: expense),
          color: expense,
          label: 'Privacy',
        ),
      ]),
      _Section('', [
        _Tile.danger(
          icon: LogOut(width: 16, height: 16, color: expense),
          color: expense,
          label: 'Sign out',
          onTap: () => context.read<AuthBloc>().add(const AuthSignOut()),
        ),
      ]),
    ];

    if (profile?.isSuperuser == true) {
      sections.insert(
        sections.length - 1,
        _Section('Admin', [
          _Tile.chevron(
            icon: UserPlus(width: 16, height: 16, color: accent),
            color: accent,
            label: 'Create user',
            sub: 'Add a new household member',
            onTap: () => showAppBottomSheet<void>(
              context: context,
              title: 'Create user',
              heightFactor: 0.7,
              child: const CreateUserForm(),
            ),
          ),
        ]),
      );
    }

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
                          color: t.danger ? expense : fg,
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
                  FSwitch(
                    value: t.value!,
                    onChange: t.onChanged!,
                  )
                else if (t.kind == _TileKind.swatch)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: t.swatchColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: t.swatchColor!,
                          spreadRadius: 1,
                          blurRadius: 0,
                        ),
                      ],
                    ),
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
            border: Border.all(color: border, width: 1),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(color: border, width: 1),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                child: Row(
                  children: [
                    MemberAvatar(name: name, color: tints[0], size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppFonts.body(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$email · Owner',
                            style:
                                AppFonts.body(fontSize: 12, color: muted),
                          ),
                        ],
                      ),
                    ),
                    ChevronIcon(color: muted),
                  ],
                ),
              ),
            ),
          ),
          for (final s in sections) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            if (s.title.isNotEmpty)
              SliverToBoxAdapter(child: SectionLabel(s.title, color: muted)),
            if (s.title.isNotEmpty)
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: sectionCard(s)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Center(
              child: Text(
                'Hestia · v1.0.0',
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

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

enum _TileKind { chevron, toggle, swatch, danger }

class _Tile {
  final Widget icon;
  final Color color;
  final String label;
  final String? sub;
  final _TileKind kind;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final Color? swatchColor;
  final VoidCallback? onTap;
  final bool danger;

  const _Tile._({
    required this.icon,
    required this.color,
    required this.label,
    this.sub,
    required this.kind,
    this.value,
    this.onChanged,
    this.swatchColor,
    this.onTap,
    this.danger = false,
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

  factory _Tile.swatch({
    required Widget icon,
    required Color color,
    required String label,
    required Color swatchColor,
  }) =>
      _Tile._(
        icon: icon,
        color: color,
        label: label,
        kind: _TileKind.swatch,
        swatchColor: swatchColor,
      );

  factory _Tile.danger({
    required Widget icon,
    required Color color,
    required String label,
    VoidCallback? onTap,
  }) =>
      _Tile._(
        icon: icon,
        color: color,
        label: label,
        kind: _TileKind.danger,
        danger: true,
        onTap: onTap,
      );
}

class _Section {
  final String title;
  final List<_Tile> tiles;
  _Section(this.title, this.tiles);
}
