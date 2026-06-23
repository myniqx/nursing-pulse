import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/weight_entry.dart';
import '../app_theme.dart';
import 'np_card.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.weights});

  final List<WeightEntry> weights;

  @override
  Widget build(BuildContext context) {
    // Need at least 2 points for a line
    if (weights.length < 2) {
      return NpCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.stackLg),
            child: Text(
              'Add at least 2 weight entries to see the chart',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    // Sort ascending by date for chart
    final sorted = [...weights]..sort((a, b) => a.date.compareTo(b.date));

    final spots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.grams / 1000);
    }).toList();

    final minY =
        (sorted.map((w) => w.grams).reduce((a, b) => a < b ? a : b) / 1000) -
        0.1;
    final maxY =
        (sorted.map((w) => w.grams).reduce((a, b) => a > b ? a : b) / 1000) +
        0.1;

    final n = sorted.length;
    final labelStep = (n / 8).ceil().clamp(1, n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight Progress',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        NpCard(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.stackLg,
            AppSpacing.stackLg,
            AppSpacing.stackLg,
            AppSpacing.stackSm,
          ),
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.outlineVariant.withValues(alpha: 0.40),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toStringAsFixed(1)}kg',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= sorted.length) {
                          return const SizedBox.shrink();
                        }
                        // Only show label every labelStep points
                        if (idx % labelStep != 0 && idx != sorted.length - 1) {
                          return const SizedBox.shrink();
                        }
                        final dt = sorted[idx].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${dt.day}/${dt.month}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceContainerLowest,
                    tooltipRoundedRadius: AppRadius.md,
                    tooltipBorder: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                      final idx = s.x.toInt().clamp(0, sorted.length - 1);
                      final dt = sorted[idx].date;
                      final dateStr = '${dt.day}/${dt.month}/${dt.year}';
                      return LineTooltipItem(
                        '${s.y.toStringAsFixed(2)} kg\n',
                        Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: AppColors.primary,
                        ),
                        children: [
                          TextSpan(
                            text: dateStr,
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: n <= 10,
                      getDotPainter: (spot, xIndex, bar, isFirst) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.surfaceContainerLowest,
                            strokeWidth: 2,
                            strokeColor: AppColors.primary,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
