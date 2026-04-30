import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';

/// App-wide bottom sheet. Theme-aware, drag handle, keyboard-safe.
///
/// `heightFactor` (0..1) caps the max height as a fraction of the screen.
/// `expand` makes the sheet take the available space inside the cap.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  double heightFactor = 0.95,
  bool expand = false,
}) {
  final theme = context.myTheme;
  final surface = _c(theme.surfaceColor);
  final fg = _c(theme.onBackgroundColor);
  final border = _c(theme.borderColor);
  final muted = _c(theme.onInactiveColor);
  final scrim = _c(theme.shadow).withValues(alpha: 0.6);

  return showCupertinoModalPopup<T>(
    context: context,
    barrierColor: scrim,
    useRootNavigator: true,
    builder: (ctx) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: _SheetContainer(
          title: title,
          heightFactor: heightFactor,
          expand: expand,
          surface: surface,
          fg: fg,
          border: border,
          muted: muted,
          child: child,
        ),
      );
    },
  );
}

class _SheetContainer extends StatelessWidget {
  final String? title;
  final double heightFactor;
  final bool expand;
  final Color surface;
  final Color fg;
  final Color border;
  final Color muted;
  final Widget child;

  const _SheetContainer({
    required this.heightFactor,
    required this.expand,
    required this.surface,
    required this.fg,
    required this.border,
    required this.muted,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.95;
    final keyboard = media.viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboard),
      child: _DraggableSheetShell(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border.all(color: border, width: 1),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 28,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Icon(CupertinoIcons.xmark, size: 16, color: fg),
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        title!,
                        style: AppFonts.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (expand) Expanded(child: child) else Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DraggableSheetShell extends StatefulWidget {
  final Widget child;
  const _DraggableSheetShell({required this.child});

  @override
  State<_DraggableSheetShell> createState() => _DraggableSheetShellState();
}

class _DraggableSheetShellState extends State<_DraggableSheetShell> {
  double _dy = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (d) {
        if (d.primaryDelta == null || d.primaryDelta! <= 0) return;
        setState(() => _dy += d.primaryDelta!);
      },
      onVerticalDragEnd: (d) {
        final velocity = d.primaryVelocity ?? 0;
        if (_dy > 120 || velocity > 900) {
          Navigator.of(context).pop();
          return;
        }
        setState(() => _dy = 0);
      },
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        offset: Offset(0, _dy / 500),
        child: widget.child,
      ),
    );
  }
}

Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
