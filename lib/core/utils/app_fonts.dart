import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Space Grotesk — titles, headings, large numbers (h1–h3 scale)
/// Space Mono — body text, labels, captions
abstract final class AppFonts {
  // Heading weights
  static TextStyle heading({
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double? height,
    List<FontFeature>? fontFeatures,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing ?? -0.02 * fontSize,
        height: height,
        fontFeatures: fontFeatures,
      );

  // Body / mono
  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
    List<FontFeature>? fontFeatures,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing ?? -0.01 * fontSize,
        height: height,
        fontFeatures: fontFeatures,
      );

  // Numeric mono (tabular)
  static TextStyle numeric({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: -0.02 * fontSize,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // Label / caption
  static TextStyle label({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? letterSpacing,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Section header (all-caps)
  static TextStyle sectionLabel({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.1,
      );
}
