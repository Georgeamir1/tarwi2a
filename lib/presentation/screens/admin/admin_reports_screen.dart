import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_reports_cubit.dart';
import '../../../domain/repositories/report_repository.dart';
import '../../../core/utils/csv_exporter.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_button.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/date_range_filter.dart';
import '../../widgets/dashboard_chart.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminReportsCubit>().loadReports(
              startDate: DateTime.now().subtract(const Duration(days: 7)),
              endDate: DateTime.now(),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _ReportsBody();
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminReportsCubit, AdminReportsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: const AppTopBar(
            title: 'التقارير المالية',
            variant: TopBarVariant.withBack,
          ),
          body: switch (state.status) {
            AdminReportsStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
            AdminReportsStatus.loaded => _ReportsContent(data: state.data!),
            AdminReportsStatus.error => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.failure?.message ?? 'حدث خطأ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    AppSpacing.gapH16,
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
            AdminReportsStatus.initial => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

class _ReportsContent extends StatelessWidget {
  final ReportData data;

  const _ReportsContent({required this.data});

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K ج';
    }
    return '${value.toInt()} ج';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<AdminReportsCubit, AdminReportsState>(
            builder: (context, state) => DateRangeFilter(
              startDate: state.startDate,
              endDate: state.endDate,
              onChanged: (range) {
                context.read<AdminReportsCubit>().updateDateRange(
                      range.start,
                      range.end,
                    );
              },
            ),
          ),
          AppSpacing.gapH16,
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'إجمالي المبيعات',
                  value: _formatCurrency(data.totalRevenue),
                  icon: Icons.trending_up,
                  color: AppColors.statusReady,
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: KpiCard(
                  title: 'متوسط الطلب',
                  value: _formatCurrency(data.averageOrder),
                  icon: Icons.receipt_long,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'إجمالي الطلبات',
                  value: data.totalOrders.toString(),
                  icon: Icons.shopping_bag,
                  color: AppColors.statusConfirmed,
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: KpiCard(
                  title: 'طلبات ملغية',
                  value: data.cancelledOrders.toString(),
                  icon: Icons.cancel,
                  color: AppColors.statusCancelled,
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'إجمالي العملاء',
                  value: data.totalCustomers.toString(),
                  icon: Icons.people,
                  color: AppColors.tertiary,
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: KpiCard(
                  title: 'إجمالي الخصومات',
                  value: _formatCurrency(data.discountTotal),
                  icon: Icons.discount,
                  color: AppColors.statusPending,
                ),
              ),
            ],
          ),
          AppSpacing.gapH24,
          DashboardChart(
            title: 'المبيعات اليومية',
            data: data.revenueByDay,
          ),
          if (data.topProducts.isNotEmpty) ...[
            AppSpacing.gapH24,
            Text(
              'المنتجات الأكثر مبيعاً',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AppSpacing.gapH12,
            ...data.topProducts.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _TopProductTile(product: product),
              ),
            ),
          ],
          AppSpacing.gapH24,
          AppButton(
            label: 'تصدير CSV',
            icon: Icons.download,
            variant: AppButtonVariant.secondary,
            onPressed: () {
              final csv = exportToCsv(
                reportsToCsvRows(data),
                ['date', 'revenue', 'orders'],
              );
              Share.share(csv, subject: 'تقرير المبيعات');
            },
          ),
          AppSpacing.gapH48,
        ],
      ),
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final TopProduct product;

  const _TopProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                AppSpacing.gapH4,
                Text(
                  '${product.quantity} قطعة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${product.revenue.toInt()} ج',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
