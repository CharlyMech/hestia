import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/domain/entities/shopping_session.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Check, Trash;

/// Swipeable card for one active shopping session.
///
/// - Swipe LEFT  → finish / mark done ([onFinish]).
/// - Swipe RIGHT → delete the session ([onDelete]).
/// - Long-press   → dialog with the same two actions.
/// - Tap          → open the session detail ([onOpen]).
class ActiveShoppingSessionCard extends StatelessWidget {
  final ShoppingSession session;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final Color green;
  final Color red;
  final VoidCallback onOpen;
  final VoidCallback onFinish;
  final VoidCallback onDelete;

  const ActiveShoppingSessionCard({
    super.key,
    required this.session,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.green,
    required this.red,
    required this.onOpen,
    required this.onFinish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shared = session.scope == ShoppingListScope.shared;
    final count = session.itemCount ?? session.items?.length;
    final subtitle = [
      shared ? l10n.shopping_sharedCollaboration : l10n.shopping_scopePersonal,
      if (count != null) l10n.shopping_itemCount(count),
    ].join(' · ');

    return SwipeableCard(
      leftActions: [
        SwipeAction(
          color: green,
          icon: Check(width: 18, height: 18, color: CupertinoColors.white),
          label: l10n.shopping_markDone,
          onTap: onFinish,
        ),
      ],
      rightActions: [
        SwipeAction(
          color: red,
          icon: Trash(width: 18, height: 18, color: CupertinoColors.white),
          label: l10n.common_delete,
          onTap: onDelete,
        ),
      ],
      longPressDialogTitle: session.name,
      longPressDialogActions: [
        SwipeAction(
          color: green,
          icon: Check(width: 18, height: 18, color: green),
          label: l10n.shopping_finishSession,
          onTap: onFinish,
        ),
        SwipeAction(
          color: red,
          icon: Trash(width: 18, height: 18, color: red),
          label: l10n.common_delete,
          onTap: onDelete,
        ),
      ],
      child: GestureDetector(
        onTap: onOpen,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      session.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_forward, size: 16, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
