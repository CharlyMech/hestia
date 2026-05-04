import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/admin/create_user_form.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/member_avatar.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Bell, LogOut, Settings, Shield, Shop, Trophy, UserPlus;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

    final state = context.watch<AuthBloc>().state;
    final profile = state is AuthAuthenticated ? state.profile : null;
    final name = profile?.displayName ?? '—';
    final email = profile?.email ?? '';
    final isSuper = profile?.isSuperuser == true;
    final memberSince = profile?.createdAt;

    Widget tile({
      required Widget icon,
      required Color color,
      required String label,
      String? sub,
      VoidCallback? onTap,
      bool danger = false,
      bool showChevron = true,
    }) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              CatTile(icon: icon, color: color, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: danger ? expense : fg,
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 1),
                      Text(sub, style: AppFonts.body(fontSize: 12, color: muted)),
                    ],
                  ],
                ),
              ),
              if (showChevron && !danger) ChevronIcon(color: muted),
            ],
          ),
        ),
      );
    }

    Widget card(List<Widget> children) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: surface,
            border: Border.all(color: border, width: 1),
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Container(height: 1, color: border),
              ],
            ],
          ),
        );

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Profile',
      child: ScreenShell(
        bg: bg,
        bottomPadding: 24,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
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
                    MemberAvatar(name: name, color: tints[0], size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.body(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: fg,
                                  ),
                                ),
                              ),
                              if (isSuper) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ADMIN',
                                    style: AppFonts.label(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: AppFonts.body(fontSize: 12, color: muted),
                          ),
                          if (memberSince != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Member since ${_fmtDate(memberSince)}',
                              style:
                                  AppFonts.body(fontSize: 11, color: muted),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(child: SectionLabel('Account', color: muted)),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: card([
              tile(
                icon: Settings(width: 16, height: 16, color: tints[2]),
                color: tints[2],
                label: 'Settings',
                sub: 'Preferences, security, household',
                onTap: () => context.push(AppRoutes.settings),
              ),
              tile(
                icon: Bell(width: 16, height: 16, color: tints[1]),
                color: tints[1],
                label: 'Notifications',
                sub: 'Inbox and alerts',
                onTap: () => context.push(AppRoutes.notifications),
              ),
              tile(
                icon: Trophy(width: 16, height: 16, color: tints[3]),
                color: tints[3],
                label: 'Goals',
                sub: 'Across all accounts',
                onTap: () => context.push(AppRoutes.goals),
              ),
              tile(
                icon: Shop(width: 16, height: 16, color: tints[2]),
                color: tints[2],
                label: 'Sources',
                sub: 'Merchants, services, employers',
                onTap: () => context.push(AppRoutes.transactionSources),
              ),
              tile(
                icon: Shield(width: 16, height: 16, color: tints[5]),
                color: tints[5],
                label: 'Privacy',
                sub: 'Data, biometrics',
                onTap: () => context.push(AppRoutes.settings),
              ),
            ]),
          ),
          // Calendar color — used to tint this user's appointment blocks
          // for everyone in the household.
          if (profile != null) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
                child: SectionLabel('Calendar color', color: muted)),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: _CalendarColorPicker(
                profile: profile,
                surface: surface,
                border: border,
                muted: muted,
                fg: fg,
                tints: tints,
                accent: accent,
              ),
            ),
          ],
          if (isSuper) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(child: SectionLabel('Admin', color: muted)),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: card([
                tile(
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
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: card([
              tile(
                icon: LogOut(width: 16, height: 16, color: expense),
                color: expense,
                label: 'Sign out',
                danger: true,
                showChevron: false,
                onTap: () => context.read<AuthBloc>().add(const AuthSignOut()),
              ),
            ]),
          ),
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

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

/// Card-shaped picker that lets the signed-in user choose the color used to
/// tint their appointment blocks across the household calendar.
class _CalendarColorPicker extends StatelessWidget {
  final Profile profile;
  final Color surface;
  final Color border;
  final Color muted;
  final Color fg;
  final Color accent;
  final List<Color> tints;

  const _CalendarColorPicker({
    required this.profile,
    required this.surface,
    required this.border,
    required this.muted,
    required this.fg,
    required this.accent,
    required this.tints,
  });

  @override
  Widget build(BuildContext context) {
    final swatches = <Color>[
      accent,
      ...tints,
      const Color(0xFF22C55E),
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
    ];
    final currentIdx = () {
      if (profile.calendarColor == null) return 0;
      final hex = profile.calendarColor!.toLowerCase();
      for (var i = 0; i < swatches.length; i++) {
        final candidate =
            '#${swatches[i].toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
        if (candidate.toLowerCase() == hex) return i;
      }
      return 0;
    }();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(
              'Used to tint your appointments for everyone in the household.',
              style: AppFonts.body(fontSize: 12, color: muted),
            ),
            ColorSwatchRow(
              colors: swatches,
              selected: currentIdx,
              onSelected: (i) {
                final hex =
                    '#${swatches[i].toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
                context
                    .read<AuthBloc>()
                    .add(AuthUpdateProfile(profile.copyWith(calendarColor: hex)));
              },
              bg: surface,
            ),
          ],
        ),
      ),
    );
  }
}
