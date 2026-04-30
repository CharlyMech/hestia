import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/money_source.dart';

class MoneySourcePicker extends StatelessWidget {
  final List<MoneySource> sources;
  final String? selectedId;
  final String? excludeId;
  final ValueChanged<MoneySource> onSelected;

  const MoneySourcePicker({
    super.key,
    required this.sources,
    required this.onSelected,
    this.selectedId,
    this.excludeId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final border = _c(theme.borderColor);

    final visible = sources.where((s) => s.id != excludeId).toList();

    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No money sources available',
          style: AppFonts.body(fontSize: 14, color: muted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shrinkWrap: true,
      itemCount: visible.length,
      separatorBuilder: (_, __) => Container(height: 0.5, color: border),
      itemBuilder: (context, i) {
        final s = visible[i];
        final selected = s.id == selectedId;
        return CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          onPressed: () {
            onSelected(s);
            Navigator.of(context).pop();
          },
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Balance ${s.currentBalance.toStringAsFixed(2)} ${s.currency}',
                      style: AppFonts.body(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(CupertinoIcons.check_mark, size: 18, color: accent),
            ],
          ),
        );
      },
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}
