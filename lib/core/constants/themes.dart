import 'package:flutter/material.dart';

enum ThemeType { light, dark, system }

/// Chart-specific theme
class MyChartTheme {
  final List<String> series;

  final String positive;
  final String negative;
  final String neutral;

  final String grid;
  final String axis;

  final String tooltipBackground;
  final String tooltipText;

  const MyChartTheme({
    required this.series,
    required this.positive,
    required this.negative,
    required this.neutral,
    required this.grid,
    required this.axis,
    required this.tooltipBackground,
    required this.tooltipText,
  });
}

/// Main app theme
class MyTheme {
  final String primaryColor;
  final String onPrimaryColor;

  final String backgroundColor;
  final String onBackgroundColor;

  final String surfaceColor;
  final String onSurfaceColor;

  final String colorGreen;
  final String colorRed;
  final String onRedColor;

  final String colorOrange;

  final String inactiveColor;
  final String onInactiveColor;

  final String outlineColor;
  final String shadow;

  // Dashboard / design-system extras
  final String surface2Color;
  final String borderColor;
  final String incomeSoft;
  final String expenseSoft;
  final List<String> categoryTints;

  final MyChartTheme chart;

  const MyTheme({
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.backgroundColor,
    required this.onBackgroundColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.colorGreen,
    required this.colorRed,
    required this.onRedColor,
    required this.colorOrange,
    required this.inactiveColor,
    required this.onInactiveColor,
    required this.outlineColor,
    required this.shadow,
    required this.surface2Color,
    required this.borderColor,
    required this.incomeSoft,
    required this.expenseSoft,
    required this.categoryTints,
    required this.chart,
  });
}

const Map<ThemeType, MyTheme> themes = {
  ThemeType.light: MyTheme(
    primaryColor: '#0077B6',
    onPrimaryColor: '#FFFFFF',
    backgroundColor: '#F7FAFC',
    onBackgroundColor: '#0F172A',
    surfaceColor: '#FFFFFF',
    onSurfaceColor: '#0F172A',
    colorGreen: '#22C55E',
    colorRed: '#EF4444',
    onRedColor: '#FFFFFF',
    colorOrange: '#F59E0B',
    inactiveColor: '#E2E8F0',
    onInactiveColor: '#475569',
    outlineColor: '#CBD5E1',
    shadow: '#000000',
    surface2Color: '#F1F5F9',
    borderColor: '#E2E8F0',
    incomeSoft: '#22C55E14',
    expenseSoft: '#EF444414',
    categoryTints: [
      '#8B7AE6',
      '#E6B87A',
      '#7AAFE6',
      '#7AD4C1',
      '#E67AB8',
      '#8DD47A',
    ],
    chart: MyChartTheme(
      series: [
        '#00B4D8',
        '#22C55E',
        '#F59E0B',
        '#EF4444',
        '#6366F1',
      ],
      positive: '#22C55E',
      negative: '#EF4444',
      neutral: '#94A3B8',
      grid: '#E2E8F0',
      axis: '#334155',
      tooltipBackground: '#0F172A',
      tooltipText: '#FFFFFF',
    ),
  ),
  ThemeType.dark: MyTheme(
    primaryColor: '#0077B6',
    onPrimaryColor: '#FFFFFF',
    backgroundColor: '#0B0F14',
    onBackgroundColor: '#E6EAF0',
    surfaceColor: '#141A22',
    onSurfaceColor: '#E6EAF0',
    colorGreen: '#34D399',
    colorRed: '#F87171',
    onRedColor: '#FFFFFF',
    colorOrange: '#F59E0B',
    inactiveColor: '#1F2733',
    onInactiveColor: '#8A94A3',
    outlineColor: '#1F2733',
    shadow: '#000000',
    surface2Color: '#1A2230',
    borderColor: '#1F2733',
    incomeSoft: '#34D39914',
    expenseSoft: '#F8717114',
    categoryTints: [
      '#8B7AE6',
      '#E6B87A',
      '#7AAFE6',
      '#7AD4C1',
      '#E67AB8',
      '#8DD47A',
    ],
    chart: MyChartTheme(
      series: [
        '#00B4D8',
        '#22C55E',
        '#F59E0B',
        '#EF4444',
        '#818CF8',
      ],
      positive: '#22C55E',
      negative: '#EF4444',
      neutral: '#475569',
      grid: '#1E293B',
      axis: '#CBD5F5',
      tooltipBackground: '#111827',
      tooltipText: '#FFFFFF',
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
