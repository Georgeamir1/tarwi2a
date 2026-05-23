import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_delivery_zones_cubit.dart';
import '../../../domain/entities/delivery_zone.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class AdminDeliveryZonesScreen extends StatelessWidget {
  const AdminDeliveryZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDeliveryZonesCubit, AdminDeliveryZonesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppTopBar(
            title: 'مناطق التوصيل',
            variant: TopBarVariant.withBack,
            leading: const SizedBox.shrink(),
            actions: [
              IconButton(
                onPressed: () => context.push('/admin/delivery-zones/create'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminDeliveryZonesState state) {
    if (state.status == AdminDeliveryZonesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.zones.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.map_outlined,
          title: 'لا توجد مناطق توصيل',
          subtitle: 'أضف مناطق التوصيل المتاحة',
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<AdminDeliveryZonesCubit>().loadZones(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: state.zones.length,
        itemBuilder: (_, index) {
          final zone = state.zones[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: zone.isActive
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.outlineVariant,
                child: Icon(
                  Icons.map,
                  color: zone.isActive
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
              title: Text(
                zone.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: zone.isActive ? null : AppColors.onSurfaceVariant,
                ),
              ),
              subtitle: Text(
                'رسوم: ${zone.fee.toStringAsFixed(2)} ج.م${zone.estimatedTime != null ? ' | ${zone.estimatedTime}' : ''}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: zone.isActive,
                    onChanged: (v) {
                      context
                          .read<AdminDeliveryZonesCubit>()
                          .toggleActive(zone.id, v);
                    },
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
              onTap: () => context.push(
                '/admin/delivery-zones/edit',
                extra: zone,
              ),
              onLongPress: () => _confirmDelete(context, zone),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, DeliveryZone zone) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف منطقة التوصيل'),
        content: Text('هل أنت متأكد من حذف منطقة "${zone.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              context.read<AdminDeliveryZonesCubit>().delete(zone.id);
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
