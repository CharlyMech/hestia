import 'package:flutter/cupertino.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/spring_physics.dart';

/// Agnostic pressable container with Apple liquid-glass spring-bounce physics.
///
/// Wraps [child] in a [ScaleTransition] that compresses on press and springs
/// back on release. All visual properties (bg color, border, radius) are
/// optional so the widget can be used both as a bare hit-target and as a
/// fully styled button.
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  /// Border radius. Defaults to [AppRadii.full] (fully circular).
  final double borderRadius;

  /// Border color. Pass `null` (default) for no border.
  final Color? borderColor;

  /// Border stroke width. Default 2.
  final double borderWidth;

  /// Background fill. Defaults to transparent when null (bare hit-target).
  /// Pass explicitly (e.g. `hexToColor(theme.primaryColor)`) for filled buttons.
  final Color? backgroundColor;

  /// How far the widget compresses on press. Default 0.92.
  final double minScale;

  final EdgeInsetsGeometry padding;

  /// Fixed square width and height. When null, sizes to [child] + [padding].
  final double? size;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = AppRadii.full,
    this.borderColor,
    this.borderWidth = 2.0,
    this.backgroundColor,
    this.minScale = 0.92,
    this.padding = EdgeInsets.zero,
    this.size,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = SpringPhysics.tapScaleController(this);
    _scale = SpringPhysics.tapScaleAnimation(_ctrl, minScale: widget.minScale);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final backgroundColor =
        widget.backgroundColor ?? CupertinoColors.transparent;
    final Widget content = widget.size != null
        ? SizedBox(
            width: widget.size,
            height: widget.size,
            child: Padding(
              padding: widget.padding,
              child: Center(child: widget.child),
            ),
          )
        : Padding(
            padding: widget.padding,
            child: widget.child,
          );

    final button = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: widget.borderColor != null
            ? Border.all(
                color: widget.borderColor!,
                width: widget.borderWidth,
              )
            : null,
      ),
      child: content,
    );

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: button,
      ),
    );
  }
}
