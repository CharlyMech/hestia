import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/presentation/blocs/calendar/calendar_bloc.dart';

class DayTransactionStrip extends StatelessWidget {
  final List<TransactionItem> transactions;
  final Color accent;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;

  const DayTransactionStrip({
    super.key,
    required this.transactions,
    required this.accent,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 1)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 6),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = transactions[i].transaction;
          final sign = t.type == TransactionType.expense ? '-' : '+';
          final label =
              '${t.note ?? t.categoryName ?? 'Recurring'} $sign${t.amount.abs().toStringAsFixed(0)}';
          return GestureDetector(
            onTap: () => context.push(AppRoutes.editTransaction, extra: t),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Text(
                label,
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: accent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
