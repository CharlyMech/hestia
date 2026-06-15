import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show EditPencil, Trash, NavArrowDown, NavArrowUp;

/// Expandable appointment card. Tap to expand/collapse.
/// Swipe left → delete, swipe right → edit. Long press → FDialog.
class AppointmentCard extends StatefulWidget {
  final Appointment appointment;
  final Color color;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.color,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    return SwipeableCard(
      leftActions: [
        if (widget.onDelete != null)
          SwipeAction(
            color: CupertinoColors.destructiveRed,
            icon: Trash(width: 18, height: 18, color: CupertinoColors.white),
            label: 'Delete',
            onTap: widget.onDelete!,
          ),
      ],
      rightActions: [
        if (widget.onEdit != null)
          SwipeAction(
            color: CupertinoColors.activeBlue,
            icon:
                EditPencil(width: 18, height: 18, color: CupertinoColors.white),
            label: 'Edit',
            onTap: widget.onEdit!,
          ),
      ],
      longPressDialogTitle: a.title,
      longPressDialogActions: [
        if (widget.onTap != null)
          SwipeAction(
            color: widget.color,
            icon: NavArrowDown(width: 18, height: 18, color: widget.color),
            label: 'View details',
            onTap: widget.onTap!,
          ),
        if (widget.onEdit != null)
          SwipeAction(
            color: CupertinoColors.activeBlue,
            icon: EditPencil(
                width: 18, height: 18, color: CupertinoColors.activeBlue),
            label: 'Edit',
            onTap: widget.onEdit!,
          ),
        if (widget.onDelete != null)
          SwipeAction(
            color: CupertinoColors.destructiveRed,
            icon: Trash(
                width: 18, height: 18, color: CupertinoColors.destructiveRed),
            label: 'Delete',
            onTap: widget.onDelete!,
          ),
      ],
      child: GestureDetector(
        onTap: () {
          setState(() => _expanded = !_expanded);
          widget.onTap?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Container(
            color: widget.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        a.title,
                        style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.fg,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _fmtTime(a.startsAt),
                      style: AppFonts.body(fontSize: 12, color: widget.muted),
                    ),
                    _expanded
                        ? NavArrowUp(width: 14, height: 14, color: widget.muted)
                        : NavArrowDown(
                            width: 14, height: 14, color: widget.muted),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 8),
                  if (a.notes != null && a.notes!.isNotEmpty)
                    Text(
                      a.notes!,
                      style: AppFonts.body(fontSize: 13, color: widget.muted),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${_fmtTime(a.startsAt)} – ${_fmtTime(a.endsAt)} · ${a.category.name}',
                    style: AppFonts.body(fontSize: 12, color: widget.muted),
                  ),
                  if (a.location != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      a.location!,
                      style: AppFonts.body(fontSize: 12, color: widget.muted),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmtTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
