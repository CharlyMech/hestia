import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/category.dart';

class CategoryPicker extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<Category> onSelected;

  const CategoryPicker({
    super.key,
    required this.categories,
    required this.onSelected,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final border = hexToColor(theme.borderColor);

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No categories yet',
          style: AppFonts.body(fontSize: 14, color: muted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shrinkWrap: true,
      itemCount: categories.length,
      separatorBuilder: (_, __) => Container(height: 0.5, color: border),
      itemBuilder: (context, i) {
        final c = categories[i];
        final selected = c.id == selectedId;
        return AnimatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          onTap: () {
            onSelected(c);
            Navigator.of(context).pop();
          },
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: c.color != null ? hexToColor(c.color!) : muted,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  c.name,
                  style: AppFonts.body(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: fg,
                  ),
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
}
