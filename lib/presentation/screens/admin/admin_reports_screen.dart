import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_reports_cubit.dart';
import '../../../domain/repositories/report_repository.dart';
import '../../../core/utils/csv_exporter.dart';
import '../../../core/utils/report_date_range.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_button.dart';
import '../../widgets/time_filter_chips.dart';
import '../../widgets/dashboard_revenue_chart.dart';
import '../../widgets/dashboard_orders_chart.dart';
import '../../widgets/dashboard_top_products_chart.dart';

import '../../../core/di/injection_container.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminReportsCubit>(
      create: (context) {
        final cairoToday = ReportDateRange.nowInCairo();
        return sl<AdminReportsCubit>()
          ..loadReports(
            startDate: cairoToday.subtract(const Duration(days: 7)),
            endDate: cairoToday,
          );
      },
      child: const _ReportsBody(),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminReportsCubit, AdminReportsState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AdminReportsStatus.error &&
          current.data != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.failure?.message ?? 'فشل تحديث البيانات',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      },
      child: BlocBuilder<AdminReportsCubit, AdminReportsState>(
        builder: (context, state) {
          final data = state.data;
          return Scaffold(
            appBar: AppTopBar(
              title: 'التقارير المالية',
              variant: TopBarVariant.withBack,
              actions: data != null
                  ? [
                      Builder(
                        builder: (btnContext) => IconButton(
                          icon: const Icon(Icons.share_rounded),
                          tooltip: 'تصدير CSV',
                          onPressed: () async {
                            final csv = exportToCsv(
                              reportsToCsvRows(data),
                              ['date', 'revenue', 'orders'],
                            );
                            final renderBox =
                                btnContext.findRenderObject() as RenderBox?;
                            final origin = renderBox != null
                                ? renderBox.localToGlobal(Offset.zero) &
                                    renderBox.size
                                : null;
                            try {
                              await Share.share(
                                csv,
                                subject: 'تقرير المبيعات',
                                sharePositionOrigin: origin,
                              );
                            } catch (_) {
                              // User cancellation or platform share failure handled gracefully
                            }
                          },
                        ),
                      ),
                    ]
                  : null,
            ),
            body: Stack(
              children: [
                if (data != null)
                  _ReportsContent(data: data)
                else if (state.status == AdminReportsStatus.loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (state.status == AdminReportsStatus.error)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 48,
                          ),
                          AppSpacing.gapH16,
                          Text(
                            state.failure?.message ??
                                'حدث خطأ في تحميل التقارير',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.gapH24,
                          AppButton(
                            label: 'إعادة المحاولة',
                            onPressed: () =>
                                context.read<AdminReportsCubit>().loadReports(
                                      startDate: state.startDate,
                                      endDate: state.endDate,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (state.status == AdminReportsStatus.loading && data != null)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportsContent extends StatefulWidget {
  final ReportData data;

  const _ReportsContent({required this.data});

  @override
  State<_ReportsContent> createState() => _ReportsContentState();
}

enum _ChartType { revenue, orders, products }

class _ReportsContentState extends State<_ReportsContent> {
  TimeFilter _selectedFilter = TimeFilter.week;
  _ChartType _selectedChartType = _ChartType.revenue;

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K ج';
    }
    return '${value.toInt()} ج';
  }

  void _onFilterChanged(TimeFilter filter) {
    if (filter == TimeFilter.custom) {
      setState(() {
        _selectedFilter = filter;
      });
      _selectCustomDateRange();
      return;
    }

    setState(() {
      _selectedFilter = filter;
    });

    final cairoToday = ReportDateRange.nowInCairo();
    DateTime start;
    DateTime end = cairoToday;

    switch (filter) {
      case TimeFilter.today:
        start = cairoToday;
        break;
      case TimeFilter.week:
        start = cairoToday.subtract(const Duration(days: 7));
        break;
      case TimeFilter.month:
        start = cairoToday.subtract(const Duration(days: 30));
        break;
      case TimeFilter.quarter:
        start = cairoToday.subtract(const Duration(days: 90));
        break;
      case TimeFilter.custom:
        return;
    }

    context.read<AdminReportsCubit>().updateDateRange(start, end);
  }

  Future<void> _selectCustomDateRange() async {
    final state = context.read<AdminReportsCubit>().state;
    final cairoToday = ReportDateRange.nowInCairo();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: cairoToday.add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: state.startDate,
        end: state.endDate,
      ),
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.darkSurface : AppColors.surface,
              onSurface:
                  isDark ? AppColors.darkTextPrimary : AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null && mounted) {
      context.read<AdminReportsCubit>().updateDateRange(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cubitState = context.watch<AdminReportsCubit>().state;

    final formattedRange =
        '${_formatDate(cubitState.startDate)}  -  ${_formatDate(cubitState.endDate)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          TimeFilterChips(
            selected: _selectedFilter,
            onChanged: _onFilterChanged,
          ),
          AppSpacing.gapH8,
          GestureDetector(
            onTap: () {
              if (_selectedFilter == TimeFilter.custom) {
                _selectCustomDateRange();
              }
            },
            child: Row(
              children: [
                Icon(
                  Icons.date_range_rounded,
                  size: 14,
                  color:
                      isDark ? AppColors.darkTextSecondary : AppColors.outline,
                ),
                AppSpacing.gapW8,
                Text(
                  formattedRange,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_selectedFilter == TimeFilter.custom) ...[
                  AppSpacing.gapW8,
                  const Icon(
                    Icons.edit_calendar_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.gapH20,

          // KPI Cards Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.4,
            children: [
              _buildModernKpiCard(
                title: 'إجمالي المبيعات',
                value: _formatCurrency(widget.data.totalRevenue),
                icon: Icons.trending_up_rounded,
                color: AppColors.statusReady,
                theme: theme,
                isDark: isDark,
              ),
              _buildModernKpiCard(
                title: 'متوسط الطلب',
                value: _formatCurrency(widget.data.averageOrder),
                icon: Icons.receipt_long_rounded,
                color: AppColors.secondary,
                theme: theme,
                isDark: isDark,
              ),
              _buildModernKpiCard(
                title: 'إجمالي الطلبات',
                value: widget.data.totalOrders.toString(),
                icon: Icons.shopping_bag_rounded,
                color: AppColors.statusConfirmed,
                theme: theme,
                isDark: isDark,
              ),
              _buildModernKpiCard(
                title: 'طلبات ملغية',
                value: widget.data.cancelledOrders.toString(),
                icon: Icons.cancel_rounded,
                color: AppColors.statusCancelled,
                theme: theme,
                isDark: isDark,
              ),
              _buildModernKpiCard(
                title: 'إجمالي العملاء',
                value: widget.data.totalCustomers.toString(),
                icon: Icons.people_rounded,
                color: AppColors.tertiary,
                theme: theme,
                isDark: isDark,
              ),
              _buildModernKpiCard(
                title: 'إجمالي الخصومات',
                value: _formatCurrency(widget.data.discountTotal),
                icon: Icons.discount_rounded,
                color: AppColors.statusPending,
                theme: theme,
                isDark: isDark,
              ),
            ],
          ),
          AppSpacing.gapH24,

          // Chart Card Container
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isDark
                    ? AppColors.darkDivider
                    : AppColors.outlineVariant.withValues(alpha: 0.6),
              ),
              boxShadow: const [AppShadows.card],
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التحليلات البيانية',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    _buildChartSelector(theme, isDark),
                  ],
                ),
                AppSpacing.gapH16,
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildSelectedChart(),
                ),
              ],
            ),
          ),
          AppSpacing.gapH24,

          // Ranked Top Products List
          if (widget.data.topProducts.isNotEmpty) ...[
            Text(
              'الأصناف الأكثر مبيعاً',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
              ),
            ),
            AppSpacing.gapH12,
            ..._buildRankedProductsList(theme, isDark),
          ],
          AppSpacing.gapH48,
        ],
      ),
    );
  }

  Widget _buildModernKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColors.darkDivider
              : AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
              color: isDark ? AppColors.darkTextPrimary : AppColors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSelector(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.darkBackground : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChartTab(_ChartType.revenue, 'المبيعات', isDark, theme),
          _buildChartTab(_ChartType.orders, 'الطلب', isDark, theme),
          _buildChartTab(_ChartType.products, 'الأصناف', isDark, theme),
        ],
      ),
    );
  }

  Widget _buildChartTab(
    _ChartType type,
    String label,
    bool isDark,
    ThemeData theme,
  ) {
    final isSelected = _selectedChartType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartType = type;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkCard : AppColors.surface)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontFamily: 'Cairo',
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedChart() {
    switch (_selectedChartType) {
      case _ChartType.revenue:
        return DashboardRevenueChart(
          key: const ValueKey('revenue_chart_tab'),
          data: widget.data.revenueByDay,
        );
      case _ChartType.orders:
        return DashboardOrdersChart(
          key: const ValueKey('orders_chart_tab'),
          data: widget.data.revenueByDay,
        );
      case _ChartType.products:
        return DashboardTopProductsChart(
          key: const ValueKey('products_chart_tab'),
          data: widget.data.topProducts,
        );
    }
  }

  List<Widget> _buildRankedProductsList(ThemeData theme, bool isDark) {
    final maxRevenue = widget.data.topProducts.isNotEmpty
        ? widget.data.topProducts
            .map((p) => p.revenue)
            .reduce((a, b) => a > b ? a : b)
        : 1.0;

    return widget.data.topProducts.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      final rank = index + 1;
      final relativeShare =
          maxRevenue > 0 ? (product.revenue / maxRevenue) : 0.0;

      Color rankColor;
      if (rank == 1) {
        rankColor = const Color(0xFFFFD700); // Gold
      } else if (rank == 2) {
        rankColor = const Color(0xFFC0C0C0); // Silver
      } else if (rank == 3) {
        rankColor = const Color(0xFFCD7F32); // Bronze
      } else {
        rankColor = isDark ? AppColors.darkDivider : AppColors.outlineVariant;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark
                ? AppColors.darkDivider
                : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
          boxShadow: const [AppShadows.card],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Rank Badge Circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: rankColor.withValues(alpha: rank <= 3 ? 0.22 : 0.15),
                    shape: BoxShape.circle,
                    border: rank <= 3
                        ? Border.all(color: rankColor, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: rank <= 3
                            ? (isDark
                                ? Colors.white
                                : AppColors.onSecondaryFixedVariant)
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapW12,
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      AppSpacing.gapH2,
                      Text(
                        '${product.quantity} قطعة مباعة',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                // Total Revenue for this product
                Text(
                  '${product.revenue.toInt()} ج',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            AppSpacing.gapH8,
            // Progress Bar relative to #1 product
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: relativeShare,
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.surfaceContainerLow,
                valueColor: AlwaysStoppedAnimation<Color>(
                  rank == 1
                      ? AppColors.statusReady
                      : (rank == 2
                          ? AppColors.statusConfirmed
                          : AppColors.primary),
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
