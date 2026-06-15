import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show EditPencil, Trash, CartAlt;

class ShoppingListCard extends StatelessWidget {
  final ShoppingList list;
  final int itemCount;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ShoppingListCard({
    super.key,
    required this.list,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    this.itemCount = 0,
    this.onTap,
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
        if (onEdit != null)
          SwipeAction(
            color: CupertinoColors.activeBlue,
            icon:
                EditPencil(width: 18, height: 18, color: CupertinoColors.white),
            label: 'Edit',
            onTap: onEdit!,
          ),
      ],
      longPressDialogTitle: list.name,
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
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: CartAlt(width: 18, height: 18, color: accent),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      list.name,
                      style: AppFonts.body(
                          fontSize: 14, fontWeight: FontWeight.w600, color: fg),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _subtitle(),
                      style: AppFonts.body(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
              if (itemCount > 0)
                Text(
                  '$itemCount items',
                  style: AppFonts.body(fontSize: 12, color: muted),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    if (list.scope == ShoppingListScope.shared) parts.add('Shared');
    if (list.isTemplate) parts.add('Template');
    return parts.isEmpty ? 'Personal' : parts.join(' · ');
  }
}
