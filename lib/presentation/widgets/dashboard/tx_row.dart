import 'package:flutter/widgets.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/dashboard/scope_pill.dart';

class TxData {
  final Widget icon;
  final Color color;
  final String title;
  final String category;
  final String source;
  final double amount;
  final bool shared;

  const TxData({
    required this.icon,
    required this.color,
    required this.title,
    required this.category,
    required this.source,
    required this.amount,
    this.shared = false,
  });
}

class TxRow extends StatelessWidget {
  final TxData tx;
  final bool showDivider;

  const TxRow({super.key, required this.tx, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final isIncome = tx.amount >= 0;
    final amountColor = isIncome ? _c(theme.colorGreen) : _c(theme.colorRed);
    final prefix = isIncome ? '+' : '−';
    final abs = tx.amount.abs().toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: border, width: 1))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tx.color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: tx.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        tx.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: fg,
                        ),
                      ),
                    ),
                    if (tx.shared) ...[
                      const SizedBox(width: 6),
                      const ScopePill(kind: ScopeKind.shared),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.category} · ${tx.source}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$prefix$abs €',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amountColor,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
