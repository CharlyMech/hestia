import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Bank, CreditCard, Cash, PiggyBank, Wallet, NavArrowLeft;

class AddEditMoneySourceScreen extends StatefulWidget {
  final String? sourceId;
  const AddEditMoneySourceScreen({super.key, this.sourceId});

  @override
  State<AddEditMoneySourceScreen> createState() =>
      _AddEditMoneySourceScreenState();
}

class _AddEditMoneySourceScreenState extends State<AddEditMoneySourceScreen> {
  int _typeIdx = 0;
  int _ownerIdx = 0;
  int _iconIdx = 1;
  int _colorIdx = 0;

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

    final swatches = <Color>[
      accent,
      tints[0],
      tints[3],
      tints[1],
      tints[4],
      tints[5],
      expense,
    ];

    final iconCtors = <Widget Function(Color)>[
      (c) => Bank(width: 22, height: 22, color: c),
      (c) => CreditCard(width: 22, height: 22, color: c),
      (c) => Cash(width: 22, height: 22, color: c),
      (c) => PiggyBank(width: 22, height: 22, color: c),
      (c) => Wallet(width: 22, height: 22, color: c),
    ];

    final selectedColor = swatches[_colorIdx];
    final selectedIcon = iconCtors[_iconIdx](selectedColor);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  IconBtn(
                    icon: NavArrowLeft(width: 16, height: 16, color: fg),
                    surface: surface,
                    border: border,
                    onTap: () => context.pop(),
                    size: 36,
                    radius: 10,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'New source',
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

            const SizedBox(height: 24),

            // Preview card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(color: border, width: 1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CatTile(
                      icon: selectedIcon,
                      color: selectedColor,
                      size: 48,
                      radius: 12,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Revolut',
                            style: AppFonts.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Checking · EUR',
                            style: AppFonts.body(fontSize: 12, color: muted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '0.00€',
                      style: AppFonts.numeric(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: fg,
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
                    value: 'Revolut',
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                  ),
                  const SizedBox(height: 12),
                  FormFieldTile(
                    label: 'Institution',
                    value: 'Revolut Ltd.',
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                  ),
                  const SizedBox(height: 12),
                  _LabeledSegmented(
                    label: 'Type',
                    options: const [
                      'Checking',
                      'Savings',
                      'Credit',
                      'Cash',
                      'Investment'
                    ],
                    active: _typeIdx,
                    onChanged: (i) => setState(() => _typeIdx = i),
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                  ),
                  const SizedBox(height: 12),
                  _LabeledSegmented(
                    label: 'Ownership',
                    options: const ['Personal', 'Shared'],
                    active: _ownerIdx,
                    onChanged: (i) => setState(() => _ownerIdx = i),
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                    activeColor: accent,
                    activeFg: CupertinoColors.white,
                  ),
                  const SizedBox(height: 12),
                  FormFieldTile(
                    label: 'Initial balance',
                    value: '0.00 €',
                    trailing: 'EUR',
                    surface: surface,
                    border: border,
                    fg: fg,
                    muted: muted,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Icon picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ICON', style: AppFonts.sectionLabel(color: muted)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < iconCtors.length; i++)
                        GestureDetector(
                          onTap: () => setState(() => _iconIdx = i),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: i == _iconIdx
                                  ? accent.withValues(alpha: 0.13)
                                  : surface,
                              border: Border.all(
                                color: i == _iconIdx ? accent : border,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: iconCtors[i](
                                i == _iconIdx ? accent : muted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

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
                    selected: _colorIdx,
                    onSelected: (i) => setState(() => _colorIdx = i),
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
