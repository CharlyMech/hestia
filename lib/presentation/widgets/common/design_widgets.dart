// Shared atoms used across all screens: section labels, cat tiles,
// segmented controls, form fields, icon buttons, chevrons.
import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:iconoir_flutter/regular/nav_arrow_right.dart';

// ── Section label ──────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  final String text;
  final String? action;
  final Color color;
  final Color? actionColor;

  const SectionLabel(
    this.text, {
    super.key,
    this.action,
    required this.color,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: AppFonts.sectionLabel(color: color),
            ),
          ),
          if (action != null)
            Text(
              action!,
              style: AppFonts.label(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: actionColor,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Cat tile (icon on tinted rounded square) ───────────────────────────────

class CatTile extends StatelessWidget {
  final Widget icon;
  final Color color;
  final double size;
  final double radius;

  const CatTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 38,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(child: icon),
    );
  }
}

// ── Segmented control ──────────────────────────────────────────────────────

class SegmentedControl extends StatelessWidget {
  final List<String> options;
  final int active;
  final ValueChanged<int> onChanged;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color? activeColor; // null = surface2, non-null = solid color
  final Color? activeFg;

  const SegmentedControl({
    super.key,
    required this.options,
    required this.active,
    required this.onChanged,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    this.activeColor,
    this.activeFg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: i == active
                        ? (activeColor ?? surface.withValues(alpha: 0.0))
                        : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    options[i],
                    textAlign: TextAlign.center,
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: i == active
                          ? (activeFg ?? fg)
                          : muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Form field row ─────────────────────────────────────────────────────────

class FormFieldTile extends StatelessWidget {
  final String label;
  final String value;
  final String? trailing;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;

  const FormFieldTile({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppFonts.sectionLabel(color: muted),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: surface,
            border: Border.all(color: border, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: AppFonts.body(fontSize: 12, color: muted),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Icon button (surface bg) ───────────────────────────────────────────────

class IconBtn extends StatelessWidget {
  final Widget icon;
  final Color surface;
  final Color border;
  final VoidCallback? onTap;
  final double size;
  final double radius;

  const IconBtn({
    super.key,
    required this.icon,
    required this.surface,
    required this.border,
    this.onTap,
    this.size = 40,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

// ── Chevron right (small) ──────────────────────────────────────────────────

class ChevronIcon extends StatelessWidget {
  final Color color;
  const ChevronIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) =>
      NavArrowRight(width: 16, height: 16, color: color);
}

// ── Color swatch row ───────────────────────────────────────────────────────

class ColorSwatchRow extends StatelessWidget {
  final List<Color> colors;
  final int selected;
  final ValueChanged<int> onSelected;
  final Color bg;

  const ColorSwatchRow({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelected,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < colors.length; i++)
          GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                boxShadow: i == selected
                    ? [
                        BoxShadow(
                          color: bg,
                          spreadRadius: 2,
                          blurRadius: 0,
                        ),
                        BoxShadow(
                          color: colors[i],
                          spreadRadius: 4,
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: i == selected
                  ? const Center(
                      child: Icon(
                        CupertinoIcons.checkmark,
                        color: CupertinoColors.white,
                        size: 14,
                      ),
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
