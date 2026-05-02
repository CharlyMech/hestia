# The CLI

Reference CLI Generate themes and styles in your project with Forui's CLI.

Forui includes a CLI that generates themes and styles in your project. These themes and styles can be directly modified to fit your design needs. No additional installation is required. Neither does the CLI increase your application's bundle size.

init Use the init command to create forui.yaml and main.dart files in your project's directory.

dart run forui init

Usage: forui init -h, --help Print this usage information. -f, --force Overwrite existing files if they exist. -t, --template The main.dart template to generate. [basic (default), router] snippet create Use the snippet create command to generate a code snippet in your project. The snippets are generated in lib by default.

dart run forui snippet create [snippets]

Usage: forui snippet create [snippets] -h, --help Print this usage information. -f, --force Overwrite existing files if they exist. -o, --output The output directory or file, relative to the project directory. (defaults to "lib") ls Use the snippet ls command to list all available snippets.

dart run forui snippet ls

Usage: forui snippet ls -h, --help Print this usage information. style create Use the style create command to generate a style in your project. The styles are generated in lib/theme by default.

See the docs on how to use the generated styles.

dart run forui style create [styles]

Usage: forui style create [styles] -h, --help Print this usage information. -a, --all Create all styles. -f, --force Overwrite existing files if they exist. -o, --output The output directory or file, relative to the project directory. (defaults to "lib/theme") ls Use the style ls command to list all available styles.

dart run forui style ls

Usage: forui style ls -h, --help Print this usage information. theme create Use the theme create command to generate a theme in your project. The theme is generated in lib/theme/theme.dart by default.

See the docs on how to use the generated theme.

dart run forui theme create [theme]

Usage: forui theme create [theme] -h, --help Print this usage information. -f, --force Overwrite existing files if they exist. -o, --output The output directory or file, relative to the project directory. (defaults to "lib/theme/theme.dart") ls Use the theme ls command to list all available themes.

dart run forui theme ls

Usage: forui theme ls -h, --help Print this usage information.

# Example (from pubdev)

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:forui/forui.dart';
import 'package:forui_example/sandbox.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();

  runApp(const Application());
}

List<Widget> _pages = [
  const Text('Home'),
  const Text('Categories'),
  const Text('Search'),
  const Text('Settings'),
  const Sandbox(),
];

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> with SingleTickerProviderStateMixin {
  int index = 4;
  Brightness brightness = .light;
  FPlatformVariant platform = (defaultTargetPlatform == .iOS || defaultTargetPlatform == .android) ? .iOS : .macOS;

  @override
  Widget build(BuildContext context) {
    final brightnessTheme = brightness == .light ? FThemes.zinc.light : FThemes.zinc.dark;
    final theme = platform.desktop ? brightnessTheme.desktop : brightnessTheme.touch;

    return MaterialApp(
      locale: const Locale('en', 'US'),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      theme: theme.toApproximateMaterialTheme(),
      builder: (context, child) => FTheme(
        data: theme,
        platform: platform,
        child: FToaster(child: FTooltipGroup(child: child!)),
      ),
      home: Builder(
        builder: (context) {
          return FScaffold(
            header: FHeader(
              title: const Text('Example'),
              suffixes: [
                FHeaderAction(
                  icon: Icon(platform.desktop ? FIcons.smartphone : FIcons.monitor),
                  onPress: togglePlatform,
                ),
                FHeaderAction(icon: Icon(brightness == .dark ? FIcons.sun : FIcons.moon), onPress: toggleTheme),
                FHeaderAction(icon: const Icon(FIcons.mousePointerClick), onPress: toggleWidgetInspector),
              ],
            ),
            footer: FBottomNavigationBar(
              index: index,
              onChange: (index) => setState(() => this.index = index),
              children: const [
                FBottomNavigationBarItem(icon: Icon(FIcons.house), label: Text('Home')),
                FBottomNavigationBarItem(icon: Icon(FIcons.layoutGrid), label: Text('Grid')),
                FBottomNavigationBarItem(icon: Icon(FIcons.search), label: Text('Search')),
                FBottomNavigationBarItem(icon: Icon(FIcons.settings), label: Text('Settings')),
                FBottomNavigationBarItem(icon: Icon(FIcons.castle), label: Text('Sandbox')),
              ],
            ),
            child: _pages[index],
          );
        },
      ),
    );
  }

  void togglePlatform() => setState(() => platform = platform.desktop ? .iOS : .macOS);

  void toggleTheme() => setState(() => brightness = brightness == .light ? .dark : .light);

  void toggleWidgetInspector() => setState(() {
    final binding = WidgetsBinding.instance;
    binding.debugShowWidgetInspectorOverride = !binding.debugShowWidgetInspectorOverride;
  });
}
```

# Widgets

Widgets Forui provides the following widgets:

- Layout
   - Divider
   - Resizable
   - Scaffold
- Form
   - Autocomplete
   - Button
   - Checkbox
   - Date
   - Field
   - Label
   - Picker
   - Radio
   - Multi-select
   - OTP Field
   - Select
   - Select
   - Group
   - Slider
   - Switch
   - Text Field
   - Text Form Field
   - Time Field
   - Time Picker
- Date Presentation
   - Accordion
   - Avatar
   - Badge
   - Calendar
   - Card
   - Item
   - Item Group
   - Line Calendar
- Tile
   - Tile
   - Tile Group
   - Select Tile Group
   - Select Menu Tile
- Navigation
   - Bottom Navigation Bar
   - Breadcrumb
   - Header
   - Pagination
   - Sidebar
   - Tabs
- Feedback
   - Alert
   - Progress
- Overlay
   - Dialog
   - Sheet
   - Persistent Sheet
   - Popover
   - Popover Menu
   - Tooltip
   - Toast/Sonner
- Foundation
   - Collapsible
   - Focused Outline
   - Portal Tappable

# Example of widget: Divider

Divider Visually or semantically separates content.

API Reference Preview Code

```dart
@override
Widget build(BuildContext _) {
  final colors = theme.colors;
  final text = theme.typography;

  return Column(
    mainAxisAlignment: .center,
    mainAxisSize: .min,
    children: [
      Text(
        'Flutter Forui',
        style: text.xl2.copyWith(color: colors.foreground, fontWeight: .w600),
      ),
      Text(
        'An open-source widget library.',
        style: text.sm.copyWith(color: colors.mutedForeground),
      ),
      const FDivider(),
      SizedBox(
        height: 30,
        child: Row(
          mainAxisAlignment: .center,
          mainAxisSize: .min,
          children: [
            Text('Blog', style: text.sm.copyWith(color: colors.foreground)),
            const FDivider(axis: .vertical),
            Text('Docs', style: text.sm.copyWith(color: colors.foreground)),
            const FDivider(axis: .vertical),
            Text('Source', style: text.sm.copyWith(color: colors.foreground)),
          ],
        ),
      ),
    ],
  );
}

```

CLI To generate a specific style for customization:

Dividers

```bash
dart run forui style create dividers
```

Usage

`FDivider(...)`

```dart
FDivider(
  style: .delta(padding: .value(.zero)),
  axis: .horizontal,
)
```

(ALL COMPONENTS WORK THE SAME WAY)

# Links

> [Pubdev](https://pub.dev/packages/forui)

> [API pubdev latest](https://pub.dev/documentation/forui/latest/)
