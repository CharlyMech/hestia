import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/member_avatar.dart';

/// Tappable user-avatar that bounces on press (Apple liquid-glass physics).
///
/// Shows the user's [profile.avatarUrl] image when available; falls back to
/// initials (up to 2 chars from [profile.displayName] or [profile.email])
/// on a [profile.calendarColor] / primary-color background circle.
class UserAvatarButton extends StatelessWidget {
  final Profile profile;
  final double size;
  final VoidCallback? onTap;

  const UserAvatarButton({
    super.key,
    required this.profile,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final accent =
        Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff')));
    final avatarColor = profile.calendarColor != null
        ? Color(int.parse((profile.calendarColor!).replaceFirst('#', '0xff')))
        : accent;

    return AnimatedButton(
      onTap: onTap,
      borderRadius: AppRadii.full,
      minScale: 0.88,
      child: MemberAvatar(
        name: profile.displayName ?? profile.email,
        color: avatarColor,
        size: size,
        imageUrl: profile.avatarUrl,
      ),
    );
  }
}
