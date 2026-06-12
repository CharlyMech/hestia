import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show EditPencil, Trash;

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String? accountName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color income;
  final Color expense;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.income,
    required this.expense,
    this.accountName,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExp = transaction.isExpense;
    final amountColor = isExp ? expense : income;
    final sign = isExp ? '-' : '+';
    final amount = '$sign${transaction.amount.abs().toStringAsFixed(2)}';

    final categoryColor = transaction.categoryColor != null
        ? hexToColor(transaction.categoryColor!)
        : muted;

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
      longPressDialogTitle: transaction.note ?? 'Transaction',
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
                  color: categoryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  transaction.categoryName?.substring(0, 1).toUpperCase() ??
                      '?',
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      transaction.note ??
                          transaction.categoryName ??
                          'Transaction',
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: fg,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      accountName ??
                          transaction.bankAccountName ??
                          transaction.categoryName ??
                          '',
                      style: AppFonts.body(fontSize: 12, color: muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2,
                children: [
                  Text(
                    amount,
                    style: AppFonts.numeric(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: amountColor,
                    ),
                  ),
                  Text(
                    _fmtDate(transaction.date),
                    style: AppFonts.body(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    return '${d.day}/${d.month}';
  }
}
