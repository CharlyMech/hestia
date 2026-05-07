import 'package:flutter/material.dart';

enum ThemeType { light, dark, system }

/// Chart-specific theme
class MyChartTheme {
  final List<String> series;

  const MyChartTheme({
    required this.series,
  });
}

/// Main app theme
class MyTheme {
  final String primaryColor;
  final String onPrimaryColor;

  final String backgroundColor;
  final String surfaceColor;
  final String foregroundColor;

  final String successColor;
  final String warningColor;
  final String errorColor;
  final String onStatusColor;
  final String destructiveColor;
  final String neutralColor;

  final String mutedColor;

  final String outlineColor;
  final String shadow;

  final List<String> categoryChartColors;

  final MyChartTheme chart;

  const MyTheme({
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.foregroundColor,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
    required this.onStatusColor,
    required this.destructiveColor,
    required this.neutralColor,
    required this.mutedColor,
    required this.outlineColor,
    required this.shadow,
    required this.categoryChartColors,
    required this.chart,
  });

  // Backward-compatibility aliases while callers migrate.
  String get colorGreen => successColor;
  String get colorRed => errorColor;
  String get onRedColor => onStatusColor;
  String get colorOrange => warningColor;
  String get surface2Color => surfaceColor;
  String get incomeSoft => successColor;
  String get expenseSoft => errorColor;
  String get borderColor => outlineColor;
  String get inactiveColor => mutedColor;
  String get onBackgroundColor => foregroundColor;
  String get onSurfaceColor => foregroundColor;
  String get onMutedColor => foregroundColor;
  @Deprecated('Use onMutedColor instead.')
  String get onInactiveColor => onMutedColor;
  String get onDestructiveColor => foregroundColor;
  List<String> get categoryTints => categoryChartColors;
}

const String _kStatusSuccess = '#22C55E';
const String _kStatusWarning = '#F59E0B';
const String _kStatusError = '#EF4444';
const String _kStatusNeutral = '#94A3B8';
const String _kOnStatusColor = '#FFFFFF';
const List<String> _kCategoryChartColors = [
  '#0077B6',
  '#00B4D8',
  '#8B7AE6',
  '#7AD4C1',
  '#E6B87A',
  '#E67AB8',
  '#8DD47A',
];

const Map<ThemeType, MyTheme> themes = {
  ThemeType.light: MyTheme(
    primaryColor: '#0077B6',
    onPrimaryColor: '#FFFFFF',
    backgroundColor: '#F0F2F5',
    surfaceColor: '#FFFFFF',
    foregroundColor: '#111111',
    successColor: _kStatusSuccess,
    warningColor: _kStatusWarning,
    errorColor: _kStatusError,
    onStatusColor: _kOnStatusColor,
    destructiveColor: '#DC2626',
    neutralColor: _kStatusNeutral,
    mutedColor: '#64748B',
    outlineColor: '#E2E8F0',
    shadow: '#000000',
    categoryChartColors: _kCategoryChartColors,
    chart: MyChartTheme(
      series: _kCategoryChartColors,
    ),
  ),
  ThemeType.dark: MyTheme(
    primaryColor: '#0077B6',
    onPrimaryColor: '#FFFFFF',
    backgroundColor: '#0F1117',
    surfaceColor: '#1C1F26',
    foregroundColor: '#f1f1f1',
    successColor: _kStatusSuccess,
    warningColor: _kStatusWarning,
    errorColor: _kStatusError,
    onStatusColor: _kOnStatusColor,
    destructiveColor: '#F87171',
    neutralColor: _kStatusNeutral,
    mutedColor: '#8A94A3',
    outlineColor: '#252B36',
    shadow: '#000000',
    categoryChartColors: _kCategoryChartColors,
    chart: MyChartTheme(
      series: _kCategoryChartColors,
    ),
  ),
};

MyTheme resolveTheme(ThemeType type, {Brightness? systemBrightness}) {
  if (type == ThemeType.system) {
    return systemBrightness == Brightness.dark
        ? themes[ThemeType.dark]!
        : themes[ThemeType.light]!;
  }
  return themes[type]!;
}
