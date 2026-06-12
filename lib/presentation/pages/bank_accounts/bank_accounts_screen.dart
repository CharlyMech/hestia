import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/bank_accounts/bank_accounts_bloc.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/dotted_border.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';

import 'package:hestia/presentation/widgets/bank_accounts/wallet_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Plus;
import 'package:skeletonizer/skeletonizer.dart';

class BankAccountsScreen extends StatefulWidget {
  final bool embeddedInTabShell;

  const BankAccountsScreen({super.key, this.embeddedInTabShell = false});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  String? _householdId;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    _resolveHousehold();
  }

  Future<void> _resolveHousehold() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      if (mounted) setState(() => _resolving = false);
      return;
    }
    final (household, _) = await AppDependencies.instance.householdRepository
        .getCurrentHousehold(auth.profile.id);
    if (!mounted) return;
    setState(() {
      _householdId = household?.id;
      _resolving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const _SignedOut();

    if (widget.embeddedInTabShell) {
      return _Body(embeddedInTabShell: true);
    }

    if (_resolving || _householdId == null) {
      final theme = context.myTheme;
      final bg = hexToColor(theme.backgroundColor);
      final surface = hexToColor(theme.surfaceColor);
      final border = hexToColor(theme.borderColor);
      final fg = hexToColor(theme.onBackgroundColor);
      final muted = hexToColor(theme.onInactiveColor);
      final l10n = AppLocalizations.of(context);

      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: l10n.bankAccounts_title,
        child: Skeletonizer(
          enabled: true,
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Placeholder label',
                          style: AppFonts.sectionLabel(color: muted)),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => BankAccountsBloc(
        AppDependencies.instance.bankAccountRepository,
      )..add(BankAccountsLoad(
          householdId: _householdId!,
          userId: auth.profile.id,
        )),
      child: _Body(embeddedInTabShell: false),
    );
  }
}

class _Body extends StatefulWidget {
  final bool embeddedInTabShell;
  const _Body({required this.embeddedInTabShell});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  int _skeletonEpoch = 0;
  bool _showOthers = false;

  Widget _wrapPageChrome({
    required Color bg,
    required Color surface,
    required Color border,
    required Color fg,
    required AppLocalizations l10n,
    required Widget child,
  }) {
    if (widget.embeddedInTabShell) {
      return ColoredBox(color: bg, child: child);
    }
    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: l10n.bankAccounts_title,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);
    final border = hexToColor(theme.borderColor);

    return _wrapPageChrome(
      bg: bg,
      surface: surface,
      border: border,
      fg: fg,
      l10n: l10n,
      child: BlocListener<BankAccountsBloc, BankAccountsState>(
        listenWhen: (p, n) =>
            n is BankAccountsLoading && p is BankAccountsLoaded,
        listener: (_, __) {
          if (mounted) setState(() => _skeletonEpoch++);
        },
        child: BlocBuilder<BankAccountsBloc, BankAccountsState>(
          builder: (context, state) {
            if (state is BankAccountsLoading || state is BankAccountsInitial) {
              return Skeletonizer(
                key: ValueKey(_skeletonEpoch),
                enabled: true,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    if (widget.embeddedInTabShell)
                      SliverToBoxAdapter(
                        child: _LargeTitle(
                            label: l10n.bankAccounts_title, fg: fg),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.list(
                        children: [
                          for (var i = 0; i < 3; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AspectRatio(
                                aspectRatio: 1.586,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: muted.withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.xl),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is BankAccountsError) {
              return ScreenShell(
                bg: bg,
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Text(state.message,
                          style: AppFonts.body(fontSize: 13, color: muted)),
                    ),
                  ),
                ],
              );
            }

            final loaded = state as BankAccountsLoaded;
            final others = loaded.others;

            return ScreenShell(
              bg: bg,
              onRefresh: () async {
                final bloc = context.read<BankAccountsBloc>();
                bloc.add(const BankAccountsRefresh());
                await bloc.stream.firstWhere((s) => s is! BankAccountsLoading);
              },
              slivers: [
                if (widget.embeddedInTabShell)
                  SliverToBoxAdapter(
                    child:
                        _LargeTitle(label: l10n.bankAccounts_title, fg: fg),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Shared accounts ───────────────────────────────────────
                if (loaded.shared.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: SectionLabel(l10n.bankAccounts_shared,
                        color: muted),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  _CardList(sources: loaded.shared, indexOffset: 0),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // ── My accounts ───────────────────────────────────────────
                if (loaded.personal.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: SectionLabel(l10n.bankAccounts_myAccounts,
                        color: muted),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  _CardList(
                    sources: loaded.personal,
                    indexOffset: loaded.shared.length,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],

                // ── Add card placeholder ──────────────────────────────────
                SliverToBoxAdapter(
                  child: _AddCardPlaceholder(
                    border: border,
                    muted: muted,
                    label: l10n.bankAccounts_addCard,
                    onTap: () async {
                      final bloc = context.read<BankAccountsBloc>();
                      final created =
                          await context.push<bool>(AppRoutes.addBankAccount);
                      // Account screen pops `true` on successful create.
                      if (created == true) {
                        bloc.add(const BankAccountsRefresh());
                      }
                    },
                  ),
                ),

                // ── Other accounts toggle ─────────────────────────────────
                if (others.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _showOthers = !_showOthers),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          spacing: 6,
                          children: [
                            Expanded(
                              child: Text(
                                _showOthers
                                    ? l10n.bankAccounts_hideOthers
                                    : '${l10n.bankAccounts_showOthers} (${others.length})',
                                style: AppFonts.body(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ),
                            Icon(
                              _showOthers
                                  ? CupertinoIcons.chevron_up
                                  : CupertinoIcons.chevron_down,
                              size: 14,
                              color: accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_showOthers) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(
                      child: SectionLabel(l10n.bankAccounts_others,
                          color: muted),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    _CardList(
                      sources: others,
                      indexOffset:
                          loaded.shared.length + loaded.personal.length,
                    ),
                  ],
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LargeTitle extends StatelessWidget {
  final String label;
  final Color fg;
  const _LargeTitle({required this.label, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Text(
        label,
        style: AppFonts.heading(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  final List<BankAccount> sources;
  final int indexOffset;

  const _CardList({required this.sources, required this.indexOffset});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.separated(
        itemCount: sources.length,
        itemBuilder: (_, i) => WalletCard(
          source: sources[i],
          index: indexOffset + i,
          onTap: () => context.push(
            AppRoutes.bankAccountDetail,
            extra: sources[i].id,
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
      ),
    );
  }
}

class _AddCardPlaceholder extends StatelessWidget {
  final Color border;
  final Color muted;
  final String label;
  final VoidCallback onTap;

  const _AddCardPlaceholder({
    required this.border,
    required this.muted,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AspectRatio(
          aspectRatio: 1.586,
          child: DottedBorder(
            color: border,
            radius: AppRadii.xl,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Plus(width: 22, height: 22, color: muted),
                  Text(
                    label,
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignedOut extends StatelessWidget {
  const _SignedOut();

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg =
        hexToColor(theme.backgroundColor);
    final muted =
        hexToColor(theme.onInactiveColor);
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Center(
        child: Text(
          AppLocalizations.of(context).bankAccounts_signInPrompt,
          style: AppFonts.body(fontSize: 14, color: muted),
        ),
      ),
    );
  }
}
