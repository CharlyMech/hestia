import 'package:flutter/cupertino.dart' hide Page;
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Cart, Cutlery, Tools, Car, Gift, Home, GraphUp, Page, Plus;

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _tab = 0; // 0 = Expense, 1 = Income

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final surface2 = _c(theme.surface2Color);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final income = _c(theme.colorGreen);
    final tints = theme.categoryTints.map(_c).toList();

    final expense = <_Cat>[
      _Cat('Groceries', Cart(width: 18, height: 18, color: tints[0]), tints[0],
          14, 700),
      _Cat('Dining', Cutlery(width: 18, height: 18, color: tints[1]), tints[1],
          8, 442),
      _Cat('Utilities', Tools(width: 18, height: 18, color: tints[2]),
          tints[2], 4, 332),
      _Cat('Transport', Car(width: 18, height: 18, color: tints[3]), tints[3],
          6, 221),
      _Cat('Shopping', Gift(width: 18, height: 18, color: tints[4]), tints[4],
          3, 147),
      _Cat('Home', Home(width: 18, height: 18, color: tints[5]), tints[5], 2,
          98),
    ];
    final inc = <_Cat>[
      _Cat('Salary', GraphUp(width: 18, height: 18, color: income), income, 1,
          2850),
      _Cat('Freelance', Page(width: 18, height: 18, color: tints[3]), tints[3],
          2, 420),
    ];

    final shown = _tab == 0 ? expense : inc;

    Widget row(_Cat c, {required bool last, required bool incomeRow}) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: border, width: 1)),
        ),
        child: Row(
          children: [
            CatTile(icon: c.icon, color: c.color, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: AppFonts.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${c.count} transactions · April',
                    style: AppFonts.body(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${c.total}€',
                  style: AppFonts.numeric(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: incomeRow ? income : fg,
                  ),
                ),
                const SizedBox(height: 2),
                ChevronIcon(color: muted.withValues(alpha: 0.6)),
              ],
            ),
          ],
        ),
      );
    }

    Widget card(List<_Cat> rows, {required bool incomeRow}) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: surface,
            border: Border.all(color: border, width: 1),
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                row(rows[i], last: i == rows.length - 1, incomeRow: incomeRow),
            ],
          ),
        );

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: ScreenShell(
        bg: bg,
        bottomPadding: 24,
        slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: AppFonts.heading(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Household · 8 custom',
                        style: AppFonts.body(fontSize: 13, color: muted),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Plus(
                        width: 18,
                        height: 18,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SegmentedControl(
              options: const ['Expense', 'Income'],
              active: _tab,
              onChanged: (i) => setState(() => _tab = i),
              surface: surface,
              border: border,
              fg: fg,
              muted: muted,
              activeColor: surface2,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: SectionLabel(
            _tab == 0
                ? 'Expense · ${expense.length} categories'
                : 'Income · ${inc.length} categories',
            color: muted,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(child: card(shown, incomeRow: _tab == 1)),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Cat {
  final String name;
  final Widget icon;
  final Color color;
  final int count;
  final num total;
  const _Cat(this.name, this.icon, this.color, this.count, this.total);
}
