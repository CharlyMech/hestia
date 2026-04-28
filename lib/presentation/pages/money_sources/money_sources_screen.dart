import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/member_avatar.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/dashboard/scope_pill.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Bank, PiggyBank, CreditCard, Cash, Plus;

class MoneySourcesScreen extends StatelessWidget {
  const MoneySourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final expense = _c(theme.colorRed);
    final tints = theme.categoryTints.map(_c).toList();

    final shared = <_Source>[
      _Source(
        name: 'Santander Joint',
        inst: 'Santander',
        type: 'checking',
        icon: Bank(width: 20, height: 20, color: expense),
        color: expense,
        balance: 4820.40,
        members: [
          (name: 'Ana', color: tints[0]),
          (name: 'Luis', color: tints[2]),
        ],
      ),
      _Source(
        name: 'Household Savings',
        inst: 'BBVA',
        type: 'savings',
        icon: PiggyBank(width: 20, height: 20, color: tints[3]),
        color: tints[3],
        balance: 12400.00,
        members: [
          (name: 'Ana', color: tints[0]),
          (name: 'Luis', color: tints[2]),
        ],
      ),
    ];

    final personal = <_Source>[
      _Source(
        name: 'Revolut',
        inst: 'Revolut',
        type: 'checking',
        icon: CreditCard(width: 20, height: 20, color: accent),
        color: accent,
        balance: 1284.12,
        members: const [],
      ),
      _Source(
        name: 'Cash wallet',
        inst: '',
        type: 'cash',
        icon: Cash(width: 20, height: 20, color: tints[5]),
        color: tints[5],
        balance: 85.00,
        members: const [],
      ),
      _Source(
        name: 'Visa Crédit',
        inst: 'CaixaBank',
        type: 'credit',
        icon: CreditCard(width: 20, height: 20, color: tints[1]),
        color: tints[1],
        balance: -320.40,
        members: const [],
      ),
    ];

    final total =
        [...shared, ...personal].fold<double>(0, (s, x) => s + x.balance);

    Widget sharedCard(_Source s) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            border: Border.all(color: border, width: 1),
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  color: s.color.withValues(alpha: 0.6),
                ),
              ),
              Row(
                children: [
                  CatTile(icon: s.icon, color: s.color, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                s.name,
                                style: AppFonts.body(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: fg,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const ScopePill(kind: ScopeKind.shared),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${s.inst} · ${s.type}',
                          style: AppFonts.body(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _money(s.balance),
                        style: AppFonts.numeric(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AvatarStack(
                        members: s.members,
                        size: 18,
                        ringColor: surface,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

    Widget personalCard(_Source s) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            border: Border.all(color: border, width: 1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CatTile(icon: s.icon, color: s.color, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            s.name,
                            style: AppFonts.body(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const ScopePill(kind: ScopeKind.personal),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.inst.isEmpty
                          ? 'No institution · ${s.type}'
                          : '${s.inst} · ${s.type}',
                      style: AppFonts.body(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
              Text(
                _money(s.balance),
                style: AppFonts.numeric(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: s.balance < 0 ? expense : fg,
                ),
              ),
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
                        'Sources',
                        style: AppFonts.heading(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total net worth',
                        style: AppFonts.body(fontSize: 13, color: muted),
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: total.toStringAsFixed(2).replaceAllMapped(
                                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                                  (m) => '${m[1]},'),
                              style: AppFonts.numeric(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: fg,
                              ),
                            ),
                            TextSpan(
                              text: '€',
                              style: AppFonts.numeric(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.addMoneySource),
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
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: SectionLabel('Shared · household', color: muted),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: shared.length,
            itemBuilder: (_, i) => sharedCard(shared[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: SectionLabel('Personal · Ana', color: muted),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: personal.length,
            itemBuilder: (_, i) => personalCard(personal[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
          ),
        ),
        ],
      ),
    );
  }

  String _money(double v) {
    final neg = v < 0;
    final abs = v.abs();
    final whole = abs.toStringAsFixed(2);
    final formatted = whole.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');
    return '${neg ? '−' : ''}$formatted€';
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Source {
  final String name;
  final String inst;
  final String type;
  final Widget icon;
  final Color color;
  final double balance;
  final List<({String name, Color color})> members;

  const _Source({
    required this.name,
    required this.inst,
    required this.type,
    required this.icon,
    required this.color,
    required this.balance,
    required this.members,
  });
}
