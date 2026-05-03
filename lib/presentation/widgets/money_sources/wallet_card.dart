import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/money_source.dart';
import 'package:hestia/presentation/widgets/dashboard/scope_pill.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart'
    show ArrowDown, ArrowUp;

/// Credit-card style account card. Renders the bundled bank PNG when a matching
/// asset exists at `assets/banks/<institution>.png`, else a primary-color
/// gradient placeholder. Animates a press scale and a staggered enter.
class WalletCard extends StatefulWidget {
  final MoneySource source;

  /// Index in the parent list — drives the staggered enter delay.
  final int index;

  /// Optional 30-day net change for the status indicator (positive/negative).
  final double? trend30d;

  final VoidCallback? onTap;

  /// Hero tag — defaults to source.id when null.
  final Object? heroTag;

  const WalletCard({
    super.key,
    required this.source,
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
    final inst = widget.source.institution;
    if (inst == null || inst.isEmpty) {
      if (mounted) setState(() => _bankAssetExists = false);
      return;
    }
    final path = _bankAssetPath(inst);
    try {
      await rootBundle.load(path);
      if (mounted) setState(() => _bankAssetExists = true);
    } catch (_) {
      if (mounted) setState(() => _bankAssetExists = false);
    }
  }

  String _bankAssetPath(String institution) {
    final slug = institution
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return 'assets/banks/$slug.png';
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final accent = _c(theme.primaryColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final surface = _c(theme.surfaceColor);
    final cardColor = widget.source.color != null
        ? _c(widget.source.color!)
        : accent;

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
            borderRadius: BorderRadius.circular(AppRadii.xl),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _bankAssetExists == true
                    ? Image.asset(
                        _bankAssetPath(widget.source.institution!),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.source.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                          ScopePill(
                            kind: widget.source.isShared
                                ? ScopeKind.shared
                                : ScopeKind.personal,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 2,
                              children: [
                                Text(
                                  '${widget.source.institution ?? ''} · ${widget.source.accountType.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.body(
                                    fontSize: 11,
                                    color: CupertinoColors.white.withValues(alpha: 0.85),
                                  ),
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
                          _StatusChip(
                            balance: widget.source.currentBalance,
                            trend30d: widget.trend30d,
                            surface: surface,
                            fg: fg,
                            muted: muted,
                          ),
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
      child: widget.heroTag != null
          ? Hero(tag: widget.heroTag!, child: card)
          : Hero(tag: 'wallet-${widget.source.id}', child: card),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
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
            ui.Color.lerp(color, const Color(0xFF000000), 0.35) ?? color,
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final double balance;
  final double? trend30d;
  final Color surface;
  final Color fg;
  final Color muted;

  const _StatusChip({
    required this.balance,
    required this.trend30d,
    required this.surface,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final red = Color(int.parse(theme.colorRed.replaceFirst('#', '0xff')));
    final green =
        Color(int.parse(theme.colorGreen.replaceFirst('#', '0xff')));
    final isOverdraft = balance < 0;
    final trend = trend30d ?? 0;
    final up = trend >= 0;
    final tint = isOverdraft ? red : (up ? green : red);
    final glyph = isOverdraft || !up
        ? ArrowDown(width: 12, height: 12, color: tint)
        : ArrowUp(width: 12, height: 12, color: tint);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          glyph,
          if (isOverdraft)
            Text(
              'Overdraft',
              style: AppFonts.body(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: tint,
              ),
            ),
        ],
      ),
    );
  }
}
