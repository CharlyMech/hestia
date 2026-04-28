import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hestia/core/config/router.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:hestia/presentation/pages/goals/goals_screen.dart';
import 'package:hestia/presentation/pages/settings/settings_screen.dart';
import 'package:hestia/presentation/pages/transactions/transactions_screen.dart';
import 'package:hestia/presentation/widgets/dashboard/floating_nav_bar.dart';

/// Persistent tab shell that holds Dashboard / Activity / Goals / More.
///
/// Body switches via [PageView] (swipeable) while the [FloatingNavBar]
/// stays mounted, so tab changes don't rebuild the surrounding chrome.
class MainTabShell extends StatefulWidget {
  final int initialTab;

  const MainTabShell({super.key, this.initialTab = 0});

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell> {
  late final PageController _controller;
  late int _index;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab;
    _offset = widget.initialTab.toDouble();
    _controller = PageController(initialPage: widget.initialTab);
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final p = _controller.page;
    if (p == null) return;
    setState(() => _offset = p);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.myTheme;
    final bg = Color(int.parse(theme.backgroundColor.replaceFirst('#', '0xff')));

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: Stack(
        children: [
          PageView(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _index = i),
            children: const [
              DashboardScreen(),
              TransactionsScreen(),
              GoalsScreen(),
              SettingsScreen(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: FloatingNavBar(
                activeIndex: _index,
                pageOffset: _offset,
                onTab: _goTo,
                onPlus: () => context.push(AppRoutes.addTransaction),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
