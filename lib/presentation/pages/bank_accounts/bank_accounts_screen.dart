import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/account_member.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/payment_card.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/bank_accounts/bank_accounts_bloc.dart';
import 'package:hestia/presentation/blocs/cards/cards_bloc.dart';
import 'package:hestia/presentation/widgets/cards/payment_card_widget.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
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

// ── Body ──────────────────────────────────────────────────────────────────────

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
                  _AccountSectionList(
                    accounts: loaded.shared,
                    muted: muted,
                    accent: accent,
                    border: border,
                    indexOffset: 0,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // ── My accounts ───────────────────────────────────────────
                if (loaded.personal.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: SectionLabel(l10n.bankAccounts_myAccounts,
                        color: muted),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  _AccountSectionList(
                    accounts: loaded.personal,
                    muted: muted,
                    accent: accent,
                    border: border,
                    indexOffset: loaded.shared.length,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],

                // ── Add account placeholder ───────────────────────────────
                SliverToBoxAdapter(
                  child: _AddAccountPlaceholder(
                    border: border,
                    muted: muted,
                    label: l10n.bankAccounts_addCard,
                    onTap: () async {
                      final bloc = context.read<BankAccountsBloc>();
                      final created =
                          await context.push<bool>(AppRoutes.addBankAccount);
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
                    _AccountSectionList(
                      accounts: others,
                      muted: muted,
                      accent: accent,
                      border: border,
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

// ── Per-account section (WalletCard + card carousel) ─────────────────────────

/// Sliver list of account sections. Each section owns a [CardsBloc].
class _AccountSectionList extends StatefulWidget {
  final List<BankAccount> accounts;
  final Color muted;
  final Color accent;
  final Color border;
  final int indexOffset;

  const _AccountSectionList({
    required this.accounts,
    required this.muted,
    required this.accent,
    required this.border,
    required this.indexOffset,
  });

  @override
  State<_AccountSectionList> createState() => _AccountSectionListState();
}

class _AccountSectionListState extends State<_AccountSectionList> {
  final _blocs = <String, CardsBloc>{};

  CardsBloc _blocFor(BankAccount account) {
    return _blocs.putIfAbsent(account.id, () {
      final bloc = CardsBloc(AppDependencies.instance.cardRepository);
      bloc.add(CardsLoad(account.id));
      return bloc;
    });
  }

  @override
  void dispose() {
    for (final b in _blocs.values) {
      b.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.separated(
        itemCount: widget.accounts.length,
        itemBuilder: (_, i) {
          final account = widget.accounts[i];
          return BlocProvider.value(
            value: _blocFor(account),
            child: _AccountSection(
              account: account,
              index: widget.indexOffset + i,
              muted: widget.muted,
              accent: widget.accent,
              border: widget.border,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 20),
      ),
    );
  }
}

class _AccountSection extends StatefulWidget {
  final BankAccount account;
  final int index;
  final Color muted;
  final Color accent;
  final Color border;

  const _AccountSection({
    required this.account,
    required this.index,
    required this.muted,
    required this.accent,
    required this.border,
  });

  @override
  State<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<_AccountSection> {
  List<AccountMember> _members = const [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final (members, _) = await AppDependencies.instance.accountMemberRepository
        .getMembers(widget.account.id);
    if (mounted) setState(() => _members = members);
  }

  void _openAddCard(BuildContext context, CardsBloc cardsBloc) {
    context.push(AppRoutes.addCard, extra: (
      account: widget.account,
      accountMembers: _members,
      cardsBloc: cardsBloc,
    ));
  }

  void _openEditCard(
      BuildContext context, PaymentCard card, CardsBloc cardsBloc) {
    context.push(AppRoutes.editCard, extra: (
      account: widget.account,
      accountMembers: _members,
      card: card,
      cardsBloc: cardsBloc,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cardsBloc = context.read<CardsBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        WalletCard(
          source: widget.account,
          index: widget.index,
          onTap: () => context.push(
            AppRoutes.bankAccountDetail,
            extra: widget.account.id,
          ),
        ),
        BlocBuilder<CardsBloc, CardsState>(
          builder: (context, state) {
            if (state is CardsLoading) {
              return const SizedBox(height: 4);
            }
            if (state is! CardsLoaded || state.cards.isEmpty) {
              return _AddCardPill(
                muted: widget.muted,
                accent: widget.accent,
                border: widget.border,
                onTap: () => _openAddCard(context, cardsBloc),
              );
            }
            final cards = state.cards;
            return SizedBox(
              height: _cardHeight(context),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: cards.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  if (i == cards.length) {
                    return _AddCardPill(
                      muted: widget.muted,
                      accent: widget.accent,
                      border: widget.border,
                      onTap: () => _openAddCard(context, cardsBloc),
                      compact: true,
                    );
                  }
                  final card = cards[i];
                  return SizedBox(
                    width: _cardWidth(context),
                    child: _CardTile(
                      card: card,
                      accent: widget.accent,
                      muted: widget.muted,
                      onTap: () => _openEditCard(context, card, cardsBloc),
                      onSetPrimary: card.isPrimary
                          ? null
                          : () => cardsBloc.add(CardsSetPrimary(
                                cardId: card.id,
                                accountId: widget.account.id,
                              )),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  double _cardWidth(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width - 40; // 20px padding each side
    // Show ~1.2 cards so user knows to scroll.
    return (sw * 0.82).clamp(240, 320);
  }

  double _cardHeight(BuildContext context) =>
      _cardWidth(context) / 1.586 + 32; // card + owner row
}

class _CardTile extends StatelessWidget {
  final PaymentCard card;
  final Color accent;
  final Color muted;
  final VoidCallback onTap;
  final VoidCallback? onSetPrimary;

  const _CardTile({
    required this.card,
    required this.accent,
    required this.muted,
    required this.onTap,
    this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        PaymentCardWidget(card: card, onTap: onTap),
        if (onSetPrimary != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: AnimatedButton(
              onTap: onSetPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                'Set as primary',
                style: AppFonts.label(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddCardPill extends StatelessWidget {
  final Color muted;
  final Color accent;
  final Color border;
  final VoidCallback onTap;
  final bool compact;

  const _AddCardPill({
    required this.muted,
    required this.accent,
    required this.border,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return AspectRatio(
        aspectRatio: 0.6,
        child: AnimatedButton(
          onTap: onTap,
          borderRadius: AppRadii.xl,
          child: DottedBorder(
            color: border,
            radius: AppRadii.xl,
            child: Center(
              child: Plus(width: 20, height: 20, color: muted),
            ),
          ),
        ),
      );
    }
    return AnimatedButton(
      onTap: onTap,
      borderRadius: AppRadii.xl,
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
                  'Add card',
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

class _AddAccountPlaceholder extends StatelessWidget {
  final Color border;
  final Color muted;
  final String label;
  final VoidCallback onTap;

  const _AddAccountPlaceholder({
    required this.border,
    required this.muted,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedButton(
        onTap: onTap,
        borderRadius: AppRadii.xl,
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
    final bg = hexToColor(theme.backgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
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
