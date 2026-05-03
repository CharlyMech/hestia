import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/money_source.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/widgets/dashboard/scope_pill.dart';
import 'package:hestia/presentation/widgets/dashboard/tx_row.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Bell, Bank, CreditCard;

class DashboardScreen extends StatefulWidget {
  final ValueChanged<String>? onOpenMoneySource;
  const DashboardScreen({super.key, this.onOpenMoneySource});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<MoneySource> _topSources = const [];
  List<TxData> _recentTx = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final profile = authState.profile;
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(profile.id);
    if (household == null) return;

    final (sources, _) = await AppDependencies.instance.moneySourceRepository
        .getMoneySources(
      householdId: household.id,
      viewMode: ViewMode.personal,
      userId: profile.id,
    );
    final userSourceIds = sources.map((s) => s.id).toSet();

    final (transactions, _) = await AppDependencies.instance.transactionRepository
        .getTransactions(
      householdId: household.id,
      viewMode: ViewMode.household,
      userId: profile.id,
      limit: 24,
    );

    final byAccount = <String, double>{};
    for (final tx in transactions) {
      byAccount[tx.moneySourceId] = (byAccount[tx.moneySourceId] ?? 0) + tx.amount.abs();
    }

    final sorted = [...sources]..sort(
        (a, b) => (byAccount[b.id] ?? b.currentBalance).compareTo(byAccount[a.id] ?? a.currentBalance));
    final recent = transactions
        .where((tx) => userSourceIds.contains(tx.moneySourceId))
        .take(6)
        .map((tx) => _toTxData(tx, sources))
        .toList();

    if (!mounted) return;
    setState(() {
      _topSources = sorted.take(5).toList();
      _recentTx = recent;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);

    return ColoredBox(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(onRefresh: _load),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 110),
              sliver: SliverList.list(children: [
            _Header(
              fg: fg,
              muted: muted,
              surface: surface,
              border: border,
              accent: accent,
              onAvatarTap: () => context.push(AppRoutes.settings),
              onBellTap: () => context.push(AppRoutes.notifications),
            ),
            const SizedBox(height: 20),
            _SectionLabel(
              label: 'Top bank accounts',
              action: 'View all',
              muted: muted,
              accent: accent,
              onTap: () => context.push(AppRoutes.moneySources),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 126,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _topSources.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final s = _topSources[i];
                  final isShared = s.ownerType == OwnerType.shared;
                  return GestureDetector(
                    onTap: () => (widget.onOpenMoneySource ??
                            ((id) => context.push(AppRoutes.moneySourceDetail, extra: id)))
                        .call(s.id),
                    child: SizedBox(
                      width: 280,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surface,
                          border: Border.all(color: border, width: 1),
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: (s.accountType == AccountType.savings
                                        ? Bank(width: 18, height: 18, color: accent)
                                        : CreditCard(width: 18, height: 18, color: accent)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    s.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600, color: fg),
                                  ),
                                ),
                                ScopePill(kind: isShared ? ScopeKind.shared : ScopeKind.personal),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              '${s.currentBalance.toStringAsFixed(2)} ${s.currency}',
                              style: AppFonts.numeric(fontSize: 22, fontWeight: FontWeight.w700, color: fg),
                            ),
                            Text(
                              '${s.institution ?? 'No institution'} · ${s.accountType.name}',
                              style: AppFonts.body(fontSize: 12, color: muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(
              label: 'Spending · April',
              action: 'View all',
              muted: muted,
              accent: accent,
              onTap: () => context.push(AppRoutes.transactions),
            ),
            const SizedBox(height: 24),
            _SectionLabel(
              label: 'Active goals',
              action: 'See all',
              muted: muted,
              accent: accent,
              onTap: () => context.push(AppRoutes.goals),
            ),
            const SizedBox(height: 24),
            _SectionLabel(
              label: 'Recent',
              action: 'View all',
              muted: muted,
              accent: accent,
              onTap: () => context.push(AppRoutes.transactions),
            ),
            const SizedBox(height: 8),
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
                  for (var i = 0; i < _recentTx.length; i++)
                    TxRow(tx: _recentTx[i], showDivider: i < _recentTx.length - 1),
                ],
              ),
            ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  TxData _toTxData(Transaction tx, List<MoneySource> sources) {
    final source = sources.where((s) => s.id == tx.moneySourceId).firstOrNull;
    final isShared = source?.ownerType == OwnerType.shared;
    final icon = tx.type == TransactionType.income
        ? CreditCard(width: 18, height: 18, color: const Color(0xFF4CB782))
        : Bank(width: 18, height: 18, color: const Color(0xFF8B7AE6));
    return TxData(
      icon: icon,
      color: const Color(0xFF8B7AE6),
      title: tx.note ?? tx.categoryName ?? 'Transaction',
      category: tx.categoryName ?? tx.type.name,
      source: source?.name ?? tx.moneySourceName ?? 'Account',
      amount: tx.type == TransactionType.expense ? -tx.amount.abs() : tx.amount.abs(),
      shared: isShared,
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
  final VoidCallback? onAvatarTap;
  final VoidCallback? onBellTap;

  const _Header({
    required this.fg,
    required this.muted,
    required this.surface,
    required this.border,
    required this.accent,
    this.onAvatarTap,
    this.onBellTap,
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
                  style: TextStyle(fontSize: 13, color: muted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Overview',
                  style: AppFonts.heading(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onBellTap,
            behavior: HitTestBehavior.opaque,
            child: Stack(
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
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onAvatarTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
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
  final VoidCallback? onTap;

  const _SectionLabel({
    required this.label,
    this.action,
    required this.muted,
    required this.accent,
    this.onTap,
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
    fontSize: 12,
                fontWeight: FontWeight.w600,
                color: muted,
                letterSpacing: 1.0,
              ),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                action!,
                style: TextStyle(
                  fontSize: 12,
                  color: accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
