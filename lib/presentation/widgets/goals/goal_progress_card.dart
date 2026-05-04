import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/presentation/widgets/dashboard/progress_ring.dart';

class GoalProgressCard extends StatelessWidget {
  final FinancialGoal goal;
  final Color color;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback? onTap;

  const GoalProgressCard({
    super.key,
    required this.goal,
    required this.color,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercent;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Row(
          spacing: 12,
          children: [
            ProgressRing(
              value: progress,
              size: 48,
              stroke: 5,
              color: color,
              trackColor: border,
              child: Text(
                '${(progress * 100).round()}%',
                style: AppFonts.numeric(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    goal.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  Text(
                    _amountLabel(),
                    style: AppFonts.body(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _amountLabel() {
    final cur = goal.currentAmount.toStringAsFixed(0);
    final tgt = goal.targetAmount?.toStringAsFixed(0);
    if (tgt == null) return '$cur ${goal.currency}';
    return '$cur / $tgt ${goal.currency}';
  }
}
