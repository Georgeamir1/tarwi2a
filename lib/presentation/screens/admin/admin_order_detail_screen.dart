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
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/repositories/print_repository.dart';
import '../../../core/di/injection_container.dart';
import '../../extensions/order_status_x.dart';
import '../../extensions/payment_method_x.dart';
import '../../widgets/info_card.dart';
import '../../../core/utils/contact_helper.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Order? order;
  final String? orderId;

  const AdminOrderDetailScreen({
    super.key,
    this.order,
    this.orderId,
  }) : assert(order != null || orderId != null,
            'Either order or orderId must be provided');

  String get effectiveOrderId => order?.id ?? orderId!;

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  Order? _order;
  bool _isLoading = false;
  String? _errorMessage;
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
    if (widget.order != null) {
      _order = widget.order;
      _currentStatus = widget.order!.status.value;
      _currentPaymentStatus = widget.order!.paymentStatus;
      _isLoading = false;
      appLogger.d(
          '[AdminOrderDetail] initState — order: ${widget.order!.id}, status: $_currentStatus, paymentStatus: $_currentPaymentStatus');
    } else {
      _currentStatus = 'pending';
      _currentPaymentStatus = 'pending';
      _isLoading = true;
      _fetchOrder();
    }
  }

  Future<void> _fetchOrder() async {
    final result =
        await sl<OrderRepository>().getOrderById(widget.effectiveOrderId);
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (order) {
        setState(() {
          _isLoading = false;
          _order = order;
          if (order != null) {
            _currentStatus = order.status.value;
            _currentPaymentStatus = order.paymentStatus;
          } else {
            _errorMessage = 'الطلب غير موجود أو تم حذفه';
          }
        });
      },
    );
  }

  Future<void> _printOrder() async {
    final orderToPrint = _order ?? widget.order;
    if (orderToPrint == null) return;
    try {
      final repo = sl<PrintRepository>();
      final result = await repo.printOrder(orderToPrint);
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
    if (_isUpdating) return;
    appLogger.d(
        '[AdminOrderDetail] _updateStatus — from: $_currentStatus to: $newStatus');
    setState(() => _isUpdating = true);
    try {
      final result = await context
          .read<AdminOrdersCubit>()
          .updateStatus(widget.effectiveOrderId, newStatus);
      if (!mounted) return;
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        ),
        (_) {
          setState(() {
            _currentStatus = newStatus;
            if (newStatus == 'delivered') {
              _currentPaymentStatus = 'confirmed';
            }
          });
          appLogger.d(
              '[AdminOrderDetail] _updateStatus — success, new status: $newStatus');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'تم تحديث الحالة إلى: ${OrderStatus.fromString(newStatus).arabicLabel}'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      );
    } catch (e) {
      appLogger.e('[AdminOrderDetail] _updateStatus — error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('حصل خطأ أثناء تحديث الحالة'),
            backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _confirmPayment() async {
    if (_isUpdating) return;
    appLogger.d(
        '[AdminOrderDetail] _confirmPayment — order: ${widget.effectiveOrderId}');
    setState(() => _isUpdating = true);
    try {
      final result = await context
          .read<AdminOrdersCubit>()
          .confirmPayment(widget.effectiveOrderId);
      if (!mounted) return;
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        ),
        (_) {
          appLogger.d('[AdminOrderDetail] _confirmPayment — success');
          setState(() {
            _currentPaymentStatus = 'confirmed';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم تأكيد استلام الدفع'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الطلب'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الطلب'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage ?? 'الطلب غير موجود أو تم حذفه',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go('/admin/orders');
                  }
                },
                child: const Text('العودة لقائمة الطلبات'),
              ),
            ],
          ),
        ),
      );
    }

    final order = _order!;
    final nextStatus = _nextStatus[_currentStatus];
    final nextLabel = _nextStatusLabel[_currentStatus];
    final isOnlinePayment = order.paymentMethod.value != 'cash';
    final isPaymentPending = _currentPaymentStatus == 'pending';

    return BlocProvider<RatingCubit>(
      create: (context) => sl<RatingCubit>()..loadOrderRating(order.id),
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
                    AppSpacing.gapH12,
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final ok = await ContactHelper.callPhoneNumber(
                                order.customerPhone,
                              );
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'تعذر بدء الاتصال برقم ${order.customerPhone}'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.call_rounded, size: 18),
                            label: const Text('اتصال'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final ok = await ContactHelper.openWhatsApp(
                                order.customerPhone,
                                message:
                                    'أهلاً ${order.customerName}، بخصوص طلبك #${order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id} من تطبيق ترويئه 🍔',
                              );
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تعذر فتح تطبيق واتساب'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.chat_bubble_rounded,
                                size: 18, color: Colors.white),
                            label: const Text(
                              'واتساب',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (ratingState.orderRating != null) ...[
                  AppSpacing.gapH16,
                  InfoCard(
                    title: 'تقييم العميل للطلب',
                    children: [
                      Row(
                        children: [
                          ...List.generate(
                              5,
                              (index) => Icon(
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
                              fontWeight: FontWeight.w700, fontSize: 16),
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
                    onPressed:
                        _isUpdating ? null : () => _updateStatus(nextStatus),
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
                    shape:
                        RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
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
                        : const Icon(Icons.check_circle_outline_rounded,
                            size: 18),
                    label: const Text('تأكيد استلام الدفع'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(double.infinity, 52),
                      shape:
                          RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
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
                                content: const Text(
                                    'هل أنت متأكد من إلغاء هذا الطلب؟'),
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
                                        style:
                                            TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 52),
                      shape:
                          RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
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
