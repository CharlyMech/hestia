import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/presentation/widgets/common/bottom_sheet.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/sliver_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/profile/edit_profile_form.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show EditPencil, LogOut, Trash;
import 'package:intl/intl.dart';

/// Unified profile screen for the signed-in user.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _onRefresh() async {
    context.read<AuthBloc>().add(const AuthCheckSession());
    // Wait briefly so the refresh indicator has time to show.
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  void _confirmDelete(BuildContext context, Profile profile) {
    final l10n = AppLocalizations.of(context);
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(l10n.profile_deleteAccountTitle),
        content: Text(l10n.profile_deleteAccountConfirm),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await AppDependencies.instance.authRepository
                  .updateProfile(profile.copyWith(isActive: false));
              if (context.mounted) {
                context.read<AuthBloc>().add(const AuthSignOut());
              }
            },
            child: Text(l10n.common_delete),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context, Profile profile, List<Color> tints) {
    showAppBottomSheet<void>(
      context: context,
      title: AppLocalizations.of(context).profile_editProfile,
      heightFactor: 0.92,
      child: EditProfileForm(profile: profile, tints: tints),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final tints = theme.categoryTints.map(hexToColor).toList();
    final logoutBg = hexToColor(theme.colorRed);
    final logoutFg = hexToColor(theme.onDestructiveColor);

    final state = context.watch<AuthBloc>().state;
    final isLoading = state is AuthLoading;
    final profile = state is AuthAuthenticated ? state.profile : null;

    return SliverPushedRouteShell(
      title: profile?.displayName ?? profile?.email ?? '',
      isActive: profile?.isActive,
      onRefresh: _onRefresh,
      header: profile == null
          ? null
          : _ProfileHeader(
              name: profile.displayName ?? profile.email,
              color: profile.calendarColor != null
                  ? hexToColor(profile.calendarColor!)
                  : tints[0],
              imageUrl: profile.avatarUrl),
      actions: profile == null
          ? null
          : [
              AppMenuAction(
                icon: EditPencil(width: 18, height: 18, color: accent),
                label: l10n.profile_edit,
                onTap: () => _openEdit(context, profile, tints),
              ),
              AppMenuAction.toggleActive(
                isActive: profile.isActive,
                setActiveLabel: l10n.profile_setActive,
                setInactiveLabel: l10n.profile_setInactive,
                fg: fg,
                onTap: () => context.read<AuthBloc>().add(
                      AuthUpdateProfile(
                        profile.copyWith(isActive: !profile.isActive),
                      ),
                    ),
              ),
              AppMenuAction(
                icon: Trash(
                    width: 18,
                    height: 18,
                    color: CupertinoColors.destructiveRed),
                label: l10n.profile_deleteAccountTitle,
                isDestructive: true,
                onTap: () => _confirmDelete(context, profile),
              ),
            ],
      content: !isLoading && profile == null
          ? Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(l10n.profile_signInPrompt,
                    style: AppFonts.body(fontSize: 14, color: muted)),
              ),
            )
          : Skeletonizer(
              enabled: isLoading,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                child: isLoading
                    ? _ProfileSkeleton(surface: surface)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 24,
                        children: [
                          Center(
                            child: _RoleBadge(
                              isSuperuser: profile!.isSuperuser,
                              accent: accent,
                              muted: muted,
                              l10n: l10n,
                            ),
                          ),
                          SectionLabel(l10n.profile_detailsSection,
                              color: muted),
                          _MetaCard(
                            surface: surface,
                            fg: fg,
                            muted: muted,
                            items: [
                              (
                                l10n.profile_birthDate,
                                profile.birthDate != null
                                    ? _fmtDate(
                                        profile.birthDate!,
                                        Localizations.localeOf(context)
                                            .toString(),
                                      )
                                    : '—'
                              ),
                              (
                                l10n.profile_preferredCurrency,
                                profile.preferredCurrency
                              ),
                              (
                                l10n.profile_memberSince,
                                _fmtMonthYear(
                                  profile.createdAt,
                                  Localizations.localeOf(context).toString(),
                                ),
                              ),
                              (
                                l10n.profile_lastUpdate,
                                _fmtDate(
                                  profile.lastUpdate,
                                  Localizations.localeOf(context).toString(),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: logoutBg.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => context
                                  .read<AuthBloc>()
                                  .add(const AuthSignOut()),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 12,
                                  children: [
                                    Text(l10n.common_signOut,
                                        style: AppFonts.body(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: logoutFg)),
                                    LogOut(
                                        width: 20, height: 20, color: logoutFg),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
    );
  }

  String _fmtDate(DateTime d, String locale) =>
      DateFormat.yMMMd(locale).format(d);

  String _fmtMonthYear(DateTime d, String locale) =>
      DateFormat.yMMMM(locale).format(d);
}

class _RoleBadge extends StatelessWidget {
  final bool isSuperuser;
  final Color accent;
  final Color muted;
  final AppLocalizations l10n;
  const _RoleBadge({
    required this.isSuperuser,
    required this.accent,
    required this.muted,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final c = isSuperuser ? accent : muted;
    final label =
        isSuperuser ? l10n.profile_roleSuperuser : l10n.profile_roleMember;
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

// Full-bleed header: photo if available, else colour + initials centred.
class _ProfileHeader extends StatelessWidget {
  final String name;
  final Color color;
  final String? imageUrl;

  const _ProfileHeader({
    required this.name,
    required this.color,
    this.imageUrl,
  });

  bool get _hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get _isRemote =>
      _hasImage &&
      (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasImage) {
      return _isRemote
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => ColoredBox(color: color),
              errorWidget: (_, __, ___) => _fallback(),
            )
          : Image.file(
              File(imageUrl!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => _fallback(),
            );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        color: color,
        alignment: Alignment.center,
        child: Text(
          _initials,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 64,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
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
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

class _ProfileSkeleton extends StatelessWidget {
  final Color surface;
  const _ProfileSkeleton({required this.surface});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role badge
        Center(
          child: Container(
            height: 22,
            width: 80,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Section label
        Container(
          height: 13,
          width: 60,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 10),
        // Meta card
        Container(
          height: 192,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
        ),
        const SizedBox(height: 24),
        // Sign-out row
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
        ),
      ],
    );
  }
}
