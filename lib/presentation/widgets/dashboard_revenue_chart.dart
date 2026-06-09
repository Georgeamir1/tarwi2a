import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/repositories/report_repository.dart';

class DashboardRevenueChart extends StatelessWidget {
  final List<DailyRevenue> data;
  final Color color;

  const DashboardRevenueChart({
    super.key,
    required this.data,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (data.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'لا توجد بيانات مبيعات متوفرة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.outline,
            ),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].revenue));
    }

    final maxY = data.map((d) => d.revenue).reduce((a, b) => a > b ? a : b);
    final yInterval = (maxY > 0 ? (maxY / 4) : 1.0).toDouble();

    String formatY(double value) {
      if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K ج';
      return '${value.toInt()} ج';
    }

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm, right: AppSpacing.xs),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY > 0 ? maxY * 1.15 : 100,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (value) => FlLine(
                color: (isDark ? AppColors.darkDivider : AppColors.outlineVariant)
                    .withValues(alpha: 0.4),
                strokeWidth: 0.5,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: data.length > 7
                      ? (data.length / 4).ceilToDouble()
                      : 1.0,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i >= 0 && i < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          '${data[i].date.day}/${data[i].date.month}',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Cairo',
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Center(
                        child: Text(
                          formatY(value),
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'Cairo',
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: color,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: data.length <= 10,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: color,
                      strokeColor: Colors.white,
                      strokeWidth: 1.5,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.22),
                      color.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor:
                    isDark ? AppColors.darkCard : AppColors.inverseSurface,
                tooltipRoundedRadius: AppRadius.md,
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toInt()} ج.م',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    );
                  }).toList();
                },
              ),
              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: color.withValues(alpha: 0.3),
                      strokeWidth: 1.5,
                      dashArray: [4, 4],
                    ),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: color,
                          strokeColor: Colors.white,
                          strokeWidth: 2,
                        );
                      },
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

