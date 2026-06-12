import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/profile.dart';
import 'package:hestia/presentation/widgets/common/pressable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show EditPencil, Trash, NavArrowRight;

class PersonCard extends StatelessWidget {
  final Profile profile;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PersonCard({
    super.key,
    required this.profile,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName ?? profile.email;
    final initials = _initials(name);
    final avatarColor = profile.calendarColor != null
        ? hexToColor(profile.calendarColor!)
        : accent;

    return PressableCard(
      surface: surface,
      border: border,
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      actions: [
        if (onEdit != null)
          CardAction(
            icon: EditPencil(
                width: 16, height: 16, color: CupertinoColors.activeBlue),
            label: 'Edit',
            color: CupertinoColors.activeBlue,
            onTap: onEdit!,
          ),
        if (onDelete != null)
          CardAction(
            icon: Trash(
                width: 16, height: 16, color: CupertinoColors.destructiveRed),
            label: 'Remove',
            color: CupertinoColors.destructiveRed,
            onTap: onDelete!,
          ),
        if (onTap != null)
          CardAction(
            icon: NavArrowRight(width: 16, height: 16, color: accent),
            label: 'Details',
            color: accent,
            onTap: onTap!,
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Row(
          spacing: 12,
          children: [
            _avatar(avatarColor, initials),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    name,
                    style: AppFonts.body(
                        fontSize: 15, fontWeight: FontWeight.w600, color: fg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    profile.email,
                    style: AppFonts.body(fontSize: 12, color: muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(Color color, String initials) {
    Widget letter() => Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: AppFonts.heading(
                fontSize: 16, fontWeight: FontWeight.w700, color: color),
          ),
        );

    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.network(
          profile.avatarUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => letter(),
        ),
      );
    }
    return letter();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
