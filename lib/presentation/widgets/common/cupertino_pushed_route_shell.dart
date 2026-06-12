import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show NavArrowLeft;
import 'package:skeletonizer/skeletonizer.dart';

/// Fixed iOS-style top row for pushed stack routes: plain back chevron (no
/// bordered button), bottom hairline on [navBackground]; body scrolls underneath.
///
/// Refresh behaviour:
/// - [childIsScrollable] = false (default): the shell wraps [child] in a
///   [CustomScrollView] with a [CupertinoSliverRefreshControl] as the first
///   sliver. The child itself does NOT need to be scrollable.
/// - [childIsScrollable] = true: the caller owns the scroll view and embeds
///   [CupertinoSliverRefreshControl] as its first sliver. [onRefresh] is
///   unused in this mode.
///
/// When [isLoading] is true, [child] is wrapped in [Skeletonizer] so the
/// skeleton shimmer is shown while content loads.
class CupertinoPushedRouteShell extends StatelessWidget {
  const CupertinoPushedRouteShell({
    super.key,
    required this.backgroundColor,
    required this.navBackground,
    required this.borderColor,
    required this.foregroundColor,
    required this.child,
    this.titleText,
    this.title,
    this.trailing,
    this.onBack,
    this.onRefresh,
    this.isLoading = false,
    this.childIsScrollable = false,
    this.topPadding = const EdgeInsets.fromLTRB(2, 2, 12, 10),
  }) : assert(
          title == null || titleText == null,
          'Use only one of title or titleText',
        );

  final Color backgroundColor;
  final Color navBackground;
  final Color borderColor;
  final Color foregroundColor;
  final Widget child;
  final String? titleText;
  final Widget? title;
  final Widget? trailing;
  final VoidCallback? onBack;

  /// Pull-to-refresh callback. Used only when [childIsScrollable] is false.
  final Future<void> Function()? onRefresh;

  /// When true, shows a Skeletonizer shimmer over [child].
  final bool isLoading;

  /// When true, the caller's child already contains a scrollable with its own
  /// [CupertinoSliverRefreshControl]. The shell does not add another scroll view.
  final bool childIsScrollable;

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

    Widget body;
    if (childIsScrollable) {
      // Caller owns the scroll; just apply skeleton if needed.
      body = isLoading ? Skeletonizer(child: child) : child;
    } else {
      // Wrap in a CustomScrollView so CupertinoSliverRefreshControl works.
      body = CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          if (onRefresh != null)
            CupertinoSliverRefreshControl(onRefresh: onRefresh),
          SliverFillRemaining(
            hasScrollBody: false,
            child: ColoredBox(
              color: backgroundColor,
              child: isLoading ? Skeletonizer(child: child) : child,
            ),
          ),
        ],
      );
    }

    return ColoredBox(
      color: navBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: navBackground,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: Padding(
                padding: topPadding,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: middle,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 40),
                        onPressed: goBack,
                        child: NavArrowLeft(
                          width: 28,
                          height: 28,
                          color: foregroundColor,
                        ),
                      ),
                    ),
                    if (trailing != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: trailing!,
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: backgroundColor,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
