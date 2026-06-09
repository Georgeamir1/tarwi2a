import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_coupons_cubit.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/coupon.dart';
import '../../../domain/enums/coupon_type.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';
import '../../extensions/coupon_type_x.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  @override
  void initState() {
    super.initState();
    appLogger.i('📄 CouponsScreen initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<AdminCouponsCubit>();
      appLogger.i(
          '📄 CouponsScreen postFrame — status: ${cubit.state.status.name}, count: ${cubit.state.coupons.length}');
      if (cubit.state.status == AdminCouponsStatus.initial) {
        appLogger.i('📄 CouponsScreen — calling loadCoupons()');
        cubit.loadCoupons();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCouponsCubit, AdminCouponsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppTopBar(
            title: 'إدارة الكوبونات',
            variant: TopBarVariant.withBack,
            leading: const SizedBox.shrink(),
            actions: [
              IconButton(
                onPressed: () => context.push('/admin/coupons/create'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminCouponsState state) {
    if (state.status == AdminCouponsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == AdminCouponsStatus.error) {
      return Center(
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'خطأ في تحميل الكوبونات',
          subtitle: state.failure?.message ?? 'حاول مرة أخرى',
          actionLabel: 'إعادة المحاولة',
          onAction: () => context.read<AdminCouponsCubit>().loadCoupons(),
        ),
      );
    }
    if (state.coupons.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.discount_outlined,
          title: 'لا توجد كوبونات',
          subtitle: 'أضف كود خصم جديد للعملاء',
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<AdminCouponsCubit>().loadCoupons(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: state.coupons.length,
        itemBuilder: (_, index) {
          final coupon = state.coupons[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: coupon.isActive
                    ? AppColors.secondary.withValues(alpha: 0.12)
                    : AppColors.outlineVariant,
                child: Icon(
                  coupon.type.value == 'percentage'
                      ? Icons.percent
                      : Icons.attach_money,
                  color: coupon.isActive
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                ),
              ),
              title: Text(
                coupon.code,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: coupon.isActive ? null : AppColors.onSurfaceVariant,
                ),
              ),
              subtitle: Text(
                coupon.type.arabicLabel,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        coupon.type == CouponType.percentage
                            ? '${coupon.value.toStringAsFixed(0)}%'
                            : '${coupon.value.toStringAsFixed(2)} ج.م',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${coupon.usedCount} استخدام',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: coupon.isActive,
                    onChanged: (v) {
                      context
                          .read<AdminCouponsCubit>()
                          .toggleActive(coupon.id, v);
                    },
                  ),
                ],
              ),
              onTap: () => context.push(
                '/admin/coupons/edit',
                extra: coupon,
              ),
              onLongPress: () => _confirmDelete(context, coupon),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Coupon coupon) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الكوبون'),
        content: Text('هل أنت متأكد من حذف الكوبون "${coupon.code}"؟'),
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
              context.read<AdminCouponsCubit>().delete(coupon.id);
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
