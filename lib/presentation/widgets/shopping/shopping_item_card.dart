import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Check, Trash, EditPencil;

class ShoppingItemCard extends StatelessWidget {
  final ShoppingListItem item;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SwipeableCard(
      leftActions: [
        if (onDelete != null)
          SwipeAction(
            color: CupertinoColors.destructiveRed,
            icon: Trash(width: 18, height: 18, color: CupertinoColors.white),
            label: 'Delete',
            onTap: onDelete!,
          ),
      ],
      rightActions: [
        if (onToggle != null)
          SwipeAction(
            color: CupertinoColors.activeGreen,
            icon: Check(width: 18, height: 18, color: CupertinoColors.white),
            label: item.isChecked ? 'Uncheck' : 'Check',
            onTap: onToggle!,
          ),
      ],
      longPressDialogTitle: item.name,
      longPressDialogActions: [
        if (onEdit != null)
          SwipeAction(
            color: CupertinoColors.activeBlue,
            icon: EditPencil(
                width: 18, height: 18, color: CupertinoColors.activeBlue),
            label: 'Edit',
            onTap: onEdit!,
          ),
        if (onDelete != null)
          SwipeAction(
            color: CupertinoColors.destructiveRed,
            icon: Trash(
                width: 18, height: 18, color: CupertinoColors.destructiveRed),
            label: 'Delete',
            onTap: onDelete!,
          ),
      ],
      child: Container(
        color: surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          spacing: 12,
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item.isChecked ? accent : CupertinoColors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: item.isChecked ? accent : border,
                    width: 1.5,
                  ),
                ),
                child: item.isChecked
                    ? Check(
                        width: 14,
                        height: 14,
                        color: CupertinoColors.white,
                      )
                    : null,
              ),
            ),
            Expanded(
              child: Text(
                item.name,
                style: AppFonts.body(
                  fontSize: 14,
                  color: item.isChecked ? muted : fg,
                  fontWeight: FontWeight.w500,
                ).copyWith(
                  decoration:
                      item.isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: muted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (item.qty > 1)
              Text(
                'x${item.qty}',
                style: AppFonts.body(fontSize: 13, color: muted),
              ),
          ],
        ),
      ),
    );
  }
}
