import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show Xmark;

/// App-wide bottom sheet. Theme-aware, drag handle, keyboard-safe.
///
/// Height is automatic: hugs content, capped at
/// (screen height − top safe area − 32). When content exceeds that cap the
/// body scrolls. No height params needed.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
}) {
  final scrim = hexToColor(context.myTheme.shadow).withValues(alpha: 0.6);

  return showCupertinoModalPopup<T>(
    context: context,
    barrierColor: scrim,
    useRootNavigator: true,
    builder: (ctx) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: _SheetContainer(
          title: title,
          child: child,
        ),
      );
    },
  );
}

/// Shared decoration shell for all bottom sheets in the app.
///
/// Provides the rounded top corners, drag handle pill, optional close button,
/// and optional title. Reads theme colors from context — no raw Color params.
///
/// Used by both [showAppBottomSheet] (modal) and any persistent in-screen
/// draggable sheet that needs visual consistency.
class AppSheetShell extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showCloseButton;
  final ScrollController? scrollController;

  const AppSheetShell({
    super.key,
    required this.child,
    this.title,
    this.showCloseButton = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final fg = hexToColor(theme.foregroundColor);
    final border = hexToColor(theme.borderColor);
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.xxl),
        ),
        border: Border(top: BorderSide(color: border, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight;
          final bounded = maxH.isFinite;
          final compact = bounded && maxH < 72;
          final vPad = compact ? 8.0 : 12.0;
          const spacing = 4.0;
          final handleHeight = _resolveHandleHeight(
            maxHeight: maxH,
            compact: compact,
            verticalPadding: vPad,
            spacing: spacing,
          );
          final showBody = !bounded || maxH > handleHeight + 2 * vPad + spacing;

          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: vPad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: spacing,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: handleHeight,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: fg.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadii.xs),
                            ),
                          ),
                        ),
                        if (showCloseButton)
                          Positioned(
                            right: 8,
                            top: compact ? 2 : 7,
                            child: FButton.icon(
                              style: FButtonStyle.ghost,
                              onPress: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 30,
                                height: 30,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: fg.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: border.withValues(alpha: 0.95),
                                    width: 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Xmark(color: fg, width: 18, height: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (title != null && showBody)
                    Text(
                      title!,
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  if (showBody)
                    Flexible(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.only(bottom: 12 + safeBottom),
                        child: child,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Drag-handle height that fits inside [maxHeight] (e.g. collapsed
  /// [DraggableScrollableSheet] peek). Unbounded height keeps the standard 44.
  static double _resolveHandleHeight({
    required double maxHeight,
    required bool compact,
    required double verticalPadding,
    required double spacing,
  }) {
    const standard = 44.0;
    const peek = 20.0;
    if (!maxHeight.isFinite) {
      return compact ? peek : standard;
    }

    final preferred = compact ? peek : standard;
    final chrome = 2 * verticalPadding + preferred + spacing;
    if (maxHeight >= chrome) return preferred;

    return (maxHeight - 2 * verticalPadding - spacing).clamp(12.0, preferred);
  }
}

class _SheetContainer extends StatelessWidget {
  final String? title;
  final Widget child;

  const _SheetContainer({
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    // Cap: stops 32 pts below the top safe area, giving visual breathing room.
    final maxHeight = media.size.height - media.padding.top - 32;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboard),
      child: _DraggableSheetShell(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: AppSheetShell(
            title: title,
            showCloseButton: true,
            child: child,
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
  double? _sheetHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Cache the sheet height to compute a percentage threshold.
        _sheetHeight ??= c.maxHeight.isFinite ? c.maxHeight : null;
        return GestureDetector(
          onVerticalDragUpdate: (d) {
            if (d.primaryDelta == null || d.primaryDelta! <= 0) return;
            // Rubbery resistance: 60% of raw delta.
            setState(() => _dy += d.primaryDelta! * 0.6);
          },
          onVerticalDragEnd: (d) {
            final velocity = d.primaryVelocity ?? 0;
            // Require ~30% of sheet height OR sustained velocity > 1200 px/s.
            final h = _sheetHeight ?? MediaQuery.of(context).size.height * 0.5;
            final threshold = h * 0.30;
            if (_dy > threshold || velocity > 1200) {
              Navigator.of(context).pop();
              return;
            }
            setState(() => _dy = 0);
          },
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            offset: Offset(0, _dy / 800),
            child: widget.child,
          ),
        );
      },
    );
  }
}
