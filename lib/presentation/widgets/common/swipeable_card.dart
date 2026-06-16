import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/utils/app_fonts.dart';

/// A single action revealed on swipe.
class SwipeAction {
  final Color color;
  final Widget icon;
  final String? label;
  final VoidCallback onTap;
  final double width;

  const SwipeAction({
    required this.color,
    required this.icon,
    required this.onTap,
    this.label,
    this.width = 100,
  });
}

/// Agnostic swipeable card wrapper.
///
/// The [child] can be any widget / height.
/// Actions slide in from left ([leftActions], revealed by swiping left) or
/// right ([rightActions], revealed by swiping right).
/// Card does NOT fly away — it stops at max action width and springs back.
/// Optional long-press shows a [FDialog] with [longPressDialogActions].
class SwipeableCard extends StatefulWidget {
  final Widget child;

  /// Revealed by swiping LEFT (actions on the right side).
  final List<SwipeAction> leftActions;

  /// Revealed by swiping RIGHT (actions on the left side).
  final List<SwipeAction> rightActions;
  final VoidCallback? onLongPress;
  final List<SwipeAction>? longPressDialogActions;
  final String? longPressDialogTitle;

  const SwipeableCard({
    super.key,
    required this.child,
    this.leftActions = const [],
    this.rightActions = const [],
    this.onLongPress,
    this.longPressDialogActions,
    this.longPressDialogTitle,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _offsetAnim;

  double _maxLeft = 0;
  double _maxRight = 0;
  double _dragStartX = 0;
  double _baseOffset = 0;

  @override
  void initState() {
    super.initState();
    _maxLeft = widget.leftActions.fold(0.0, (s, a) => s + a.width);
    _maxRight = widget.rightActions.fold(0.0, (s, a) => s + a.width);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _offsetAnim = const AlwaysStoppedAnimation(0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double get _currentOffset => _offsetAnim.value;

  void _onDragStart(DragStartDetails d) {
    _ctrl.stop();
    _dragStartX = d.localPosition.dx;
    _baseOffset = _currentOffset;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final delta = d.localPosition.dx - _dragStartX;
    final raw = _baseOffset + delta;
    final clamped = raw.clamp(-_maxLeft, _maxRight);
    setState(() => _offsetAnim = AlwaysStoppedAnimation(clamped));
  }

  void _onDragEnd(DragEndDetails d) {
    final offset = _currentOffset;
    const threshold = 0.35;

    if (_maxRight > 0 && offset > _maxRight * threshold) {
      // Full swipe right: trigger the first right action, then spring back.
      _animateTo(0);
      if (widget.rightActions.isNotEmpty) {
        widget.rightActions.first.onTap();
      }
      return;
    }
    if (_maxLeft > 0 && offset < -_maxLeft * threshold) {
      // Full swipe left: trigger the first left action, then spring back.
      _animateTo(0);
      if (widget.leftActions.isNotEmpty) {
        widget.leftActions.first.onTap();
      }
      return;
    }

    _animateTo(0);
  }

  void _animateTo(double target) {
    final begin = _currentOffset;
    _offsetAnim = Tween<double>(begin: begin, end: target).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _baseOffset = target;
    _ctrl.forward(from: 0);
    setState(() {});
  }

  void _springBack() => _animateTo(0);

  void _onLongPress() {
    if (widget.onLongPress != null) {
      widget.onLongPress!();
      return;
    }
    final actions = widget.longPressDialogActions;
    if (actions == null || actions.isEmpty) return;

    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => FDialog(
        title: widget.longPressDialogTitle != null
            ? Text(widget.longPressDialogTitle!)
            : null,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: actions
              .map(
                (a) => GestureDetector(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    a.onTap();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      spacing: 12,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: a.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: a.icon,
                        ),
                        if (a.label != null)
                          Text(
                            a.label!,
                            style: AppFonts.body(
                              fontSize: 15,
                              color: a.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          FButton(
            style: FButtonStyle.outline,
            onPress: () => Navigator.of(ctx).pop(),
            label: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLongPress = widget.onLongPress != null ||
        (widget.longPressDialogActions?.isNotEmpty ?? false);

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onLongPress: hasLongPress ? _onLongPress : null,
      onTap: _currentOffset != 0 ? _springBack : null,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final offset = _offsetAnim.value;
          return Stack(
            children: [
              // Right-side actions revealed by swiping RIGHT (offset > 0)
              if (widget.rightActions.isNotEmpty && offset > 0)
                Positioned.fill(
                  child: Row(
                    children: widget.rightActions
                        .map(
                          (a) => GestureDetector(
                            onTap: () {
                              _springBack();
                              a.onTap();
                            },
                            child: Container(
                              width: a.width,
                              color: a.color,
                              alignment: Alignment.center,
                              child: a.icon,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              // Left-side actions revealed by swiping LEFT (offset < 0)
              if (widget.leftActions.isNotEmpty && offset < 0)
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: widget.leftActions
                        .map(
                          (a) => GestureDetector(
                            onTap: () {
                              _springBack();
                              a.onTap();
                            },
                            child: Container(
                              width: a.width,
                              color: a.color,
                              alignment: Alignment.center,
                              child: a.icon,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              // Sliding card content
              Transform.translate(
                offset: Offset(offset, 0),
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }
}
