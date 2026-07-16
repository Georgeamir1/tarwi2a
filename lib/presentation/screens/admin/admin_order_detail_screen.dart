import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_orders_cubit.dart';
import '../../../application/rating/rating_cubit.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_status.dart';
import '../../../domain/repositories/print_repository.dart';
import '../../../core/di/injection_container.dart';
import '../../extensions/order_status_x.dart';
import '../../extensions/payment_method_x.dart';
import '../../widgets/info_card.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Order order;
  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late String _currentStatus;
  late String _currentPaymentStatus;
  bool _isUpdating = false;

  static const _nextStatus = {
    'pending': 'confirmed',
    'confirmed': 'preparing',
    'preparing': 'ready',
    'ready': 'delivered',
  };

  static const _nextStatusLabel = {
    'pending': 'تأكيد الطلب',
    'confirmed': 'بدء التحضير',
    'preparing': 'جاهز للاستلام',
    'ready': 'تم التوصيل',
  };

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status.value;
    _currentPaymentStatus = widget.order.paymentStatus;
    appLogger.d(
        '[AdminOrderDetail] initState — order: ${widget.order.id}, status: $_currentStatus, paymentStatus: $_currentPaymentStatus');
  }

  Future<void> _printOrder() async {
    try {
      final repo = sl<PrintRepository>();
      final result = await repo.printOrder(widget.order);
      if (!mounted) return;
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        ),
        (printed) {
          if (printed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إرسال الطلب للطباعة'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حصل خطأ في الطباعة'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    appLogger.d(
        '[AdminOrderDetail] _updateStatus — from: $_currentStatus to: $newStatus');
    setState(() => _isUpdating = true);
    try {
      await context
          .read<AdminOrdersCubit>()
          .updateStatus(widget.order.id, newStatus);
      setState(() {
        _currentStatus = newStatus;
        if (newStatus == 'delivered') {
          _currentPaymentStatus = 'confirmed';
        }
      });
      appLogger.d(
          '[AdminOrderDetail] _updateStatus — success, new status: $newStatus');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'تم تحديث الحالة إلى: ${OrderStatus.fromString(newStatus).arabicLabel}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      appLogger.e('[AdminOrderDetail] _updateStatus — error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('حصل خطأ'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _confirmPayment() async {
    appLogger.d('[AdminOrderDetail] _confirmPayment — order: ${widget.order.id}');
    setState(() => _isUpdating = true);
    try {
      await context.read<AdminOrdersCubit>().confirmPayment(widget.order.id);
      appLogger.d('[AdminOrderDetail] _confirmPayment — success');
      if (mounted) {
        setState(() {
          _currentPaymentStatus = 'confirmed';
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تأكيد استلام الدفع'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      appLogger.e('[AdminOrderDetail] _confirmPayment — error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('حصل خطأ'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = widget.order;
    final nextStatus = _nextStatus[_currentStatus];
    final nextLabel = _nextStatusLabel[_currentStatus];
    final isOnlinePayment =
        order.paymentMethod.value != 'cash';
    final isPaymentPending = _currentPaymentStatus == 'pending';

    return BlocProvider<RatingCubit>(
      create: (context) => sl<RatingCubit>()..loadOrderRating(widget.order.id),
      child: BlocBuilder<RatingCubit, RatingState>(
        builder: (context, ratingState) {
          return Scaffold(
            appBar: AppBar(
              title: Text('طلب #${order.id.substring(0, 8).toUpperCase()}'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  appLogger.d('[AdminOrderDetail] back pressed');
                  context.pop();
                },
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatusStepper(currentStatus: _currentStatus),
                AppSpacing.gapH16,
                InfoCard(
                  title: 'بيانات العميل',
                  children: [
                    InfoRow('الاسم', order.customerName),
                    InfoRow('الهاتف', order.customerPhone),
                    if (order.customerAddress != null)
                      InfoRow('العنوان', order.customerAddress!),
                    InfoRow('طريقة الدفع', order.paymentMethod.arabicLabel),
                    if (isOnlinePayment)
                      InfoRow(
                        'حالة الدفع',
                        isPaymentPending ? 'معلق' : 'تم الدفع ✅',
                      ),
                    InfoRow(
                        'التاريخ',
                        DateFormat('dd/MM/yyyy - hh:mm a')
                            .format(order.createdAt.toLocal())),
                    if (order.notes != null) InfoRow('ملاحظات', order.notes!),
                  ],
                ),
                if (ratingState.orderRating != null) ...[
                  AppSpacing.gapH16,
                  InfoCard(
                    title: 'تقييم العميل للطلب',
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (index) => Icon(
                            index < ratingState.orderRating!.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.statusPending,
                            size: 24,
                          )),
                          const SizedBox(width: 12),
                          Text(
                            '${ratingState.orderRating!.rating} / 5',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.statusPending,
                            ),
                          ),
                        ],
                      ),
                      if (ratingState.orderRating!.comment != null &&
                          ratingState.orderRating!.comment!.isNotEmpty) ...[
                        AppSpacing.gapH12,
                        Text(
                          'التعليق:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Text(
                            ratingState.orderRating!.comment!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                AppSpacing.gapH16,
                InfoCard(
                  title: 'الأصناف',
                  children: [
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.productName} × ${item.quantity}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '${item.subtotal.toStringAsFixed(0)} ج',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الإجمالي',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,

                           fontSize: 160
                          ),
                        ),
                        Text(
                          '${order.totalAmount.toStringAsFixed(0)} جنيه',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          AppSpacing.gapH24,
          if (nextStatus != null &&
              _currentStatus != 'delivered' &&
              _currentStatus != 'cancelled')
            ElevatedButton(
              onPressed: _isUpdating ? null : () => _updateStatus(nextStatus),
              child: _isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.surface, strokeWidth: 2))
                  : Text(nextLabel ?? ''),
            ),
          AppSpacing.gapH12,
          OutlinedButton.icon(
            onPressed: () => _printOrder(),
            icon: const Icon(Icons.print, size: 18),
            label: const Text('طباعة الطلب'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
            ),
          ),
          if (isOnlinePayment && isPaymentPending) ...[
            AppSpacing.gapH12,
            FilledButton.icon(
              onPressed: _isUpdating ? null : _confirmPayment,
              icon: _isUpdating
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('تأكيد استلام الدفع'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
              ),
            ),
          ],
          if (_currentStatus != 'delivered' &&
              _currentStatus != 'cancelled') ...[
            AppSpacing.gapH12,
            OutlinedButton(
              onPressed: _isUpdating
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg)),
                          title: const Text('إلغاء الطلب'),
                          content:
                              const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('رجوع'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _updateStatus('cancelled');
                              },
                              child: const Text('إلغاء الطلب',
                                  style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
              ),
              child: const Text('إلغاء الطلب'),
            ),
          ],
        ],
      ),
    );
  },
),
);
  }
}

class _StatusStepper extends StatelessWidget {
  final String currentStatus;
  const _StatusStepper({required this.currentStatus});

  static const _steps = [
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'delivered'
  ];
  static const _labels = ['انتظار', 'تأكيد', 'تحضير', 'جاهز', 'توصيل'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _steps.indexOf(currentStatus);
    final isCancelled = currentStatus == 'cancelled';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.divider),
      ),
      child: isCancelled
          ? const Center(
              child: Text(
              'تم إلغاء الطلب',
              style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ))
          : Row(
              children: List.generate(_steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  final stepIndex = i ~/ 2;
                  return Expanded(
                    child: Container(
                      height: 2,
                      color: stepIndex < currentIndex
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  );
                }
                final stepIndex = i ~/ 2;
                final isDone = stepIndex <= currentIndex;
                final isActive = stepIndex == currentIndex;
                return Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.primary : AppColors.divider,
                        border: isActive
                            ? Border.all(color: AppColors.primary, width: 3)
                            : null,
                      ),
                      child: isDone
                          ? const Icon(Icons.check,
                              color: AppColors.surface, size: 14)
                          : null,
                    ),
                    AppSpacing.gapH4,
                    Text(
                      _labels[stepIndex],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDone
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                );
              }),
            ),
    );
  }
}
