import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/constants/themes.dart';

/// Shared hex parser for app theme colors (e.g. '#0077B6').
Color hexToColor(String hex) =>
    Color(int.parse(hex.replaceFirst('#', '0xff')));

/// Convert MyTheme → Forui FThemeData
extension MyThemeToForui on MyTheme {
  FThemeData toFThemeData({required Brightness brightness}) {
    return FThemeData.inherit(
      colorScheme: FColorScheme(
        brightness: brightness,
        primary: hexToColor(primaryColor),
        primaryForeground: hexToColor(onPrimaryColor),
        secondary: hexToColor(surfaceColor),
        secondaryForeground: hexToColor(foregroundColor),
        muted: hexToColor(mutedColor),
        mutedForeground: hexToColor(foregroundColor),
        background: hexToColor(backgroundColor),
        foreground: hexToColor(foregroundColor),
        destructive: hexToColor(destructiveColor),
        destructiveForeground: hexToColor(onDestructiveColor),
        error: hexToColor(errorColor),
        errorForeground: hexToColor(onStatusColor),
        border: hexToColor(outlineColor),
      ),
    );
  }
}

/// Chart helpers
extension MyChartThemeParser on MyChartTheme {
  List<Color> get seriesColors => series.map(hexToColor).toList();
}

/// InheritedWidget that carries MyTheme alongside FTheme.
/// Wrap your app root with this so widgets can call context.myTheme.
class InheritedMyTheme extends InheritedWidget {
  final MyTheme theme;

  const InheritedMyTheme({
    super.key,
    required this.theme,
    required super.child,
  });

  static MyTheme of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<InheritedMyTheme>();
    assert(result != null, 'No InheritedMyTheme found in context');
    return result!.theme;
  }

  @override
  bool updateShouldNotify(InheritedMyTheme old) => theme != old.theme;
}

/// Easy access from context
extension MyThemeX on BuildContext {
  MyTheme get myTheme => InheritedMyTheme.of(this);
  MyChartTheme get chartTheme => InheritedMyTheme.of(this).chart;
}
