import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/services/location_service.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:hestia/presentation/widgets/common/user_avatar_button.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/appointment.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/map/map_bloc.dart';
import 'package:hestia/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:hestia/domain/entities/shopping_list.dart';
import 'package:hestia/presentation/blocs/shopping/shopping_lists_bloc.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/widgets/bank_accounts/wallet_card.dart';
import 'package:hestia/presentation/widgets/common/animated_pill_tabs.dart';
import 'package:hestia/presentation/widgets/common/date_range_selector.dart';
import 'package:hestia/presentation/widgets/dashboard/map_preview_card.dart';
import 'package:hestia/presentation/widgets/dashboard/spend_donut.dart';
import 'package:hestia/presentation/widgets/dashboard/tx_row.dart';

import 'package:hestia/presentation/widgets/dashboard/week_calendar_strip.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show Bell, Bank, CreditCard, Settings, CartAlt;
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<String>? onOpenMoneySource;
  const DashboardScreen({super.key, this.onOpenMoneySource});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  List<BankAccount> _accounts = const [];
  List<Transaction> _allTransactions = const [];
  List<TxData> _recentTx = const [];
  List<Transaction> _recentTransactions = const [];
  List<Appointment> _weekAppointments = const [];
  StreamSubscription<List<Appointment>>? _weekAppointmentsSub;
  StreamSubscription<Position>? _locationSub;
  bool _loading = true;
  bool _refreshing = false;
  DateRangePreset _range = DateRangePreset.d30;

  static const _rangePresets = [
    DateRangePreset.d7,
    DateRangePreset.d30,
    DateRangePreset.d90,
    DateRangePreset.m6,
    DateRangePreset.y1,
  ];

  static const _rangeLabels = ['7d', '30d', '90d', '6m', '1y'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
    _startLocationStream();
  }

  @override
  void dispose() {
    _weekAppointmentsSub?.cancel();
    _locationSub?.cancel();
    super.dispose();
  }

  void _startLocationStream() async {
    // Only start if permission already granted — never request here.
    final granted = await LocationService().hasPermission();
    if (!granted || !mounted) return;

    // First fix recentres the shared map camera on the user.
    try {
      final current = await Geolocator.getCurrentPosition();
      if (mounted) {
        context.read<MapBloc>().add(
              MapUserLocationUpdated(current.latitude, current.longitude,
                  recenter: true),
            );
      }
    } catch (_) {
      // Stream may still deliver a fix shortly after.
    }

    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((pos) {
      if (!mounted) return;
      context
          .read<MapBloc>()
          .add(MapUserLocationUpdated(pos.latitude, pos.longitude));
    });
  }

  Future<void> _load({bool fromPullRefresh = false}) async {
    if (fromPullRefresh && mounted) setState(() => _refreshing = true);
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        await _weekAppointmentsSub?.cancel();
        if (mounted) setState(() => _loading = false);
        return;
      }
      final profile = authState.profile;
      final deps = AppDependencies.instance;
      final (household, _) =
          await deps.householdRepository.getCurrentHousehold(profile.id);
      if (household == null) {
        await _weekAppointmentsSub?.cancel();
        if (mounted) {
          setState(() {
            _loading = false;
            _accounts = const [];
            _allTransactions = const [];
            _recentTx = const [];
            _recentTransactions = const [];
            _weekAppointments = const [];
          });
        }
        return;
      }

      _watchWeekAppointments(profile.id);

      // Global (household-wide) data — all members' accounts & transactions.
      final (accounts, _) = await deps.bankAccountRepository.getBankAccounts(
        householdId: household.id,
        viewMode: ViewMode.household,
        userId: profile.id,
      );
      final (transactions, _) =
          await deps.transactionRepository.getTransactions(
        householdId: household.id,
        viewMode: ViewMode.household,
        userId: profile.id,
        limit: 500,
      );
      if (mounted) {
        context.read<NotificationsBloc>().add(NotificationsLoad(profile.id));
      }

      final recentTransactions = transactions.take(8).toList();
      final recent =
          recentTransactions.map((tx) => _toTxData(tx, accounts)).toList();

      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _allTransactions = transactions;
        _recentTx = recent;
        _recentTransactions = recentTransactions;
        _loading = false;
      });
    } finally {
      if (mounted && fromPullRefresh) {
        setState(() => _refreshing = false);
      }
    }
  }

  void _watchWeekAppointments(String userId) {
    final startDay = context.read<UserPrefsBloc>().state.startDay;
    final now = DateTime.now();
    final weekStart = _dateOnly(now)
        .subtract(Duration(days: (now.weekday - startDay + 7) % 7));
    final weekEnd = weekStart.add(const Duration(days: 7));

    _weekAppointmentsSub?.cancel();
    _weekAppointmentsSub = AppDependencies.instance.appointmentRepository
        .watchRange(
      userId: userId,
      from: weekStart,
      to: weekEnd,
    )
        .listen((appointments) {
      if (!mounted) return;
      setState(() => _weekAppointments = appointments);
    });
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Transaction> _txInRange() {
    final r = DateRange.fromPreset(_range);
    return _allTransactions
        .where((tx) => tx.date.isAfter(r.start) && tx.date.isBefore(r.end))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final primary = hexToColor(theme.primaryColor);
    final tints = theme.categoryTints.map(hexToColor).toList();
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthBloc>().state;
    final topInset = MediaQuery.viewPaddingOf(context).top;
    return ColoredBox(
      color: bg,
      child: _loading
          ? Skeletonizer(
              enabled: true,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Row(
                      children: [
                        Text(
                          'User name goes here long',
                          style: AppFonts.heading(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 148,
                      width: 262,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                      ),
                    ),
                    Text(
                      'RECENT ACTIVITY placeholder',
                      style: AppFonts.body(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
            )
          : Skeletonizer(
              enabled: _refreshing,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  CupertinoSliverRefreshControl(
                      onRefresh: () => _load(fromPullRefresh: true)),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 140),
                    sliver: SliverList.list(children: [
                      _Header(
                        fg: fg,
                        muted: muted,
                        surface: surface,
                        border: border,
                        accent: accent,
                        profile:
                            auth is AuthAuthenticated ? auth.profile : null,
                        unreadCount: (context.watch<NotificationsBloc>().state
                                is NotificationsLoaded)
                            ? (context.watch<NotificationsBloc>().state
                                    as NotificationsLoaded)
                                .unreadCount
                            : 0,
                      ),
                      const SizedBox(height: 20),
                      _SectionLabel(
                          label: l10n.dashboard_accounts, muted: muted),
                      const SizedBox(height: 12),
                      if (_accounts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              await context
                                  .push<bool>(AppRoutes.addBankAccount);
                              if (mounted) _load();
                            },
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                child: Row(
                                  spacing: 12,
                                  children: [
                                    Icon(CupertinoIcons.add_circled,
                                        size: 22, color: accent),
                                    Expanded(
                                      child: Text(
                                        l10n.bankAccounts_addCard,
                                        style: AppFonts.body(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: fg),
                                      ),
                                    ),
                                    Icon(CupertinoIcons.chevron_right,
                                        size: 16, color: muted),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _accounts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) => SizedBox(
                              width: 280,
                              child: WalletCard(
                                source: _accounts[i],
                                index: i,
                                onTap: () => (widget.onOpenMoneySource ??
                                        ((id) => context.push(
                                            AppRoutes.bankAccountDetail,
                                            extra: id)))
                                    .call(_accounts[i].id),
                              ),
                            ),
                          ),
                        ),
                      // Active shopping session banner
                      Builder(builder: (ctx) {
                        final shState = ctx.watch<ShoppingListsBloc>().state;
                        final sessions = shState is ShoppingListsLoaded
                            ? shState.activeSessions
                            : <ShoppingList>[];
                        if (sessions.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              border: Border.all(
                                  color: accent.withValues(alpha: 0.25),
                                  width: 0.8),
                            ),
                            child: Row(
                              spacing: 10,
                              children: [
                                CartAlt(width: 18, height: 18, color: fg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 2,
                                    children: [
                                      Text(
                                        sessions.length == 1
                                            ? l10n
                                                .dashboard_activeShoppingSession
                                            : l10n
                                                .dashboard_activeShoppingSessions(
                                                sessions.length,
                                              ),
                                        style: AppFonts.body(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: fg),
                                      ),
                                      Text(
                                        sessions.first.name,
                                        style: AppFonts.body(
                                            fontSize: 12, color: muted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push(
                                      AppRoutes.shoppingListDetail,
                                      extra: sessions.first.id),
                                  child: Text(l10n.common_viewAll,
                                      style: AppFonts.body(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: accent)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      _CalendarSectionLabel(accent: accent, muted: muted),
                      const SizedBox(height: 8),
                      WeekCalendarStrip(
                        appointments: _weekAppointments,
                        transactions: _allTransactions,
                        accent: accent,
                        fg: fg,
                        muted: muted,
                        surface: surface,
                        income: hexToColor(theme.colorGreen),
                        startDay: context.read<UserPrefsBloc>().state.startDay,
                      ),
                      const SizedBox(height: 20),
                      // Date range — animated pill tabs
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimatedPillTabs(
                          labels: _rangeLabels,
                          selectedIndex: _rangePresets.indexOf(_range),
                          onChanged: (i) =>
                              setState(() => _range = _rangePresets[i]),
                          surface: surface,
                          border: border,
                          fg: fg,
                          muted: muted,
                          pillColor: primary,
                          height: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionLabel(
                          label: l10n.dashboard_spending, muted: muted),
                      const SizedBox(height: 8),
                      _ChartCard(
                        surface: surface,
                        border: border,
                        child: SpendDonut(
                          transactions: _txInRange(),
                          fg: fg,
                          muted: muted,
                          border: border,
                          surface: surface,
                          palette: tints,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(label: l10n.dashboard_recent, muted: muted),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _recentTx.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(18),
                                child: Text(
                                  'No transactions yet',
                                  style:
                                      AppFonts.body(fontSize: 13, color: muted),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Column(
                                children: [
                                  for (var i = 0; i < _recentTx.length; i++)
                                    TxRow(
                                      tx: _recentTx[i],
                                      showDivider: i < _recentTx.length - 1,
                                      onTap: () => context.push(
                                        AppRoutes.transactionDetail,
                                        extra: _recentTransactions[i],
                                      ),
                                    ),
                                ],
                              ),
                      ),

                      // Map preview — always visible; opens the global map.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _SectionLabel(
                              label: l10n.dashboard_map, muted: muted),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: MapPreviewCard(
                              surface: surface,
                              border: border,
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),
    );
  }

  TxData _toTxData(Transaction tx, List<BankAccount> sources) {
    final source = sources.where((s) => s.id == tx.bankAccountId).firstOrNull;
    final isShared = source?.ownerType == OwnerType.shared;
    final icon = tx.type == TransactionType.income
        ? CreditCard(width: 18, height: 18, color: const Color(0xFF4CB782))
        : Bank(width: 18, height: 18, color: const Color(0xFF8B7AE6));
    return TxData(
      icon: icon,
      color: const Color(0xFF8B7AE6),
      title: tx.note ?? tx.categoryName ?? 'Transaction',
      category: tx.categoryName ?? tx.type.name,
      source: source?.name ?? tx.bankAccountName ?? 'Account',
      amount: tx.type == TransactionType.expense
          ? -tx.amount.abs()
          : tx.amount.abs(),
      shared: isShared,
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Color fg, muted, surface, border, accent;
  final dynamic profile; // Profile? — dynamic to avoid import cycle
  final int unreadCount;

  const _Header({
    required this.fg,
    required this.muted,
    required this.surface,
    required this.border,
    required this.accent,
    required this.profile,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.viewPaddingOf(context).top + 12, 20, 0),
      child: Row(
        spacing: 8,
        children: [
          if (profile != null)
            UserAvatarButton(
              profile: profile,
              size: 44,
              onTap: () => context.push(AppRoutes.profile),
            )
          else
            const SizedBox(width: 44),
          const Spacer(),
          AnimatedButton(
            onTap: () => context.push(AppRoutes.notifications),
            size: 44,
            borderRadius: AppRadii.full,
            backgroundColor: surface,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: Bell(width: 18, height: 18, color: fg)),
                if (unreadCount > 0)
                  Positioned(
                    top: 6,
                    right: 7,
                    child: Container(
                      width: 8,
                      height: 8,
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
          AnimatedButton(
            onTap: () => context.push(AppRoutes.settings),
            size: 44,
            borderRadius: AppRadii.full,
            backgroundColor: surface,
            child: Settings(width: 18, height: 18, color: fg),
          ),
        ],
      ),
    );
  }
}

class _CalendarSectionLabel extends StatelessWidget {
  final Color accent;
  final Color muted;
  const _CalendarSectionLabel({required this.accent, required this.muted});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final month = DateFormat('MMMM', locale).format(DateTime.now());
    final isEs = locale.startsWith('es');
    final prefix = isEs ? 'Calendario de ' : 'Calendar of ';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        text: TextSpan(
          text: prefix.toUpperCase(),
          style: AppFonts.body(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: muted,
            letterSpacing: 1.0,
          ),
          children: [
            TextSpan(
              text: month.toUpperCase(),
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color muted;

  const _SectionLabel({required this.label, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label.toUpperCase(),
        style: AppFonts.body(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: muted,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;
  final Color surface, border;

  const _ChartCard(
      {required this.child, required this.surface, required this.border});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(AppRadii.lg),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: child,
      ),
    );
  }
}
