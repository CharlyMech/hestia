import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/dashboard/category_donut.dart';
import 'package:hestia/presentation/widgets/dashboard/floating_nav_bar.dart';
import 'package:hestia/presentation/widgets/dashboard/progress_ring.dart';
import 'package:hestia/presentation/widgets/dashboard/scope_pill.dart';
import 'package:hestia/presentation/widgets/dashboard/sparkline.dart';
import 'package:hestia/presentation/widgets/dashboard/tx_row.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show ArrowUp, ArrowUpRight, ArrowDownLeft, Bell, Cart, Cutlery, GraphUp, Tools;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final income = _c(theme.colorGreen);
    final expense = _c(theme.colorRed);
    final tints = theme.categoryTints.map(_c).toList();

    final donutSegs = [
      DonutSegment(value: 38, color: tints[0]),
      DonutSegment(value: 24, color: tints[1]),
      DonutSegment(value: 18, color: tints[2]),
      DonutSegment(value: 12, color: tints[3]),
      DonutSegment(value: 8, color: tints[4]),
    ];

    final legend = [
      _LegendItem('Groceries', tints[0], 700),
      _LegendItem('Dining', tints[1], 442),
      _LegendItem('Utilities', tints[2], 332),
      _LegendItem('Transport', tints[3], 221),
    ];

    final goals = [
      _Goal('Summer trip', 0.62, '1,860/3,000€', accent),
      _Goal('Emergency', 0.34, '3,400/10,000€', tints[0]),
      _Goal('New laptop', 0.78, '1,560/2,000€', income),
    ];

    final txs = [
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
    ];

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                _Header(
                  fg: fg,
                  muted: muted,
                  surface: surface,
                  border: border,
                  accent: accent,
                ),
                const SizedBox(height: 20),
                _BalanceCard(
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  income: income,
                  expense: expense,
                  accent: accent,
                  incomeSoft: _c(theme.incomeSoft),
                  expenseSoft: _c(theme.expenseSoft),
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Spending · April', action: 'View all', muted: muted, accent: accent),
                const SizedBox(height: 12),
                _DonutCard(
                  surface: surface,
                  border: border,
                  fg: fg,
                  muted: muted,
                  trackColor: border,
                  segments: donutSegs,
                  legend: legend,
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Active goals', action: 'See all', muted: muted, accent: accent),
                const SizedBox(height: 12),
                _GoalsRow(goals: goals, surface: surface, border: border, fg: fg, muted: muted, trackColor: border),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Recent', muted: muted, accent: accent),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: border, width: 1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < txs.length; i++)
                        TxRow(tx: txs[i], showDivider: i < txs.length - 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: FloatingNavBar(
                active: NavTab.home,
                onPlus: () => context.push(AppRoutes.addTransaction),
                onTab: (tab) {
                  switch (tab) {
                    case NavTab.activity:
                      context.push(AppRoutes.transactions);
                    case NavTab.goals:
                      context.push(AppRoutes.goals);
                    case NavTab.more:
                      context.push(AppRoutes.settings);
                    case NavTab.home:
                      break;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Header extends StatelessWidget {
  final Color fg;
  final Color muted;
  final Color surface;
  final Color border;
  final Color accent;

  const _Header({
    required this.fg,
    required this.muted,
    required this.surface,
    required this.border,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, Ana',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: muted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Overview',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(color: border, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Bell(width: 18, height: 18, color: fg),
                ),
              ),
              Positioned(
                top: 6,
                right: 7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF8B7AE6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'AR',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color income;
  final Color expense;
  final Color accent;
  final Color incomeSoft;
  final Color expenseSoft;

  const _BalanceCard({
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.income,
    required this.expense,
    required this.accent,
    required this.incomeSoft,
    required this.expenseSoft,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL BALANCE · APRIL',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: muted,
                    letterSpacing: 0.6,
                  ),
                ),
                const ScopePill(kind: ScopeKind.shared, label: 'Household'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '8,427',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          letterSpacing: -1.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      TextSpan(
                        text: '.60',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: fg.withValues(alpha: 0.5),
                          letterSpacing: -0.6,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '€',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                ArrowUp(width: 13, height: 13, color: income),
                const SizedBox(width: 4),
                Text(
                  '+2.4%',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: income,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'vs last month',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: muted),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Sparkline(color: accent, height: 56),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _InOutTile(
                    isIncome: true,
                    color: income,
                    soft: incomeSoft,
                    fg: fg,
                    label: 'IN',
                    value: '3,120.00€',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InOutTile(
                    isIncome: false,
                    color: expense,
                    soft: expenseSoft,
                    fg: fg,
                    label: 'OUT',
                    value: '1,842.30€',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InOutTile extends StatelessWidget {
  final bool isIncome;
  final Color color;
  final Color soft;
  final Color fg;
  final String label;
  final String value;

  const _InOutTile({
    required this.isIncome,
    required this.color,
    required this.soft,
    required this.fg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: soft,
        border: Border.all(color: color.withValues(alpha: 0.13), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              isIncome
                  ? ArrowDownLeft(width: 13, height: 13, color: color)
                  : ArrowUpRight(width: 13, height: 13, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: fg,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final String? action;
  final Color muted;
  final Color accent;

  const _SectionLabel({
    required this.label,
    this.action,
    required this.muted,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: muted,
                letterSpacing: 1.0,
              ),
            ),
          ),
          if (action != null)
            Text(
              action!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: accent,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendItem {
  final String name;
  final Color color;
  final int value;
  const _LegendItem(this.name, this.color, this.value);
}

class _DonutCard extends StatelessWidget {
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color trackColor;
  final List<DonutSegment> segments;
  final List<_LegendItem> legend;

  const _DonutCard({
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.trackColor,
    required this.segments,
    required this.legend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            Stack(
              alignment: Alignment.center,
              children: [
                CategoryDonut(
                  segments: segments,
                  size: 96,
                  stroke: 12,
                  trackColor: trackColor,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SPENT',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: muted,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      '1,842€',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: fg,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < legend.length; i++) ...[
                    _LegendRow(item: legend[i], fg: fg, muted: muted),
                    if (i < legend.length - 1) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final _LegendItem item;
  final Color fg;
  final Color muted;

  const _LegendRow({required this.item, required this.fg, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.name,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: fg),
          ),
        ),
        Text(
          '${item.value}€',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: muted,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _Goal {
  final String title;
  final double value;
  final String amount;
  final Color color;
  const _Goal(this.title, this.value, this.amount, this.color);
}

class _GoalsRow extends StatelessWidget {
  final List<_Goal> goals;
  final Color surface;
  final Color border;
  final Color fg;
  final Color muted;
  final Color trackColor;

  const _GoalsRow({
    required this.goals,
    required this.surface,
    required this.border,
    required this.fg,
    required this.muted,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (_, i) {
          final g = goals[i];
          return Container(
            width: 168,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              border: Border.all(color: border, width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProgressRing(
                  value: g.value,
                  size: 44,
                  stroke: 4,
                  color: g.color,
                  trackColor: trackColor,
                  child: Text(
                    '${(g.value * 100).round()}%',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: fg,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  g.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  g.amount,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: muted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: goals.length,
      ),
    );
  }
}
