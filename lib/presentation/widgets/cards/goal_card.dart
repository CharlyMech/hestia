import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/financial_goal.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:hestia/presentation/widgets/common/animated_progress_bar.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show EditPencil, Trash;

class GoalCard extends StatelessWidget {
  final FinancialGoal goal;
  final Color color;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
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
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: AppFonts.body(
                          fontSize: 14, fontWeight: FontWeight.w600, color: fg),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (goal.hasTarget)
                    Text(
                      '${(goal.progressPercent * 100).toStringAsFixed(0)}%',
                      style: AppFonts.numeric(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color),
                    ),
                ],
              ),
              if (goal.hasTarget) ...[
                AnimatedProgressBar(
                  value: goal.progressPercent,
                  fillColor: color,
                  trackColor: color.withValues(alpha: 0.15),
                  height: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                Text(
                  '${goal.currentAmount.toStringAsFixed(0)}'
                  ' / ${goal.targetAmount!.toStringAsFixed(0)}',
                  style: AppFonts.body(fontSize: 12, color: muted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
