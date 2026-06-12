import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';

/// Circular floating action button with a glass (BackdropFilter blur) effect.
/// Matches the visual language of FloatingNavBar — blur 22, accent fill at 0.6
/// alpha, hairline white border at 0.25 alpha.
class GlassFab extends StatelessWidget {
  const GlassFab({
    super.key,
    required this.onTap,
    required this.accentColor,
    required this.child,
    this.size = 56.0,
  });

  final VoidCallback onTap;
  final Color accentColor;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      borderRadius: size / 2,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
