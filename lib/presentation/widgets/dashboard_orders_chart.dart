import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/repositories/report_repository.dart';

class DashboardOrdersChart extends StatelessWidget {
  final List<DailyRevenue> data;
  final Color color;

  const DashboardOrdersChart({
    super.key,
    required this.data,
    this.color = AppColors.statusConfirmed,
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
            'لا توجد بيانات طلبات متوفرة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.outline,
            ),
          ),
        ),
      );
    }

    final maxCount = data
        .map((d) => d.orderCount.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final yMax = maxCount > 0 ? maxCount * 1.2 : 10.0;
    final yInterval = (yMax / 4).toDouble();

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: yMax,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (value) => FlLine(
                color:
                    (isDark ? AppColors.darkDivider : AppColors.outlineVariant)
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
                  interval:
                      data.length > 7 ? (data.length / 4).ceilToDouble() : 1.0,
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
                  reservedSize: 36,
                  interval: yInterval > 0 ? yInterval : 1,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Center(
                        child: Text(
                          value.toInt().toString(),
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
            barGroups: data.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.orderCount.toDouble(),
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.6),
                        color,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: data.length > 14 ? 8 : 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.sm),
                    ),
                  ),
                ],
              );
            }).toList(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor:
                    isDark ? AppColors.darkCard : AppColors.inverseSurface,
                tooltipRoundedRadius: AppRadius.md,
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()} طلب',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
