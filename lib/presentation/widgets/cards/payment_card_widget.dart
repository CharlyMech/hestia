import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/domain/entities/payment_card.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';

/// ISO ID-1 (credit-card) style widget for a [PaymentCard].
///
/// Layout:
///   Top-left  — institution logo (Image.asset from [card.institutionLogoAsset])
///   Top-right — network badge (SVG `assets/networks/<network>.svg`, text fallback)
///   Center    — masked card number  `**** **** **** last4`
///   Bottom-left  — cardholder name
///   Bottom-right — MM/YY expiry
///   Badges    — "PRIMARY" if `isPrimary`, "VIRTUAL" if `isVirtual`
///   Owner row — shown when [card.ownerName] is not null
class PaymentCardWidget extends StatelessWidget {
  final PaymentCard card;
  final VoidCallback? onTap;

  const PaymentCardWidget({super.key, required this.card, this.onTap});

  Color get _baseColor {
    if (card.color != null) return hexToColor(card.color!);
    if (card.institutionBrandColor != null) {
      return hexToColor(card.institutionBrandColor!);
    }
    return const Color(0xFF1E293B); // slate-800 fallback
  }

  @override
  Widget build(BuildContext context) {
    final base = _baseColor;
    final dark = ui.Color.lerp(base, const Color(0xFF000000), 0.28) ?? base;

    final cardWidget = AspectRatio(
      aspectRatio: 1.586,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [base, dark],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x55000000)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (card.institutionLogoAsset != null)
                        Image.asset(
                          card.institutionLogoAsset!,
                          height: 28,
                          errorBuilder: (_, __, ___) =>
                              _InstitutionNameFallback(
                                  name: card.institutionName ?? ''),
                        )
                      else
                        _InstitutionNameFallback(
                            name: card.institutionName ?? ''),
                      _NetworkLabel(network: card.network.value),
                    ],
                  ),
                  if (card.ownerName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        card.ownerName!,
                        style: AppFonts.body(
                          fontSize: 10,
                          color: CupertinoColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    card.maskedNumber,
                    style: AppFonts.numeric(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          card.cardholderName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color:
                                CupertinoColors.white.withValues(alpha: 0.85),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EXPIRES',
                            style: AppFonts.body(
                              fontSize: 8,
                              color:
                                  CupertinoColors.white.withValues(alpha: 0.6),
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            card.expiryFormatted,
                            style: AppFonts.numeric(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Badges row (top-right area, below network label)
            Positioned(
              top: 12,
              right: 8,
              child: Row(
                spacing: 4,
                children: [
                  if (card.isPrimary) _Badge(label: 'PRIMARY'),
                  if (card.isVirtual) _Badge(label: 'VIRTUAL'),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return cardWidget;

    return AnimatedButton(onTap: onTap!, child: cardWidget);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        label,
        style: AppFonts.body(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: CupertinoColors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _InstitutionNameFallback extends StatelessWidget {
  final String name;
  const _InstitutionNameFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: AppFonts.body(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: CupertinoColors.white,
      ),
    );
  }
}

class _NetworkLabel extends StatelessWidget {
  final String network;
  const _NetworkLabel({required this.network});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        network.toUpperCase(),
        style: AppFonts.body(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: CupertinoColors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
