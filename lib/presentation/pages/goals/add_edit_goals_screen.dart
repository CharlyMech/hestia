import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/dashboard/progress_ring.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Xmark, Sparks;

class AddEditGoalScreen extends StatefulWidget {
  final String? goalId;
  const AddEditGoalScreen({super.key, this.goalId});

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  int _scope = 1; // 0=Personal 1=Household
  int _type = 0; // 0=Reach 1=Save 2=Reduce
  int _color = 0;

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final tints = theme.categoryTints.map(_c).toList();
    final expense = _c(theme.colorRed);
    final income = _c(theme.colorGreen);

    final swatches = <Color>[
      accent,
      tints[0],
      income,
      tints[1],
      tints[4],
      tints[3],
      expense,
    ];
    final selectedColor = swatches[_color];

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconBtn(
                    icon: Xmark(width: 16, height: 16, color: fg),
                    surface: surface,
                    border: border,
                    onTap: () => context.pop(),
                    size: 36,
                    radius: 10,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.goalId != null ? 'Edit goal' : 'New goal',
                        style: AppFonts.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Save',
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Preview card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(color: border, width: 1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    ProgressRing(
                      value: 0,
                      size: 48,
                      stroke: 4,
                      color: selectedColor,
                      trackColor: border,
                      child: CatTile(
                        icon:
                            Sparks(width: 14, height: 14, color: selectedColor),
                        color: selectedColor,
                        size: 24,
                        radius: 6,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summer trip · Sicily',
                            style: AppFonts.body(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '0 / 3,000€ · 0% complete',
                            style: AppFonts.body(fontSize: 11, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  FormFieldTile(
                    label: 'Name',
                    value: 'Summer trip · Sicily',
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                  ),
                  const SizedBox(height: 12),
                  _LabeledSegmented(
                    label: 'Scope',
                    options: const ['Personal', 'Household'],
                    active: _scope,
                    onChanged: (i) => setState(() => _scope = i),
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    activeColor: accent,
                    activeFg: CupertinoColors.white,
                  ),
                  const SizedBox(height: 12),
                  _LabeledSegmented(
                    label: 'Goal type',
                    options: const ['Reach target', 'Save monthly', 'Reduce spend'],
                    active: _type,
                    onChanged: (i) => setState(() => _type = i),
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FormFieldTile(
                          label: 'Target amount',
                          value: '3,000',
                          trailing: 'EUR',
                          surface: surface,
                          border: border,
                          fg: fg,
                          muted: muted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FormFieldTile(
                          label: 'Deadline',
                          value: '31 Aug 2026',
                          surface: surface,
                          border: border,
                          fg: fg,
                          muted: muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FormFieldTile(
                    label: 'Linked source',
                    value: 'Household Savings · BBVA',
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Color picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('COLOR', style: AppFonts.sectionLabel(color: muted)),
                  const SizedBox(height: 10),
                  ColorSwatchRow(
                    colors: swatches,
                    selected: _color,
                    onSelected: (i) => setState(() => _color = i),
                    bg: bg,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _LabeledSegmented extends StatelessWidget {
  final String label;
  final List<String> options;
  final int active;
  final ValueChanged<int> onChanged;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color? activeColor;
  final Color? activeFg;

  const _LabeledSegmented({
    required this.label,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: AppFonts.sectionLabel(color: muted)),
        const SizedBox(height: 6),
        SegmentedControl(
          options: options,
          active: active,
          onChanged: onChanged,
          surface: surface,
          border: border,
          fg: fg,
          muted: muted,
          activeColor: activeColor ?? const Color(0xFF1A2230),
          activeFg: activeFg,
        ),
      ],
    );
  }
}
