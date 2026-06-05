import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/constants/themes.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';

/// Builds the Forui theme from a [MyTheme] instance.
FThemeData buildForuiTheme(MyTheme theme, {required Brightness brightness}) {
  final fg = hexToColor(theme.foregroundColor);
  final muted = hexToColor(theme.mutedColor);

  final colorScheme = FColorScheme(
    brightness: brightness,
    primary: hexToColor(theme.primaryColor),
    primaryForeground: hexToColor(theme.onPrimaryColor),
    secondary: hexToColor(theme.surfaceColor),
    secondaryForeground: hexToColor(theme.foregroundColor),
    muted: hexToColor(theme.mutedColor),
    mutedForeground: hexToColor(theme.foregroundColor),
    background: hexToColor(theme.backgroundColor),
    foreground: hexToColor(theme.foregroundColor),
    destructive: hexToColor(theme.destructiveColor),
    destructiveForeground: hexToColor(theme.onDestructiveColor),
    error: hexToColor(theme.errorColor),
    errorForeground: hexToColor(theme.onStatusColor),
    border: hexToColor(theme.outlineColor),
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

  final base = FThemeData.inherit(
    colorScheme: colorScheme,
    typography: typography,
  );

  final surface = hexToColor(theme.surfaceColor);

  final popoverDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(AppRadii.lg),
    border: Border.all(color: hexToColor(theme.borderColor), width: 0.8),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  // Forui buttons wrap child icons with FIconStyle, so icon colors come from
  // button styles (not the icon widget color). Keep these explicit and aligned
  // with app foreground for reliable contrast in custom surfaces.
  return base.copyWith(
    popoverMenuStyle: base.popoverMenuStyle.copyWith(
      decoration: popoverDecoration,
    ),
    buttonStyles: base.buttonStyles.copyWith(
      ghost: base.buttonStyles.ghost.copyWith(
        contentStyle: base.buttonStyles.ghost.contentStyle.copyWith(
          enabledTextStyle:
              base.buttonStyles.ghost.contentStyle.enabledTextStyle.copyWith(
            color: fg,
          ),
          disabledTextStyle:
              base.buttonStyles.ghost.contentStyle.disabledTextStyle.copyWith(
            color: muted,
          ),
          enabledIconColor: fg,
          disabledIconColor: muted,
        ),
        iconContentStyle: base.buttonStyles.ghost.iconContentStyle.copyWith(
          enabledColor: fg,
          disabledColor: muted,
        ),
      ),
      outline: base.buttonStyles.outline.copyWith(
        contentStyle: base.buttonStyles.outline.contentStyle.copyWith(
          enabledTextStyle:
              base.buttonStyles.outline.contentStyle.enabledTextStyle.copyWith(
            color: fg,
          ),
          disabledTextStyle:
              base.buttonStyles.outline.contentStyle.disabledTextStyle.copyWith(
            color: muted,
          ),
          enabledIconColor: fg,
          disabledIconColor: muted,
        ),
        iconContentStyle: base.buttonStyles.outline.iconContentStyle.copyWith(
          enabledColor: fg,
          disabledColor: muted,
        ),
      ),
    ),
  );
}

/// Builds the Cupertino theme from a [MyTheme] instance.
CupertinoThemeData buildCupertinoTheme(
  MyTheme theme, {
  required Brightness brightness,
}) {
  final bg = hexToColor(theme.backgroundColor);
  final surface = hexToColor(theme.surfaceColor);
  final fg = hexToColor(theme.foregroundColor);
  final primary = hexToColor(theme.primaryColor);

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
