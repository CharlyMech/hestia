import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/money_source.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/money_sources/money_sources_bloc.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';
import 'package:hestia/presentation/widgets/money_sources/wallet_card.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Plus;

class MoneySourcesScreen extends StatefulWidget {
  const MoneySourcesScreen({super.key});

  @override
  State<MoneySourcesScreen> createState() => _MoneySourcesScreenState();
}

class _MoneySourcesScreenState extends State<MoneySourcesScreen> {
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
      return CupertinoPageScaffold(
        backgroundColor: bg,
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }
    return BlocProvider(
      create: (_) => MoneySourcesBloc(
        AppDependencies.instance.moneySourceRepository,
      )..add(MoneySourcesLoad(
          householdId: _householdId!,
          userId: auth.profile.id,
        )),
      child: const _Body(),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);
    final border = _c(theme.borderColor);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: BlocBuilder<MoneySourcesBloc, MoneySourcesState>(
        builder: (context, state) {
          if (state is MoneySourcesLoading || state is MoneySourcesInitial) {
            return ScreenShell(
              bg: bg,
              slivers: const [
                SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator()),
                ),
              ],
            );
          }
          if (state is MoneySourcesError) {
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
          final loaded = state as MoneySourcesLoaded;
          return ScreenShell(
            bg: bg,
            onRefresh: () async {
              final bloc = context.read<MoneySourcesBloc>();
              bloc.add(const MoneySourcesRefresh());
              await bloc.stream
                  .firstWhere((s) => s is! MoneySourcesLoading);
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
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              if (loaded.shared.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionLabel(l10n.moneySources_shared, color: muted),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                _CardList(sources: loaded.shared, indexOffset: 0),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
              if (loaded.personal.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child:
                      SectionLabel(l10n.moneySources_personal, color: muted),
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
                  label: l10n.moneySources_addCard,
                  onTap: () => context.push(AppRoutes.addMoneySource),
                ),
              ),
            ],
          );
        },
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

  const _Header({
    required this.l10n,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.total,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            l10n.moneySources_title,
            style: AppFonts.heading(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          Text(
            l10n.moneySources_totalNetWorth,
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
  final List<MoneySource> sources;
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
            AppRoutes.moneySourceDetail,
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
