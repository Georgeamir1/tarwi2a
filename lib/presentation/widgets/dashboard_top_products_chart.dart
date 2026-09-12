import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/repositories/report_repository.dart';

class DashboardTopProductsChart extends StatelessWidget {
  final List<TopProduct> data;

  const DashboardTopProductsChart({super.key, required this.data});

  static const _colors = [
    AppColors.primary,
    AppColors.statusConfirmed,
    AppColors.tertiary,
    AppColors.statusPending,
    AppColors.statusPreparing,
    AppColors.statusReady,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (data.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'لا توجد بيانات أصناف متوفرة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.outline,
            ),
          ),
        ),
      );
    }

    final total = data.fold(0.0, (sum, p) => sum + p.revenue);

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: PieChart(
                PieChartData(
                  sections: data.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    final percent = total > 0 ? (p.revenue / total * 100) : 0.0;
                    return PieChartSectionData(
                      value: p.revenue,
                      color: _colors[i % _colors.length],
                      radius: 32,
                      title: '${percent.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 3,
                  centerSpaceRadius: 36,
                ),
              ),
            ),
            AppSpacing.gapW16,
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    final percent = total > 0 ? (p.revenue / total * 100) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _colors[i % _colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppSpacing.gapW8,
                          Expanded(
                            child: Text(
                              p.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppSpacing.gapW8,
                          Text(
                            '${percent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
