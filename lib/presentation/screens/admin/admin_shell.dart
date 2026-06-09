import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_orders_cubit.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/enums/order_status.dart';

class AdminShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final pendingCount = context.select((AdminOrdersCubit c) =>
        c.state.status == AdminOrdersStatus.loaded
            ? c.state.orders
                .where((o) => o.status == OrderStatus.pending)
                .length
            : 0);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          appLogger.i('👆 Nav tap — tab index: $index');
          navigationShell.goBranch(
            index,
            initialLocation: index == currentIndex,
          );
        },
        indicatorColor: AppColors.primaryLight,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon:
                Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: pendingCount > 0
                ? Badge(
                    label: Text(
                      '$pendingCount',
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontSize: 10,
                      ),
                    ),
                    backgroundColor: AppColors.warning,
                    child: const Icon(Icons.receipt_long_outlined),
                  )
                : const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded,
                color: AppColors.primary),
            label: 'الطلبات',
          ),
          const NavigationDestination(
            icon: Icon(Icons.discount_outlined),
            selectedIcon:
                Icon(Icons.discount_rounded, color: AppColors.primary),
            label: 'كوبونات',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded, color: AppColors.primary),
            label: 'عملاء',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded, color: AppColors.primary),
            label: 'توصيل',
          ),
        ],
      ),
    );
  }
}
