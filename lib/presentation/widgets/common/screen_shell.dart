import 'package:flutter/cupertino.dart';

/// Bare scrollable screen body used by tab pages and sub-pages.
///
/// Scroll viewport fills the screen edge-to-edge (no SafeArea applied here).
/// The first sliver receives a top padding equal to the status-bar height so
/// content starts below the Dynamic Island at rest; scrolling carries content
/// up under the blur overlay that the parent shell renders on top.
class ScreenShell extends StatelessWidget {
  final Color bg;
  final List<Widget> slivers;
  final double bottomPadding;
  final Future<void> Function()? onRefresh;

  const ScreenShell({
    super.key,
    required this.bg,
    required this.slivers,
    this.bottomPadding = 110,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          if (onRefresh != null)
            CupertinoSliverRefreshControl(onRefresh: onRefresh),
          SliverPadding(
            padding: EdgeInsets.only(top: topInset + 12),
            sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          ...slivers,
          SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
        ],
      ),
    );
  }
}
