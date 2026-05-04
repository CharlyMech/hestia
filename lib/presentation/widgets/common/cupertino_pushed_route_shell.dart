import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show NavArrowLeft;

/// Fixed iOS-style top row for pushed stack routes: plain back chevron (no
/// bordered button), bottom hairline, light shadow; body scrolls underneath.
class CupertinoPushedRouteShell extends StatelessWidget {
  const CupertinoPushedRouteShell({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.child,
    this.titleText,
    this.title,
    this.trailing,
    this.onBack,
    this.topPadding = const EdgeInsets.fromLTRB(2, 2, 12, 10),
  }) : assert(
          title == null || titleText == null,
          'Use only one of title or titleText',
        );

  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final Widget child;
  final String? titleText;
  final Widget? title;
  final Widget? trailing;
  final VoidCallback? onBack;
  final EdgeInsets topPadding;

  @override
  Widget build(BuildContext context) {
    void goBack() {
      if (onBack != null) {
        onBack!();
      } else {
        context.pop();
      }
    }

    final Widget middle = title ??
        (titleText != null
            ? Text(
                titleText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              )
            : const SizedBox.shrink());

    return ColoredBox(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: foregroundColor.withValues(alpha: 0.07),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Padding(
                padding: topPadding,
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 40),
                      onPressed: goBack,
                      child: NavArrowLeft(
                        width: 20,
                        height: 20,
                        color: foregroundColor,
                      ),
                    ),
                    Expanded(child: middle),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
