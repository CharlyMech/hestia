import 'package:flutter/cupertino.dart';

/// Bare scrollable screen body. Used by tab pages (where the parent
/// `MainTabShell` provides the nav bar) and by sub-pages (no nav).
///
/// Set [bottomPadding] to make room for an external floating nav bar.
/// Pass [onRefresh] to enable pull-to-refresh (Cupertino sliver).
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
    return ColoredBox(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            if (onRefresh != null)
              CupertinoSliverRefreshControl(onRefresh: onRefresh),
            ...slivers,
            SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
          ],
        ),
      ),
    );
  }
}
