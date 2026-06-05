import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/spring_physics.dart';
import 'package:hestia/core/utils/theme_utils.dart';

/// Full-width primary action button with spring-scale tap animation.
/// Used for all create / save / confirm actions throughout the app.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Widget? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.width,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = SpringPhysics.tapScaleController(this);
    _scale = SpringPhysics.tapScaleAnimation(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed == null || widget.loading) return;
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    if (!widget.loading) widget.onPressed?.call();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = Color(int.parse(theme.primaryColor.replaceFirst('#', '0xff')));
    final fg = Color(int.parse(theme.onPrimaryColor.replaceFirst('#', '0xff')));
    final disabled = widget.onPressed == null || widget.loading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedOpacity(
          opacity: disabled ? 0.55 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: widget.width ?? double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: widget.loading
                ? CupertinoActivityIndicator(color: fg)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      if (widget.icon != null) widget.icon!,
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
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
