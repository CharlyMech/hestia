import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/presentation/widgets/common/pressable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show EditPencil, Trash, HomeSimpleDoor, NavArrowRight;

/// Data model placeholder until Home entity is implemented (step 9).
class HomeData {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? description;

  const HomeData({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
  });
}

class HomeCard extends StatelessWidget {
  final HomeData home;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HomeCard({
    super.key,
    required this.home,
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
            label: 'Delete',
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
            // Mini map placeholder — replaced with GemMap in step 9.
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: accent.withValues(alpha: 0.25), width: 0.8),
              ),
              alignment: Alignment.center,
              child: HomeSimpleDoor(width: 24, height: 24, color: accent),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    home.name,
                    style: AppFonts.body(
                        fontSize: 15, fontWeight: FontWeight.w600, color: fg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    home.address,
                    style: AppFonts.body(fontSize: 12, color: muted),
                    maxLines: 2,
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
}
