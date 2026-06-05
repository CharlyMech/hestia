import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/spring_physics.dart';

/// A named action shown on a [PressableCard].
class CardAction {
  final Widget icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

/// Agnostic card with optional action buttons and spring-scale tap animation.
/// Content is fully agnostic — pass any [child].
/// Actions are shown as a row of icon+label buttons below or trailing the child.
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final List<CardAction> actions;
  final Color? surface;
  final Color? border;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.actions = const [],
    this.surface,
    this.border,
    this.borderRadius,
    this.padding,
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
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
    if (widget.onTap == null) return;
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _onTapDown : null,
        onTapUp: widget.onTap != null ? _onTapUp : null,
        onTapCancel: widget.onTap != null ? _onTapCancel : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            border: widget.border != null
                ? Border.all(color: widget.border!, width: 0.8)
                : null,
          ),
          padding: widget.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.child,
              if (widget.actions.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: widget.actions
                      .map(
                        (a) => Expanded(
                          child: GestureDetector(
                            onTap: a.onTap,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 4,
                                children: [
                                  a.icon,
                                  Text(
                                    a.label,
                                    style: AppFonts.body(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: a.color ??
                                          CupertinoColors.secondaryLabel
                                              .resolveFrom(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
