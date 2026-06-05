import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/domain/entities/car.dart';
import 'package:hestia/presentation/widgets/common/pressable_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show EditPencil, Trash, NavArrowRight;

class CarCard extends StatelessWidget {
  final Car car;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color accent;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CarCard({
    super.key,
    required this.car,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.accent,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      surface: surface,
      border: border,
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      actions: [
        if (onEdit != null)
          CardAction(
            icon: EditPencil(
                width: 16, height: 16, color: CupertinoColors.activeBlue),
            label: 'Edit',
            color: CupertinoColors.activeBlue,
            onTap: onEdit!,
          ),
        if (onDelete != null)
          CardAction(
            icon: Trash(
                width: 16, height: 16, color: CupertinoColors.destructiveRed),
            label: 'Delete',
            color: CupertinoColors.destructiveRed,
            onTap: onDelete!,
          ),
        if (onTap != null)
          CardAction(
            icon: NavArrowRight(width: 16, height: 16, color: accent),
            label: 'Details',
            color: accent,
            onTap: onTap!,
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                car.name.substring(0, 1).toUpperCase(),
                style: AppFonts.heading(
                    fontSize: 18, fontWeight: FontWeight.w700, color: accent),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(car.name,
                      style: AppFonts.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fg)),
                  Text(
                    _subtitle(),
                    style: AppFonts.body(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
            if (car.currentOdometerKm != null)
              Text(
                '${car.currentOdometerKm!.toStringAsFixed(0)} km',
                style: AppFonts.numeric(
                    fontSize: 12, fontWeight: FontWeight.w600, color: muted),
              ),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    if (car.make != null) parts.add(car.make!);
    if (car.model != null) parts.add(car.model!);
    if (car.year != null) parts.add('${car.year}');
    return parts.join(' · ');
  }
}
