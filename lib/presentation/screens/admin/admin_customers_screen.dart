import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_customers_cubit.dart';
import '../../../core/logger/app_logger.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  @override
  void initState() {
    super.initState();
    appLogger.i('📄 CustomersScreen initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<AdminCustomersCubit>();
      appLogger.i(
          '📄 CustomersScreen postFrame — status: ${cubit.state.status.name}, count: ${cubit.state.customers.length}');
      if (cubit.state.status == AdminCustomersStatus.initial) {
        appLogger.i('📄 CustomersScreen — calling loadCustomers()');
        cubit.loadCustomers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCustomersCubit, AdminCustomersState>(
      builder: (context, state) {
        return Scaffold(
          appBar: const AppTopBar(
            title: 'إدارة العملاء',
            variant: TopBarVariant.withBack,
            leading: SizedBox.shrink(),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
                child: TextField(
                  onChanged: (v) =>
                      context.read<AdminCustomersCubit>().search(v),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن عميل...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminCustomersState state) {
    if (state.status == AdminCustomersStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == AdminCustomersStatus.error) {
      return Center(
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'خطأ في تحميل العملاء',
          subtitle: state.failure?.message ?? 'حاول مرة أخرى',
          actionLabel: 'إعادة المحاولة',
          onAction: () => context.read<AdminCustomersCubit>().loadCustomers(),
        ),
      );
    }
    final display = state.filteredCustomers;
    if (display.isEmpty && state.status == AdminCustomersStatus.loaded) {
      return const Center(
        child: EmptyState(
          icon: Icons.people_outline,
          title: 'لا يوجد عملاء',
          subtitle: 'سيظهر العملاء هنا بعد أول طلب',
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<AdminCustomersCubit>().loadCustomers(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: display.length,
        itemBuilder: (_, index) {
          final customer = display[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              title: Text(
                customer.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                customer.phone ?? 'لا يوجد رقم',
                style: const TextStyle(fontSize: 13),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${customer.totalOrders} طلب',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${customer.totalSpent.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              onTap: () => context.push(
                '/admin/customers/${customer.id}',
                extra: customer,
              ),
            ),
          );
        },
      ),
    );
  }
}
