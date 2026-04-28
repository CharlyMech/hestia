import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/utils/app_fonts.dart';

/// Builds the Forui theme from a [MyTheme] instance.
FThemeData buildForuiTheme(MyTheme theme, {required Brightness brightness}) {
  final fg = _c(theme.onBackgroundColor);
  final muted = _c(theme.onInactiveColor);

  final colorScheme = FColorScheme(
    brightness: brightness,
    primary: _c(theme.primaryColor),
    primaryForeground: _c(theme.onPrimaryColor),
    secondary: _c(theme.inactiveColor),
    secondaryForeground: _c(theme.onInactiveColor),
    muted: _c(theme.inactiveColor),
    mutedForeground: _c(theme.onInactiveColor),
    background: _c(theme.backgroundColor),
    foreground: _c(theme.onBackgroundColor),
    destructive: _c(theme.colorRed),
    destructiveForeground: _c(theme.onRedColor),
    error: _c(theme.colorRed),
    errorForeground: _c(theme.onRedColor),
    border: _c(theme.outlineColor),
  );

  // Space Mono drives Forui widget typography; Space Grotesk applied directly
  // in custom widgets via AppFonts.heading().
  final monoFamily = GoogleFonts.spaceMono().fontFamily ?? 'SpaceMono';
  final typography = FTypography.inherit(colorScheme: colorScheme).copyWith(
    defaultFontFamily: monoFamily,
    xl: AppFonts.body(fontSize: 20, color: fg),
    xl2: AppFonts.body(fontSize: 22, color: fg),
    xl3: AppFonts.body(fontSize: 30, color: fg),
    xl4: AppFonts.body(fontSize: 36, color: fg),
    lg: AppFonts.body(fontSize: 18, color: fg),
    base: AppFonts.body(fontSize: 16, color: fg),
    sm: AppFonts.body(fontSize: 14, color: muted),
    xs: AppFonts.body(fontSize: 12, color: muted),
  );

  return FThemeData.inherit(
    colorScheme: colorScheme,
    typography: typography,
  );
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
      textStyle: AppFonts.body(fontSize: 16, color: fg),
      navTitleTextStyle: AppFonts.heading(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: fg,
      ),
      navLargeTitleTextStyle: AppFonts.heading(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: fg,
      ),
    ),
  );
}

Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
