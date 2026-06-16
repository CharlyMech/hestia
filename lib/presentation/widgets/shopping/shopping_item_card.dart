import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/shopping_list_item.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Check, Trash;

/// Swipeable shopping-list item row.
///
/// - Swipe RIGHT → toggle picked-up ([onToggle]).
/// - Swipe LEFT  → delete, no confirm ([onDelete]).
/// - Tap         → toggle picked-up.
/// - Left  [FCheckbox] toggles picked-up; right delete button.
/// - Right numeric [FTextField] edits quantity ([onQtyChanged]).
class ShoppingItemCard extends StatefulWidget {
  final ShoppingListItem item;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color accent;
  final Color red;

  /// When true the row is read-only (immutable session in history).
  final bool disabled;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final ValueChanged<int>? onQtyChanged;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.red,
    this.disabled = false,
    this.onToggle,
    this.onDelete,
    this.onQtyChanged,
  });

  @override
  State<ShoppingItemCard> createState() => _ShoppingItemCardState();
}

class _ShoppingItemCardState extends State<ShoppingItemCard> {
  late final TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: '${widget.item.qty}');
  }

  @override
  void didUpdateWidget(covariant ShoppingItemCard old) {
    super.didUpdateWidget(old);
    final text = '${widget.item.qty}';
    if (old.item.qty != widget.item.qty && _qtyCtrl.text != text) {
      _qtyCtrl.text = text;
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _commitQty(String raw) {
    final parsed = int.tryParse(raw.trim());
    final qty = (parsed == null || parsed < 1) ? 1 : parsed;
    if (qty != widget.item.qty) widget.onQtyChanged?.call(qty);
    _qtyCtrl.text = '$qty';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final checked = item.isChecked;
    final l10n = AppLocalizations.of(context);

    final row = Container(
      color: widget.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        spacing: 6,
        children: [
          FCheckbox(
            value: checked,
            onChange: widget.disabled ? null : (_) => widget.onToggle?.call(),
          ),
          Expanded(
            child: GestureDetector(
              onTap: widget.disabled ? null : widget.onToggle,
              behavior: HitTestBehavior.opaque,
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  fontSize: 14,
                  color: checked ? widget.muted : widget.fg,
                  fontWeight: FontWeight.w500,
                ).copyWith(
                  decoration: checked ? TextDecoration.lineThrough : null,
                  decorationColor: widget.muted,
                ),
              ),
            ),
          ),
          if (!widget.disabled) ...[
            SizedBox(
              width: 40,
              child: FTextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                textCapitalization: TextCapitalization.none,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                hint: '0',
                onEditingComplete: () => _commitQty(_qtyCtrl.text),
                onSubmit: _commitQty,
              ),
            ),
            GestureDetector(
              onTap: widget.onDelete,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Trash(width: 16, height: 16, color: widget.muted),
              ),
            ),
          ] else if (item.qty > 1)
            Text(
              'x${item.qty}',
              style: AppFonts.body(fontSize: 13, color: widget.muted),
            ),
        ],
      ),
    );

    if (widget.disabled) return row;

    return SwipeableCard(
      leftActions: [
        if (widget.onDelete != null)
          SwipeAction(
            color: widget.red,
            icon: Trash(width: 18, height: 18, color: CupertinoColors.white),
            label: l10n.common_delete,
            onTap: widget.onDelete!,
          ),
      ],
      rightActions: [
        if (widget.onToggle != null)
          SwipeAction(
            color: widget.accent,
            icon: Check(width: 18, height: 18, color: CupertinoColors.white),
            label: checked ? l10n.shopping_uncheck : l10n.shopping_check,
            onTap: widget.onToggle!,
          ),
      ],
      child: row,
    );
  }
}
