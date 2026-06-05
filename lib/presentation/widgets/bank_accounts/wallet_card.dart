import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/bank_account.dart';
import 'package:hestia/domain/entities/financial_institution.dart';
import 'package:hestia/presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'package:hestia/presentation/widgets/dashboard/scope_pill.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Credit-card style account card. Renders the bundled bank PNG when a matching
/// asset exists at `assets/banks/<institution>.png`, else a primary-color
/// gradient placeholder. Animates a press scale and a staggered enter.
///
/// Pass [institution] (resolved from [InstitutionsCubit]) to use the proper
/// logo asset. Falls back to [source.institution] slug derivation for legacy data.
/// Cash accounts ([AccountType.cash]) always show a special warm gradient skin.
class WalletCard extends StatefulWidget {
  final BankAccount source;

  /// Resolved financial institution — provides logoAsset directly.
  final FinancialInstitution? institution;

  /// Index in the parent list — drives the staggered enter delay.
  final int index;

  /// Optional 30-day net change for the status indicator (positive/negative).
  final double? trend30d;

  final VoidCallback? onTap;

  /// Hero tag. When null the card is NOT wrapped in a Hero (safe default —
  /// avoids duplicate-tag crashes when the same account renders in multiple
  /// places). Supply a route-unique tag only where a hero transition is wanted.
  final Object? heroTag;

  const WalletCard({
    super.key,
    required this.source,
    this.institution,
    this.index = 0,
    this.trend30d,
    this.onTap,
    this.heroTag,
  });

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  bool _pressed = false;
  bool? _bankAssetExists;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    Future<void>.delayed(
      Duration(milliseconds: widget.index * 60),
      () {
        if (mounted) _enter.forward();
      },
    );
    _checkAsset();
  }

  Future<void> _checkAsset() async {
    // Cash accounts never show a bank logo.
    if (widget.source.accountType == AccountType.cash) {
      if (mounted) setState(() => _bankAssetExists = false);
      return;
    }
    // Prefer resolved institution logoAsset, else derive from legacy slug.
    final path = widget.institution?.logoAsset ?? _legacyAssetPath();
    if (path == null) {
      if (mounted) setState(() => _bankAssetExists = false);
      return;
    }
    try {
      await rootBundle.load(path);
      if (mounted) setState(() => _bankAssetExists = true);
    } catch (_) {
      if (mounted) setState(() => _bankAssetExists = false);
    }
  }

  String? _legacyAssetPath() {
    final inst = widget.source.institution;
    if (inst == null || inst.isEmpty) return null;
    final slug = inst
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return 'assets/banks/$slug.png';
  }

  String _resolvedAssetPath() {
    return widget.institution?.logoAsset ?? _legacyAssetPath() ?? '';
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<UserPrefsBloc>(),
      child: BlocConsumer<UserPrefsBloc, UserPrefsState>(
        listenWhen: (prev, curr) => prev.themeType != curr.themeType,
        listener: (_, __) {},
        buildWhen: (prev, curr) => prev.themeType != curr.themeType,
        builder: (context, _) => _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final theme = context.myTheme;
    final surface = hexToColor(theme.surfaceColor);
    final primary = hexToColor(theme.primaryColor);
    // Cash account: warm amber-green gradient, always — no PNG, no institution.
    final isCash = widget.source.accountType == AccountType.cash;
    const cashColor = Color(0xFF16A34A); // green-600
    // Placeholder uses neutral grayscale to hint "no bank visual yet" — once
    // a custom color is set or a bank PNG drops in, that wins.
    final themeFallbackCard = Color.alphaBlend(
      primary.withValues(alpha: 0.28),
      surface,
    );
    final cardColor = isCash
        ? cashColor
        : (widget.source.color != null
            ? hexToColor(widget.source.color!)
            : themeFallbackCard);

    final card = AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_enter.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - t)),
            child: child,
          ),
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AspectRatio(
          aspectRatio: 1.586, // ISO/IEC 7810 ID-1 (credit card)
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _bankAssetExists == true
                    ? Image.asset(
                        _resolvedAssetPath(),
                        fit: BoxFit.cover,
                      )
                    : _GradientCard(color: cardColor),
                // Subtle dark scrim for legibility on bright assets.
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0x00000000),
                        const Color(0x00000000),
                        const Color(0xFF000000).withValues(alpha: 0.35),
                      ],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 2,
                              children: [
                                Row(
                                  spacing: 4,
                                  children: [
                                    ScopePill(
                                      kind: widget.source.isShared
                                          ? ScopeKind.shared
                                          : ScopeKind.personal,
                                    ),
                                    Text(
                                      widget.source.accountType.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.body(
                                        fontSize: 11,
                                        color: CupertinoColors.white
                                            .withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${widget.source.currentBalance.toStringAsFixed(2)} ${widget.source.currency}',
                                  style: AppFonts.numeric(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // _StatusChip(
                          //   balance: widget.source.currentBalance,
                          //   trend30d: widget.trend30d,
                          //   surface: surface,
                          //   fg: fg,
                          //   muted: muted,
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      // Only wrap in a Hero when an explicit tag is supplied. The same account
      // can be on-screen in multiple places (dashboard + list) within one route
      // subtree, so a shared default tag throws "multiple heroes share tag".
      child: widget.heroTag != null
          ? Hero(tag: widget.heroTag!, child: card)
          : card,
    );
  }
}

class _GradientCard extends StatelessWidget {
  final Color color;
  const _GradientCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            ui.Color.lerp(color, const Color(0xFF000000), 0.22) ?? color,
          ],
        ),
      ),
    );
  }
}
