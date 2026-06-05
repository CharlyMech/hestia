import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/fuel_entry.dart';
import 'package:hestia/presentation/widgets/common/swipeable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show EditPencil, Trash, GasTank;

class FuelEntryCard extends StatelessWidget {
  final FuelEntry entry;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FuelEntryCard({
    super.key,
    required this.entry,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
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
              child: GasTank(width: 18, height: 18, color: accent),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    '${entry.liters.toStringAsFixed(2)} L'
                    '${entry.isFullTank ? ' · Full' : ''}',
                    style: AppFonts.body(
                        fontSize: 14, fontWeight: FontWeight.w600, color: fg),
                  ),
                  Text(
                    '${entry.odometerKm.toStringAsFixed(0)} km'
                    ' · ${entry.pricePerLiter.toStringAsFixed(3)} /L',
                    style: AppFonts.body(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 2,
              children: [
                Text(
                  entry.totalAmount.toStringAsFixed(2),
                  style: AppFonts.numeric(
                      fontSize: 14, fontWeight: FontWeight.w600, color: fg),
                ),
                Text(
                  _fmtDate(entry.filledAt),
                  style: AppFonts.body(fontSize: 11, color: muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
