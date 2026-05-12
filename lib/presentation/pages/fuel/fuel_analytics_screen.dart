import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/core/constants/app_constants.dart';
import 'package:hestia/core/utils/app_fonts.dart';
import 'package:hestia/core/utils/theme_utils.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/fuel/fuel_bloc.dart';
import 'package:hestia/presentation/widgets/common/cupertino_pushed_route_shell.dart';
import 'package:hestia/presentation/widgets/common/screen_shell.dart';

class FuelAnalyticsScreen extends StatelessWidget {
  final String carId;
  const FuelAnalyticsScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FuelBloc(AppDependencies.instance.fuelEntryRepository)
        ..add(FuelLoad(carId)),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.myTheme;
    final bg = _c(theme.backgroundColor);
    final surface = _c(theme.surfaceColor);
    final border = _c(theme.borderColor);
    final fg = _c(theme.onBackgroundColor);
    final muted = _c(theme.onInactiveColor);
    final accent = _c(theme.primaryColor);

    return CupertinoPushedRouteShell(
      backgroundColor: bg,
      navBackground: surface,
      borderColor: border,
      foregroundColor: fg,
      titleText: l10n.cars_analyticsTitle,
      child: ScreenShell(
        bg: bg,
        bottomPadding: 32,
        slivers: [
          SliverToBoxAdapter(
            child: BlocBuilder<FuelBloc, FuelState>(
              builder: (context, state) {
                if (state is FuelLoading || state is FuelInitial) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }
                if (state is FuelError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(state.message,
                        style: AppFonts.body(fontSize: 13, color: muted)),
                  );
                }
                final loaded = state as FuelLoaded;
                final a = loaded.analytics;
                if (loaded.entries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text('No data yet',
                          style: AppFonts.body(fontSize: 13, color: muted)),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _Kpi(
                              label: 'Avg L/100km',
                              value: a.avgLPer100Km != null
                                  ? a.avgLPer100Km!.toStringAsFixed(1)
                                  : '—',
                              surface: surface,
                              fg: fg,
                              muted: muted,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _Kpi(
                              label: 'Cost / km',
                              value: a.costPerKm != null
                                  ? '${a.costPerKm!.toStringAsFixed(3)} €'
                                  : '—',
                              surface: surface,
                              fg: fg,
                              muted: muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _Kpi(
                        label: 'Last 30 days',
                        value: '${a.last30dTotal.toStringAsFixed(2)} €',
                        surface: surface,
                        fg: fg,
                        muted: muted,
                      ),
                      const SizedBox(height: 18),
                      Text('CONSUMPTION (L/100KM)',
                          style: AppFonts.sectionLabel(color: muted)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 18, 14, 8),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                        ),
                        child: SizedBox(
                          height: 180,
                          child: a.consumptionPoints.length < 2
                              ? Center(
                                  child: Text(
                                    'Need at least 2 full tanks',
                                    style: AppFonts.body(
                                        fontSize: 12, color: muted),
                                  ),
                                )
                              : LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (_) =>
                                          FlLine(color: border, strokeWidth: 1),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 28,
                                          getTitlesWidget: (v, _) => Text(
                                            v.toStringAsFixed(0),
                                            style: AppFonts.numeric(
                                                fontSize: 9, color: muted),
                                          ),
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(),
                                      topTitles: const AxisTitles(),
                                      bottomTitles: const AxisTitles(),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: [
                                          for (var i = 0;
                                              i < a.consumptionPoints.length;
                                              i++)
                                            FlSpot(
                                                i.toDouble(),
                                                a.consumptionPoints[i]
                                                    .lPer100km),
                                        ],
                                        isCurved: true,
                                        color: accent,
                                        barWidth: 2,
                                        dotData: const FlDotData(show: true),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('MONTHLY COST',
                          style: AppFonts.sectionLabel(color: muted)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 18, 14, 14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                        ),
                        child: SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) =>
                                    FlLine(color: border, strokeWidth: 1),
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (v, _) => Text(
                                      v.toStringAsFixed(0),
                                      style: AppFonts.numeric(
                                          fontSize: 9, color: muted),
                                    ),
                                  ),
                                ),
                                rightTitles: const AxisTitles(),
                                topTitles: const AxisTitles(),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    getTitlesWidget: (v, _) {
                                      final i = v.toInt();
                                      if (i < 0 || i >= a.monthlyCost.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final m = a.monthlyCost[i].month;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${m.month}/${m.year % 100}',
                                          style: AppFonts.numeric(
                                              fontSize: 9, color: muted),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                for (var i = 0; i < a.monthlyCost.length; i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: a.monthlyCost[i].total,
                                        color: accent,
                                        width: 14,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _c(String hex) => Color(int.parse(hex.replaceFirst('#', '0xff')));
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final Color surface;
  final Color fg;
  final Color muted;
  const _Kpi({
    required this.label,
    required this.value,
    required this.surface,
    required this.fg,
    required this.muted,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppFonts.sectionLabel(color: muted)),
          const SizedBox(height: 6),
          Text(value,
              style: AppFonts.numeric(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: fg,
              )),
        ],
      ),
    );
  }
}
