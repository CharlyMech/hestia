import 'package:flutter/cupertino.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/pages/categories/categories_screen.dart';
import 'package:hestia/presentation/pages/transaction_sources/transaction_sources_screen.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/design_widgets.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  late final PageController _controller;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final bg = hexToColor(theme.backgroundColor);
    final surface = hexToColor(theme.surfaceColor);
    final border = hexToColor(theme.borderColor);
    final fg = hexToColor(theme.onBackgroundColor);
    final muted = hexToColor(theme.onInactiveColor);
    final accent = hexToColor(theme.primaryColor);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: l10n.settings_dataManagement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: SegmentedControl(
              options: [
                l10n.settings_categoriesTab,
                l10n.settings_sourcesTab,
              ],
              active: _tab,
              onChanged: (i) {
                setState(() => _tab = i);
                _goTo(i);
              },
              surface: surface,
              border: border,
              fg: fg,
              muted: muted,
              activeColor: accent,
              activeFg: CupertinoColors.white,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _tab = i),
              children: const [
                CategoriesScreen(embedded: true),
                TransactionSourcesScreen(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
