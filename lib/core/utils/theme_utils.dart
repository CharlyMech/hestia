import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/constants/themes.dart';

/// Convert MyTheme → Forui FThemeData
extension MyThemeToForui on MyTheme {
  FThemeData toFThemeData({required Brightness brightness}) {
    return FThemeData.inherit(
      colorScheme: FColorScheme(
        brightness: brightness,
        primary: _c(primaryColor),
        primaryForeground: _c(onPrimaryColor),
        secondary: _c(surfaceColor),
        secondaryForeground: _c(foregroundColor),
        muted: _c(mutedColor),
        mutedForeground: _c(foregroundColor),
        background: _c(backgroundColor),
        foreground: _c(foregroundColor),
        destructive: _c(destructiveColor),
        destructiveForeground: _c(onDestructiveColor),
        error: _c(errorColor),
        errorForeground: _c(onStatusColor),
        border: _c(outlineColor),
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

/// Chart helpers
extension MyChartThemeParser on MyChartTheme {
  List<Color> get seriesColors => series.map((c) => _c(c)).toList();

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
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
