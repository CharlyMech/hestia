import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/dashboard/tx_row.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Search, FilterAlt, Cart, Cutlery, GraphUp, Tools, Car, Group;

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _month = 0; // 0=April 1=March 2=Feb 3=Jan
  int _filter = 0; // 0=All 1=Shared 2=Personal 3=Income

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
    final tints = theme.categoryTints.map(_c).toList();
    final income = _c(theme.colorGreen);
    final expense = _c(theme.colorRed);

    final groups = <_Group>[
      _Group('Today · April 22', -72.70, [
        TxData(
          icon: Cart(width: 18, height: 18, color: tints[0]),
          color: tints[0],
          title: 'Mercadona',
          category: 'Groceries',
          source: 'Joint · Santander',
          amount: -48.20,
          shared: true,
        ),
        TxData(
          icon: Cutlery(width: 18, height: 18, color: tints[1]),
          color: tints[1],
          title: 'Pizza di Napoli',
          category: 'Dining',
          source: 'Ana · Revolut',
          amount: -24.50,
        ),
      ]),
      _Group('Yesterday · April 21', 2787.86, [
        TxData(
          icon: GraphUp(width: 18, height: 18, color: income),
          color: income,
          title: 'Salary — Acme Co.',
          category: 'Income',
          source: 'Ana · BBVA',
          amount: 2850.00,
        ),
        TxData(
          icon: Tools(width: 18, height: 18, color: tints[1]),
          color: tints[1],
          title: 'Iberdrola',
          category: 'Utilities',
          source: 'Joint · Santander',
          amount: -62.14,
          shared: true,
        ),
      ]),
      _Group('April 19', -145.30, [
        TxData(
          icon: Car(width: 18, height: 18, color: tints[2]),
          color: tints[2],
          title: 'Repsol Gasolinera',
          category: 'Transport',
          source: 'Joint · Santander',
          amount: -45.30,
          shared: true,
        ),
        TxData(
          icon: Cart(width: 18, height: 18, color: tints[0]),
          color: tints[0],
          title: 'Lidl',
          category: 'Groceries',
          source: 'Joint · Santander',
          amount: -100.00,
          shared: true,
        ),
      ]),
    ];

    Widget monthChip(String label, int idx) {
      final active = _month == idx;
      return GestureDetector(
        onTap: () => setState(() => _month = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? accent : surface,
            border: active ? null : Border.all(color: border, width: 1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? CupertinoColors.white : muted,
            ),
          ),
        ),
      );
    }

    Widget filterPill(String label, int idx, {Widget? leading}) {
      final active = _filter == idx;
      return GestureDetector(
        onTap: () => setState(() => _filter = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? surface2 : const Color(0x00000000),
            border: Border.all(
              color: active ? muted.withValues(alpha: 0.4) : border,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: active ? fg : muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget groupSection(_Group g, {required bool first}) {
      final positive = g.total >= 0;
      return Padding(
        padding: EdgeInsets.only(top: first ? 0 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      g.date,
                      style: AppFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: muted,
                      ),
                    ),
                  ),
                  Text(
                    '${positive ? '+' : '−'}${g.total.abs().toStringAsFixed(2)} €',
                    style: AppFonts.numeric(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: positive ? income : expense,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(color: border, width: 1),
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < g.items.length; i++)
                    TxRow(tx: g.items[i], showDivider: i < g.items.length - 1),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: 'Activity',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconBtn(
            icon: Search(width: 18, height: 18, color: fg),
            surface: surface,
            border: border,
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconBtn(
                icon: FilterAlt(width: 18, height: 18, color: fg),
                surface: surface,
                border: border,
              ),
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      child: ScreenShell(
        bg: bg,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                monthChip('April', 0),
                const SizedBox(width: 8),
                monthChip('March', 1),
                const SizedBox(width: 8),
                monthChip('Feb', 2),
                const SizedBox(width: 8),
                monthChip('Jan', 3),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                filterPill('All', 0),
                const SizedBox(width: 6),
                filterPill(
                  'Shared',
                  1,
                  leading: Group(
                    width: 12,
                    height: 12,
                    color: _filter == 1 ? fg : muted,
                  ),
                ),
                const SizedBox(width: 6),
                filterPill('Personal', 2),
                const SizedBox(width: 6),
                filterPill('Income', 3),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        SliverList.builder(
          itemCount: groups.length,
          itemBuilder: (_, i) =>
              groupSection(groups[i], first: i == 0),
        ),
      ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Group {
  final String date;
  final double total;
  final List<TxData> items;
  const _Group(this.date, this.total, this.items);
}
