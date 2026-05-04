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
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/bank_accounts/wallet_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Plus;
import 'package:skeletonizer/skeletonizer.dart';

class BankAccountsScreen extends StatefulWidget {
  /// When true (tab inside [MainTabShell]), skips pushed-route top chrome.
  final bool embeddedInTabShell;

  const BankAccountsScreen({super.key, this.embeddedInTabShell = false});

  @override
  State<BankAccountsScreen> createState() => _MoneySourcesScreenState();
}

class _MoneySourcesScreenState extends State<BankAccountsScreen> {
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
    if (auth is! AuthAuthenticated) {
      return const _SignedOut();
    }
    if (_resolving || _householdId == null) {
      final theme = context.myTheme;
      final bg = _c(theme.backgroundColor);
      final border = _c(theme.borderColor);
      final fg = _c(theme.onBackgroundColor);
      final muted = _c(theme.onInactiveColor);
      final l10n = AppLocalizations.of(context);

      Widget loadingBody = Skeletonizer(
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
                    if (widget.embeddedInTabShell) ...[
                      Text(
                        l10n.bankAccounts_title,
                        style: AppFonts.heading(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      l10n.bankAccounts_totalNetWorth,
                      style: AppFonts.body(fontSize: 13, color: muted),
                    ),
                    Text(
                      '9999.99 EUR',
                      style: AppFonts.numeric(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Placeholder label', style: AppFonts.sectionLabel(color: muted)),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

      if (widget.embeddedInTabShell) {
        return ColoredBox(
          color: bg,
          child: SafeArea(
            bottom: false,
            child: loadingBody,
          ),
        );
      }
      final surface = _c(theme.surfaceColor);
      return CupertinoPushedRouteShell(
        backgroundColor: bg,
        navBackground: surface,
        borderColor: border,
        foregroundColor: fg,
        titleText: l10n.bankAccounts_title,
        child: loadingBody,
      );
    }
    return BlocProvider(
      create: (_) => BankAccountsBloc(
        AppDependencies.instance.bankAccountRepository,
      )..add(BankAccountsLoad(
          householdId: _householdId!,
          userId: auth.profile.id,
        )),
      child: _Body(embeddedInTabShell: widget.embeddedInTabShell),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Body extends StatefulWidget {
  final bool embeddedInTabShell;

  const _Body({required this.embeddedInTabShell});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  int _skeletonEpoch = 0;

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
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final border = _c(theme.borderColor);

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
                  SliverToBoxAdapter(
                    child: _Header(
                      l10n: l10n,
                      fg: fg,
                      muted: muted,
                      accent: accent,
                      total: 88888.88,
                      currency: 'EUR',
                      showLargeTitle: widget.embeddedInTabShell,
                    ),
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
          return ScreenShell(
            bg: bg,
            onRefresh: () async {
              final bloc = context.read<BankAccountsBloc>();
              bloc.add(const BankAccountsRefresh());
              await bloc.stream
                  .firstWhere((s) => s is! BankAccountsLoading);
            },
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  l10n: l10n,
                  fg: fg,
                  muted: muted,
                  accent: accent,
                  total: loaded.totalBalance,
                  currency: loaded.sources.firstOrNull?.currency ?? 'EUR',
                  showLargeTitle: widget.embeddedInTabShell,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              if (loaded.shared.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionLabel(l10n.bankAccounts_shared, color: muted),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                _CardList(sources: loaded.shared, indexOffset: 0),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
              if (loaded.personal.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child:
                      SectionLabel(l10n.bankAccounts_personal, color: muted),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                _CardList(
                  sources: loaded.personal,
                  indexOffset: loaded.shared.length,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
              SliverToBoxAdapter(
                child: _AddCardPlaceholder(
                  border: border,
                  muted: muted,
                  label: l10n.bankAccounts_addCard,
                  onTap: () => context.push(AppRoutes.addBankAccount),
                ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Header extends StatelessWidget {
  final AppLocalizations l10n;
  final Color fg;
  final Color muted;
  final Color accent;
  final double total;
  final String currency;
  final bool showLargeTitle;

  const _Header({
    required this.l10n,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.total,
    required this.currency,
    this.showLargeTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          if (showLargeTitle)
            Text(
              l10n.bankAccounts_title,
              style: AppFonts.heading(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          Text(
            l10n.bankAccounts_totalNetWorth,
            style: AppFonts.body(fontSize: 13, color: muted),
          ),
          Text(
            '${total.toStringAsFixed(2)} $currency',
            style: AppFonts.numeric(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
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

/// Lightweight dashed-border container — avoids adding a dotted_border package.
class DottedBorder extends StatelessWidget {
  final Color color;
  final double radius;
  final Widget child;

  const DottedBorder({
    super.key,
    required this.color,
    required this.radius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashed = _dash(path, dash: 6, gap: 4);
    canvas.drawPath(dashed, paint);
  }

  Path _dash(Path source, {required double dash, required double gap}) {
    final out = Path();
    for (final metric in source.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = dist + dash;
        out.addPath(metric.extractPath(dist, next), Offset.zero);
        dist = next + gap;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

class _SignedOut extends StatelessWidget {
  const _SignedOut();

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg =
        Color(int.parse(theme.backgroundColor.replaceFirst('#', '0xff')));
    final muted =
        Color(int.parse(theme.onInactiveColor.replaceFirst('#', '0xff')));
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Center(
        child: Text(
          'Sign in to view accounts',
          style: AppFonts.body(fontSize: 14, color: muted),
        ),
      ),
    );
  }
}
