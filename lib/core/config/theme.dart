import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/utils/theme_utils.dart';

/// Builds the Forui theme from a [MyTheme] instance.
FThemeData buildForuiTheme(MyTheme theme, {required Brightness brightness}) {
  return theme.toFThemeData(brightness: brightness);
}

/// Builds the Cupertino theme from a [MyTheme] instance.
CupertinoThemeData buildCupertinoTheme(
  MyTheme theme, {
  required Brightness brightness,
}) {
  final bg = _c(theme.backgroundColor);
  final surface = _c(theme.surfaceColor);
  final fg = _c(theme.onBackgroundColor);
  final primary = _c(theme.primaryColor);

  return CupertinoThemeData(
    brightness: brightness,
    primaryColor: primary,
    scaffoldBackgroundColor: bg,
    barBackgroundColor: surface,
    textTheme: CupertinoTextThemeData(
      primaryColor: fg,
      textStyle: TextStyle(
        fontFamily: 'Inter',
        color: fg,
        fontSize: 16,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: fg,
        fontSize: 17,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        color: fg,
        fontSize: 34,
      ),
    ),
  );
}

Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
