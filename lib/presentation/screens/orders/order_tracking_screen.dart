import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_status.dart';
import '../../../core/logger/app_logger.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/orders/customer_orders_cubit.dart';
import '../../widgets/app_top_bar.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final Order? initialOrder;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    _ensureLoaded();
  }

  void _ensureLoaded() {
    final authState = context.read<AuthCubit>().state;
    final customerId = authState is Authenticated ? authState.profile.id : '';
    if (customerId.isNotEmpty) {
      context.read<CustomerOrdersCubit>().loadOrders(customerId);
    }
  }

  int _getActiveStepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    appLogger.i('[OrderTrackingScreen] build — orderId: ${widget.orderId}');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        title: 'تتبع الطلب',
        variant: TopBarVariant.withBack,
      ),
      body: BlocBuilder<CustomerOrdersCubit, CustomerOrdersState>(
        builder: (context, state) {
          Order? order = widget.initialOrder;
          if (state.status == CustomerOrdersStatus.loaded) {
            try {
              order = state.orders.firstWhere((o) => o.id == widget.orderId);
            } catch (_) {}
          }

          if (order == null) {
            if (state.status == CustomerOrdersStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Center(
              child: Text(
                state.status == CustomerOrdersStatus.error
                    ? 'خطأ في تحميل بيانات التتبع: ${state.failure?.message}'
                    : 'الطلب غير موجود',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          final activeStep = _getActiveStepIndex(order.status);
          final isCancelled = order.status == OrderStatus.cancelled;

          return RefreshIndicator(
            onRefresh: () async {
              _ensureLoaded();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 0.8),
                      boxShadow: const [AppShadows.card],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم الطلب: #${order.id.substring(0, 8).toUpperCase()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.status == OrderStatus.delivered
                              ? 'تم توصيل الطلب بنجاح'
                              : isCancelled
                                  ? 'تم إلغاء هذا الطلب'
                                  : 'الوقت المتوقع للتوصيل: 25-35 دقيقة',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isCancelled
                                ? AppColors.error
                                : order.status == OrderStatus.delivered
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'حالة خط سير الطلب',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (isCancelled) ...[
                    // Special Cancelled State Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.cancel_rounded, color: AppColors.error, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'تم إلغاء الطلب',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تم إلغاء هذا الطلب بمعرفة المطعم أو العميل. إذا كان لديك أي استفسار، يرجى التواصل مع الدعم الفني.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Vertical Timeline steps
                    _TimelineItem(
                      icon: Icons.receipt_long_rounded,
                      title: 'تم إرسال الطلب',
                      subtitle: 'طلبك وصل للمطعم وبانتظار التأكيد',
                      isActive: activeStep >= 0,
                      isFirst: true,
                    ),
                    _TimelineItem(
                      icon: Icons.thumb_up_alt_outlined,
                      title: 'تم تأكيد الطلب',
                      subtitle: 'تمت مراجعة الطلب والموافقة عليه',
                      isActive: activeStep >= 1,
                    ),
                    _TimelineItem(
                      icon: Icons.restaurant_rounded,
                      title: 'قيد التجهيز بالمطبخ',
                      subtitle: 'طهاة ترويقة يحضرون وجبتك اللذيذة الآن',
                      isActive: activeStep >= 2,
                    ),
                    _TimelineItem(
                      icon: Icons.delivery_dining_rounded,
                      title: 'خارج للتوصيل',
                      subtitle: 'عامل التوصيل استلم طلبك وهو في الطريق إليك',
                      isActive: activeStep >= 3,
                    ),
                    _TimelineItem(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'تم التوصيل بنجاح',
                      subtitle: 'استلمت طلبك — بالهنا والشفا!',
                      isActive: activeStep >= 4,
                      isLast: true,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Driver Info Card (Only display if preparing or ready or delivered)
                  if (!isCancelled && activeStep >= 2) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.outlineVariant, width: 0.8),
                        boxShadow: const [AppShadows.card],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'محمد علي (مندوب التوصيل)',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  '+20 111 222 3333',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              appLogger.i('[OrderTrackingScreen] calling driver...');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('جاري الاتصال بمندوب التوصيل...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.phone_in_talk_rounded),
                            color: AppColors.success,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.success.withValues(alpha: 0.1),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = AppColors.outlineVariant;
    final inactiveBg = AppColors.surfaceContainerLow;
    final inactiveLine = AppColors.outlineVariant;
    final color = isActive ? AppColors.primary : AppColors.textMuted;

    return SizedBox(
      height: 84,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: isActive ? AppColors.primary : inactiveLine,
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : inactiveBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? AppColors.primary : inactiveColor,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isActive ? AppColors.primary : inactiveLine,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive ? AppColors.onSurface : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isActive ? AppColors.textSecondary : AppColors.textMuted,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
