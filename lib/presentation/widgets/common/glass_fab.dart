import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';

/// Circular floating action button with a glass (BackdropFilter blur) effect.
/// Accent fill and border are derived from the ambient theme. Blur 22, accent
/// at 0.6 alpha, border at 0.35 alpha.
class GlassFab extends StatelessWidget {
  const GlassFab({
    super.key,
    required this.onTap,
    required this.child,
    this.size = 56.0,
  });

  final VoidCallback onTap;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final accent = hexToColor(theme.primaryColor);
    final border = hexToColor(theme.borderColor);

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
              color: accent,
              shape: BoxShape.circle,
              border: Border.all(
                color: border.withValues(alpha: 0.35),
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
