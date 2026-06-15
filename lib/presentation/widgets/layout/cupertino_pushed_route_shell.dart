import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/presentation/widgets/common/animated_button.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' show NavArrowLeft;
import 'package:skeletonizer/skeletonizer.dart';

/// Fixed iOS-style top row for pushed stack routes: plain back chevron (no
/// bordered button), bottom hairline on [navBackground]; body scrolls underneath.
///
/// Refresh behaviour ([onRefresh] is OPTIONAL):
/// - [childIsScrollable] = false (default): the shell wraps [child] in a
///   [CustomScrollView]. When [onRefresh] is set, a [CupertinoSliverRefreshControl]
///   is added as the first sliver; when omitted, no refresh control is added.
///   The child itself does NOT need to be scrollable.
/// - [childIsScrollable] = true: the caller owns the scroll view and embeds
///   [CupertinoSliverRefreshControl] as its first sliver. [onRefresh] is
///   unused in this mode.
///
/// When [isLoading] is true, [child] is wrapped in [Skeletonizer] so the
/// skeleton shimmer is shown while content loads. RULE: a screen that sets
/// [onRefresh] MUST also drive [isLoading] so the load shows the shimmer (not a
/// bare spinner) — pull-to-refresh and skeleton go together.
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
      // Skeletonizer wraps the entire CustomScrollView (not the child inside
      // SliverFillRemaining) to avoid intrinsic-dimension crashes when the
      // child itself contains a scrollable or viewport.
      Widget scrollView = CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          if (onRefresh != null)
            CupertinoSliverRefreshControl(onRefresh: onRefresh),
          SliverFillRemaining(
            child: ColoredBox(
              color: backgroundColor,
              child: child,
            ),
          ),
        ],
      );
      body = isLoading ? Skeletonizer(child: scrollView) : scrollView;
    }

    // CupertinoPageScaffold with resizeToAvoidBottomInset (default true) ensures
    // the body shrinks when the software keyboard appears, so fields are never
    // hidden behind the keyboard — without any per-screen workarounds.
    return CupertinoPageScaffold(
      backgroundColor: navBackground,
      resizeToAvoidBottomInset: true,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
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
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: AnimatedButton(
                          onTap: goBack,
                          size: 44,
                          borderRadius: AppRadii.full,
                          backgroundColor: CupertinoColors.transparent,
                          borderColor: CupertinoColors.transparent,
                          borderWidth: 0,
                          padding: const EdgeInsets.all(10),
                          child: NavArrowLeft(
                            width: 22,
                            height: 22,
                            color: foregroundColor,
                          ),
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
      ),
    );
  }
}
