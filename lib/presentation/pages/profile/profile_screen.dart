import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/member_avatar.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/profile/edit_profile_form.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show LogOut;

/// Unified profile screen for the signed-in user.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openEdit(BuildContext context, Profile profile, List<Color> tints) {
    showAppBottomSheet<void>(
      context: context,
      title: 'Edit profile',
      heightFactor: 0.92,
      child: EditProfileForm(profile: profile, tints: tints),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final tints = theme.categoryTints.map(_c).toList();
    final expense = _c(theme.colorRed);

    final state = context.watch<AuthBloc>().state;
    final profile = state is AuthAuthenticated ? state.profile : null;

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: surface,
      foregroundColor: fg,
      titleText: 'Profile',
      trailing: profile == null
          ? null
          : GestureDetector(
              onTap: () => _openEdit(context, profile, tints),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  l10n.profile_edit,
                  style: AppFonts.body(
                    fontSize: 13,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
      child: ScreenShell(
        bg: bg,
        bottomPadding: 24,
        slivers: [
          if (profile == null)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'Sign in to view profile',
                  style: AppFonts.body(fontSize: 14, color: muted),
                ),
              ),
            )
          else ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    MemberAvatar(
                      name: profile.displayName ?? profile.email,
                      color: profile.calendarColor != null
                          ? _c(profile.calendarColor!)
                          : tints[0],
                      size: 96,
                      imageUrl: profile.avatarUrl,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profile.displayName ?? profile.email,
                      textAlign: TextAlign.center,
                      style: AppFonts.heading(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(fontSize: 13, color: muted),
                    ),
                    const SizedBox(height: 10),
                    _RoleBadge(
                      isSuperuser: profile.isSuperuser,
                      accent: accent,
                      muted: muted,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(child: SectionLabel('Details', color: muted)),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: _MetaCard(
                surface: surface,
                fg: fg,
                muted: muted,
                items: [
                  (
                    'Birth date',
                    profile.birthDate != null
                        ? _fmtDate(profile.birthDate!)
                        : '—'
                  ),
                  ('Currency', profile.preferredCurrency),
                  ('Member since', _fmtMonthYear(profile.createdAt)),
                  ('Last update', _fmtDate(profile.lastUpdate)),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      context.read<AuthBloc>().add(const AuthSignOut()),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        CatTile(
                          icon: LogOut(width: 16, height: 16, color: expense),
                          color: expense,
                          size: 34,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sign out',
                          style: AppFonts.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _fmtMonthYear(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isSuperuser;
  final Color accent;
  final Color muted;
  const _RoleBadge({
    required this.isSuperuser,
    required this.accent,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    final c = isSuperuser ? accent : muted;
    final label = isSuperuser ? 'SUPERUSER' : 'MEMBER';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppFonts.label(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: c,
        ),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final Color surface;
  final Color fg;
  final Color muted;
  final List<(String, String)> items;
  const _MetaCard({
    required this.surface,
    required this.fg,
    required this.muted,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      items[i].$1,
                      style: AppFonts.body(fontSize: 13, color: muted),
                    ),
                  ),
                  Text(
                    items[i].$2,
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: muted.withValues(alpha: 0.12),
              ),
          ],
        ],
      ),
    );
  }
}
