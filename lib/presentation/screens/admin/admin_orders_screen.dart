import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_orders_cubit.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_status.dart';
import '../../extensions/order_status_x.dart';
import '../../extensions/payment_method_x.dart';
import '../../../domain/enums/payment_method.dart';
import '../../../core/utils/contact_helper.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _filterStatus = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  static const _statuses = [
    ('all', 'الكل'),
    ('pending', 'جديدة'),
    ('confirmed', 'مؤكدة'),
    ('preparing', 'تحضير'),
    ('ready', 'جاهزة'),
    ('delivered', 'تم التوصيل'),
    ('cancelled', 'ملغية'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<AdminOrdersCubit>();
      if (cubit.state.status == AdminOrdersStatus.initial) {
        cubit.loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Order> _filterOrders(List<Order> orders) {
    var filtered = _filterStatus == 'all'
        ? orders
        : orders.where((o) => o.status.value == _filterStatus).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((o) {
        return o.customerName.toLowerCase().contains(query) ||
            o.customerPhone.contains(query) ||
            o.id.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Color _getStatusFilterColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.statusPending;
      case 'confirmed':
        return AppColors.statusConfirmed;
      case 'preparing':
        return AppColors.statusPreparing;
      case 'ready':
        return AppColors.statusReady;
      case 'delivered':
        return AppColors.statusDelivered;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('إدارة الطلبات'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'بحث بالاسم أو الهاتف أو رقم الطلب...',
                      hintStyle: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textSecondary, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.cancel_rounded,
                                  size: 20, color: AppColors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(
                          color:
                              AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(
                          color:
                              AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                AppSpacing.gapH12,
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _statuses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final (value, label) = _statuses[index];
                      final isSelected = _filterStatus == value;
                      final filterColor = isSelected
                          ? _getStatusFilterColor(value)
                          : AppColors.outline;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _filterStatus = value);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? filterColor.withValues(alpha: 0.12)
                                : AppColors.surface,
                            borderRadius: AppRadius.xlAll,
                            border: Border.all(
                              color: isSelected
                                  ? filterColor
                                  : AppColors.outlineVariant,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          filterColor.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? filterColor
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppSpacing.gapH8,
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<AdminOrdersCubit>().loadOrders();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: state.status == AdminOrdersStatus.loading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary))
                        : state.status == AdminOrdersStatus.error
                            ? Center(
                                child: Text(
                                    'خطأ: ${state.failure?.message ?? ''}'))
                            : () {
                                final filtered = _filterOrders(state.orders);
                                if (filtered.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.search_off,
                                            size: 48, color: AppColors.grey300),
                                        AppSpacing.gapH12,
                                        Text(
                                          _searchQuery.isNotEmpty
                                              ? 'مفيش نتائج للبحث'
                                              : 'مفيش طلبات',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      AppSpacing.gapH10,
                                  itemBuilder: (context, index) =>
                                      _AdminOrderCard(
                                    order: filtered[index],
                                    onTap: () {
                                      context.push(
                                        '/admin/orders/${filtered[index].id}',
                                        extra: filtered[index],
                                      );
                                    },
                                  ),
                                );
                              }(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminOrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onTap;

  const _AdminOrderCard({required this.order, required this.onTap});

  @override
  State<_AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<_AdminOrderCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.order.status == OrderStatus.pending) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AdminOrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.order.status == OrderStatus.pending) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor => widget.order.status.color;

  IconData get _statusIcon => switch (widget.order.status) {
        OrderStatus.pending => Icons.hourglass_empty_rounded,
        OrderStatus.confirmed => Icons.check_circle_outline_rounded,
        OrderStatus.preparing => Icons.restaurant_rounded,
        OrderStatus.ready => Icons.shopping_bag_outlined,
        OrderStatus.delivered => Icons.task_alt_rounded,
        OrderStatus.cancelled => Icons.cancel_outlined,
      };

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      return 'اليوم، ${DateFormat('hh:mm a').format(dateTime)}';
    } else if (difference.inDays == 1 ||
        (difference.inHours < 48 &&
            dateTime.day == now.subtract(const Duration(days: 1)).day)) {
      return 'أمس، ${DateFormat('hh:mm a').format(dateTime)}';
    } else {
      return DateFormat('dd/MM - hh:mm a').format(dateTime);
    }
  }

  Color _getPaymentColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return AppColors.statusDelivered;
      case PaymentMethod.wallet:
        return AppColors.statusPending;
      case PaymentMethod.instapay:
        return AppColors.statusConfirmed;
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money_rounded;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.instapay:
        return Icons.pix_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = widget.order.status == OrderStatus.pending;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOutCubic,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isPending
                  ? AppColors.statusPending
                  : AppColors.outlineVariant,
              width: isPending ? 1.5 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSubtle,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isPending)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.statusPending.withValues(
                              alpha: _pulseController.value * 0.8 + 0.2,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.statusPending.withValues(
                                  alpha: _pulseController.value * 0.4,
                                ),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.only(left: 8),
                        );
                      },
                    ),
                  Expanded(
                    child: Text(
                      widget.order.customerName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: AppRadius.xlAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon, size: 12, color: _statusColor),
                        const SizedBox(width: 4),
                        Text(
                          widget.order.status.arabicLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH8,
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_enabled_rounded,
                                size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              widget.order.customerPhone,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final ok = await ContactHelper.callPhoneNumber(
                              widget.order.customerPhone,
                            );
                            if (!ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'تعذر بدء الاتصال برقم ${widget.order.customerPhone}'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.call_rounded,
                                    size: 12, color: AppColors.primary),
                                SizedBox(width: 3),
                                Text(
                                  'اتصال',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final ok = await ContactHelper.openWhatsApp(
                              widget.order.customerPhone,
                              message:
                                  'أهلاً ${widget.order.customerName}، بخصوص طلبك #${widget.order.id.length >= 8 ? widget.order.id.substring(0, 8).toUpperCase() : widget.order.id} من ترويئه 🍔',
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
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: const Color(0xFF25D366)
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_rounded,
                                    size: 12, color: Color(0xFF25D366)),
                                SizedBox(width: 3),
                                Text(
                                  'واتساب',
                                  style: TextStyle(
                                    color: Color(0xFF25D366),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _formatRelativeTime(widget.order.createdAt.toLocal()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.order.items.isNotEmpty) ...[
                AppSpacing.gapH8,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.restaurant_menu_rounded,
                          size: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.order.items
                            .map((e) => '${e.productName} × ${e.quantity}')
                            .join('، '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              AppSpacing.gapH10,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPaymentColor(widget.order.paymentMethod)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPaymentIcon(widget.order.paymentMethod),
                          size: 12,
                          color: _getPaymentColor(widget.order.paymentMethod),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.order.paymentMethod.arabicLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getPaymentColor(widget.order.paymentMethod),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${widget.order.totalAmount.toStringAsFixed(0)} جنيه',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
