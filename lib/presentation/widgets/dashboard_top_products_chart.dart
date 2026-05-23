import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/repositories/report_repository.dart';

class DashboardTopProductsChart extends StatelessWidget {
  final List<TopProduct> data;

  const DashboardTopProductsChart({super.key, required this.data});

  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.tertiary,
    AppColors.statusPending,
    AppColors.statusConfirmed,
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('لا توجد بيانات')),
      );
    }

    final total = data.fold(0.0, (sum, p) => sum + p.revenue);

    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: data.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final percent = total > 0 ? (p.revenue / total * 100) : 0.0;
                  return PieChartSectionData(
                    value: p.revenue,
                    color: _colors[i % _colors.length],
                    radius: 30,
                    title: '${percent.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 20,
              ),
            ),
          ),
          AppSpacing.gapW8,
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _colors[i % _colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.gapW8,
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
