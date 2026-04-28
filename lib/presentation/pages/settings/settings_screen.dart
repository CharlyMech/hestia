import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/member_avatar.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/common/toggle_switch.dart';
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
        LogOut;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _faceId = true;

  @override
  Widget build(BuildContext context) {
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
      _Section('Preferences', [
        _Tile.chevron(
          icon: HalfMoon(width: 16, height: 16, color: tints[2]),
          color: tints[2],
          label: 'Appearance',
          sub: 'Dark',
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
          label: 'Currency',
          sub: 'EUR · €',
          onTap: () {},
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
                  ToggleSwitch(
                    value: t.value!,
                    onChanged: t.onChanged!,
                    activeColor: accent,
                    inactiveColor: border,
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
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < s.tiles.length; i++)
                tileWidget(s.tiles[i], last: i == s.tiles.length - 1),
            ],
          ),
        );

    return ScreenShell(
      bg: bg,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              'Settings',
              style: AppFonts.heading(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(color: border, width: 1),
                borderRadius: BorderRadius.circular(14),
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
                          style: AppFonts.body(fontSize: 12, color: muted),
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
