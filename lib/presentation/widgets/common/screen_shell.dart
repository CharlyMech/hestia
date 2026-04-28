import 'package:flutter/cupertino.dart';

/// Bare scrollable screen body. Used by tab pages (where the parent
/// `MainTabShell` provides the nav bar) and by sub-pages (no nav).
///
/// Set [bottomPadding] to make room for an external floating nav bar.
class ScreenShell extends StatelessWidget {
  final Color bg;
  final List<Widget> slivers;
  final double bottomPadding;

  const ScreenShell({
    super.key,
    required this.bg,
    required this.slivers,
    this.bottomPadding = 110,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            ...slivers,
            SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
          ],
        ),
      ),
    );
  }
}
