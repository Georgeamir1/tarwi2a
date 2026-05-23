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
    if (data.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('لا توجد بيانات')),
      );
    }

    final maxCount = data
        .map((d) => d.orderCount.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final yMax = maxCount * 1.3;
    final yInterval = (yMax > 0 ? yMax / 4 : 1).toDouble();

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: yMax,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: (data.length / 4).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < data.length) {
                    return Text(
                      '${data[i].date.day}/${data[i].date.month}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: yInterval,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.onSurfaceVariant),
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
                  color: color,
                  width: data.length > 14 ? 6 : 12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
