import 'package:flutter/widgets.dart';

/// Exposes tab switching inside [MainTabShell] without pushing routes.
///
/// Descendants call [MainTabScope.select] to animate the [PageView] and nav
/// pill the same way as [FloatingNavBar].
class MainTabScope extends InheritedWidget {
  const MainTabScope({
    super.key,
    required this.selectTab,
    required this.statusBarHeight,
    required super.child,
  });

  final ValueChanged<int> selectTab;

  /// Physical top inset (Dynamic Island / notch), captured once in the shell.
  final double statusBarHeight;

  static MainTabScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainTabScope>();
  }

  /// Switches to [index] when inside the tab shell; no-op otherwise.
  static void select(BuildContext context, int index) {
    maybeOf(context)?.selectTab(index);
  }

  @override
  bool updateShouldNotify(MainTabScope old) =>
      selectTab != old.selectTab || statusBarHeight != old.statusBarHeight;
}
