import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/enums/order_type.dart';
import '../../../domain/enums/payment_method.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/repositories/coupon_repository.dart';
import '../../../application/cart/cart_cubit.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/orders/customer_orders_cubit.dart';
import '../../../application/coupon/coupon_cubit.dart';
import '../../extensions/payment_method_x.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/coupon_input.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _couponCodeController = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.cash;
  OrderType _orderType = OrderType.delivery;
  DateTime? _scheduledDateTime;
  bool _isLoading = false;
  bool _scheduleOrder = false;
  String? _selectedAddressId;
  Address? _selectedAddress;
  String? _addressValidationError;

  @override
  void initState() {
    super.initState();
    appLogger.i('[CheckoutScreen] initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        appLogger.i(
            '[CheckoutScreen] pre-filling from profile: ${authState.profile.name}');
        _nameController.text = authState.profile.name;
        _phoneController.text = authState.profile.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    appLogger.i('[CheckoutScreen] dispose');
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _couponCodeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_orderType == OrderType.delivery && _selectedAddress == null) {
      setState(() {
        _addressValidationError = 'من فضلك اختر أو أضف عنواناً للتوصيل أولاً';
      });
      HapticFeedback.heavyImpact();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      appLogger.i('[CheckoutScreen] _placeOrder — form validation failed');
      return;
    }

    appLogger.i('[CheckoutScreen] _placeOrder — placing order...');
    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated) {
        appLogger.w('[CheckoutScreen] _placeOrder — user not authenticated');
        return;
      }
      final profile = authState.profile;
      final cartState = context.read<CartCubit>().state;

      appLogger.i(
          '[CheckoutScreen] _placeOrder — user: ${profile.id}, items: ${cartState.items.length}, total: ${cartState.total}, payment: ${_paymentMethod.value}, type: ${_orderType.value}');

      final items = cartState.items
          .map((item) => {
                'product_id': item.productId,
                'product_name': item.productNameAr,
                'product_price': item.productPrice,
                'quantity': item.quantity,
                'subtotal': item.subtotal,
                'selected_options': item.selectedOptions
                    .map((e) => {
                          'option_id': e.optionId,
                          'option_name': e.name,
                          'price_adjustment': e.priceAdjustment,
                        })
                    .toList(),
              })
          .toList();

      await sl<CustomerOrdersCubit>().placeOrder(
        customerId: profile.id,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        customerAddress: _orderType == OrderType.delivery
            ? _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim()
            : null,
        addressId: _selectedAddressId,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        paymentMethod: _paymentMethod.value,
        totalAmount: cartState.finalTotal,
        items: items,
        scheduledFor: _scheduleOrder ? _scheduledDateTime : null,
        orderType: _orderType.value,
        couponId: cartState.appliedCouponId,
        discountAmount: cartState.discountAmount,
        deliveryFee: cartState.deliveryFee > 0 ? cartState.deliveryFee : null,
        deliveryZoneId: cartState.deliveryZoneId,
        deliveryZoneName: cartState.deliveryZoneName,
      );

      if (cartState.appliedCouponId != null) {
        await sl<CouponRepository>()
            .incrementUsage(cartState.appliedCouponId!);
      }

      await sl<CustomerOrdersCubit>().loadOrders(profile.id);

      if (!mounted) return;
      context.read<CartCubit>().clearCart();
      HapticFeedback.mediumImpact();
      appLogger.i(
          '[CheckoutScreen] _placeOrder — order created successfully, cart cleared');

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      appLogger.e('[CheckoutScreen] _placeOrder — error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حصل خطأ، حاول تاني'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    appLogger.i('[CheckoutScreen] showing success dialog');
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 550),
          tween: Tween<double>(begin: 0.85, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, cardScale, child) {
            return Opacity(
              opacity: ((cardScale - 0.85) / 0.15).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: cardScale,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 700),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
                          builder: (context, iconScale, child) {
                            return Transform.scale(
                              scale: iconScale,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.successContainer,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success.withValues(alpha: 0.2),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.successOnContainer,
                                  size: 46,
                                ),
                              ),
                            );
                          },
                        ),
                        AppSpacing.gapH24,
                        Text(
                          'تم الطلب بنجاح!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.gapH8,
                        Text(
                          'هنتواصل معاك في أقرب وقت لتأكيد وتوصيل طلبك',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: () {
                            appLogger.i('[CheckoutScreen] navigate to /orders after success');
                            Navigator.of(dialogContext).pop();
                            context.go('/orders');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            elevation: 2,
                            shadowColor: AppColors.primary.withValues(alpha: 0.3),
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'شوف طلباتي',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, 
                                   color: AppColors.onPrimary, 
                                   size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickAddress() async {
    final result = await context.push<Address>('/profile/addresses');
    if (result != null && mounted) {
      setState(() {
        _selectedAddress = result;
        _selectedAddressId = result.id;
        _addressController.text = result.address;
        _addressValidationError = null;
      });

      final cartCubit = context.read<CartCubit>();
      if (result.deliveryZoneId != null && result.deliveryZoneName != null) {
        cartCubit.setDeliveryZone(
          deliveryZoneId: result.deliveryZoneId!,
          deliveryZoneName: result.deliveryZoneName!,
          deliveryFee: result.deliveryFee ?? 0,
        );
      } else {
        cartCubit.clearDeliveryZone();
      }

      appLogger.i(
          '[CheckoutScreen] address selected — zone: ${result.deliveryZoneName ?? "none"}, fee: ${result.deliveryFee ?? 0}');
    }
  }

  Future<void> _pickScheduleDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Widget _buildSelectedAddressCard(ThemeData theme) {
    final address = _selectedAddress!;
    IconData addressIcon = Icons.location_on_rounded;
    final labelLower = address.label.trim().toLowerCase();
    if (labelLower == 'البيت' || labelLower == 'home') {
      addressIcon = Icons.home_rounded;
    } else if (labelLower == 'العمل' || labelLower == 'الشغل' || labelLower == 'work') {
      addressIcon = Icons.work_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  addressIcon,
                  color: AppColors.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (address.deliveryZoneName != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successContainer,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          'منطقة: ${address.deliveryZoneName}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.successOnContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton(
                onPressed: _pickAddress,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('تغيير'),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.outlineVariant),
          Text(
            address.address,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (address.building != null || address.floor != null || address.apartment != null) ...[
            const SizedBox(height: 6),
            Text(
              [
                if (address.building != null) 'عمارة: ${address.building}',
                if (address.floor != null) 'دور: ${address.floor}',
                if (address.apartment != null) 'شقة: ${address.apartment}',
              ].join(' - '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (address.notes != null && address.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CouponCubit>()),
      ],
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const AppTopBar(
              title: 'إتمـام الطلب',
              variant: TopBarVariant.withBack,
            ),
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _CheckoutSectionCard(
                      title: 'نوع الطلب',
                      icon: Icons.restaurant_menu_rounded,
                      child: Row(
                        children: [
                          Expanded(
                            child: _OrderTypeChip(
                              type: OrderType.delivery,
                              selected: _orderType,
                              onSelect: (v) => setState(() => _orderType = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _OrderTypeChip(
                              type: OrderType.pickup,
                              selected: _orderType,
                              onSelect: (v) => setState(() => _orderType = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _OrderTypeChip(
                              type: OrderType.dineIn,
                              selected: _orderType,
                              onSelect: (v) => setState(() => _orderType = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _CheckoutSectionCard(
                      title: _orderType == OrderType.delivery ? 'بيانات التوصيل والتواصل' : 'بيانات التواصل',
                      icon: _orderType == OrderType.delivery ? Icons.person_pin_circle_rounded : Icons.person_outline_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            _nameController,
                            'الاسم',
                            Icons.person_outline,
                            validator: (v) => (v == null || v.isEmpty) ? 'أدخل اسمك' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            _phoneController,
                            'رقم الهاتف',
                            Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.isEmpty) ? 'أدخل رقم الهاتف' : null,
                          ),
                          if (_orderType == OrderType.delivery) ...[
                            const SizedBox(height: 16),
                            if (_selectedAddress != null)
                              _buildSelectedAddressCard(theme)
                            else ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _addressValidationError != null
                                      ? AppColors.errorContainer.withValues(alpha: 0.15)
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(
                                    color: _addressValidationError != null
                                        ? AppColors.error
                                        : AppColors.outlineVariant.withValues(alpha: 0.8),
                                    width: _addressValidationError != null ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.location_off_rounded,
                                      color: _addressValidationError != null ? AppColors.error : AppColors.textSecondary,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'لم يتم تحديد عنوان للتوصيل',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'يجب اختيار عنوان توصيل محفوظ لتأكيد الطلب وحساب الرسوم',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_addressValidationError != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        _addressValidationError!,
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _pickAddress,
                                      icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                                      label: const Text('اختيار أو إضافة عنوان جديد'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.onPrimary,
                                        elevation: 0,
                                        minimumSize: const Size(double.infinity, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppRadius.lg),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                          const SizedBox(height: 12),
                          _buildTextField(
                            _notesController,
                            'ملاحظات إضافية (مثلاً: رقم الشقة، علامة مميزة)',
                            Icons.note_outlined,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    _CheckoutSectionCard(
                      title: _orderType == OrderType.delivery ? 'موعد التوصيل' : 'موعد الاستلام',
                      icon: Icons.schedule_rounded,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ScheduleChip(
                                  label: 'في أقرب وقت',
                                  selected: !_scheduleOrder,
                                  onTap: () => setState(() => _scheduleOrder = false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ScheduleChip(
                                  label: 'جدولة',
                                  selected: _scheduleOrder,
                                  onTap: () => setState(() => _scheduleOrder = true),
                                ),
                              ),
                            ],
                          ),
                          if (_scheduleOrder) ...[
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _pickScheduleDateTime,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        color: AppColors.primary, size: 18),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _scheduledDateTime != null
                                            ? DateFormat('dd/MM/yyyy - hh:mm a').format(_scheduledDateTime!)
                                            : 'اختر التاريخ والوقت',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: _scheduledDateTime != null
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                          fontWeight: _scheduledDateTime != null
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (_scheduledDateTime != null)
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppColors.success, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _CheckoutSectionCard(
                      title: 'طريقة الدفع',
                      icon: Icons.payment_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PaymentOption(
                            label: 'كاش عند الاستلام',
                            icon: Icons.money_rounded,
                            method: PaymentMethod.cash,
                            selected: _paymentMethod,
                            onSelect: (v) => setState(() => _paymentMethod = v),
                          ),
                          const SizedBox(height: 8),
                          _PaymentOption(
                            label: 'محفظة إلكترونية',
                            icon: Icons.account_balance_wallet_outlined,
                            method: PaymentMethod.wallet,
                            selected: _paymentMethod,
                            onSelect: (v) => setState(() => _paymentMethod = v),
                          ),
                          const SizedBox(height: 8),
                          _PaymentOption(
                            label: 'InstaPay',
                            icon: Icons.payment_rounded,
                            method: PaymentMethod.instapay,
                            selected: _paymentMethod,
                            onSelect: (v) => setState(() => _paymentMethod = v),
                          ),
                          if (_paymentMethod != PaymentMethod.cash) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(
                                  color: AppColors.tertiary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded,
                                      color: AppColors.tertiary, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'هتدفع ${_paymentMethod.arabicLabel} وترفع لقطة الشاشة دلوقتي أو بعد الطلب',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.onTertiaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _CheckoutSectionCard(
                      title: 'كود الخصم',
                      icon: Icons.local_offer_outlined,
                      child: BlocConsumer<CouponCubit, CouponState>(
                        listener: (context, couponState) {
                          if (couponState.status == CouponStatus.applied) {
                            context.read<CartCubit>().applyCoupon(
                                  couponState.appliedCoupon!.id,
                                  couponState.discountAmount,
                                );
                            HapticFeedback.lightImpact();
                          } else if (couponState.status == CouponStatus.error) {
                            HapticFeedback.heavyImpact();
                          } else if (couponState.status == CouponStatus.removing ||
                              couponState.status == CouponStatus.initial) {
                            context.read<CartCubit>().removeCoupon();
                          }
                        },
                        builder: (context, couponState) {
                          final isLoading = couponState.status == CouponStatus.validating;
                          final hasError = couponState.status == CouponStatus.error;
                          final isApplied = couponState.status == CouponStatus.applied;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isApplied)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.successContainer,
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                    border: Border.all(
                                      color: AppColors.success.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppColors.success, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'تم تطبيق كود: ${couponState.appliedCoupon!.code}',
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                color: AppColors.successOnContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'وفرت ${couponState.discountAmount.toStringAsFixed(0)} ج من إجمالي طلبك',
                                              style: theme.textTheme.labelMedium?.copyWith(
                                                color: AppColors.successOnContainer.withValues(alpha: 0.8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          context.read<CouponCubit>().removeCoupon();
                                          _couponCodeController.clear();
                                        },
                                        icon: const Icon(Icons.close_rounded, size: 16),
                                        label: const Text('إزالة'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else ...[
                                CouponInput(
                                  controller: _couponCodeController,
                                  isLoading: isLoading,
                                  onChanged: (String value) {
                                    final couponCubit = context.read<CouponCubit>();
                                    if (couponCubit.state.status == CouponStatus.error) {
                                      couponCubit.clearError();
                                    }
                                  },
                                  onApply: () {
                                    final code = _couponCodeController.text.trim();
                                    if (code.isEmpty) return;
                                    context.read<CouponCubit>().validateAndApply(code, cartState.total);
                                  },
                                ),
                                if (hasError) ...[
                                  const SizedBox(height: 8),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorContainer,
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      border: Border.all(
                                        color: AppColors.error.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            couponState.errorMessage ?? 'حصل خطأ في كود الخصم',
                                            style: theme.textTheme.labelMedium?.copyWith(
                                              color: AppColors.onErrorContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                    _CheckoutSectionCard(
                      title: 'ملخص الطلب',
                      icon: Icons.receipt_long_rounded,
                      child: Column(
                        children: [
                          ...cartState.items.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item.productNameAr} × ${item.quantity}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontSize: 13,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (item.selectedOptions.isNotEmpty)
                                            Text(
                                              item.selectedOptions.map((e) => e.name).join(', '),
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${item.subtotal.toStringAsFixed(0)} ج',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(height: 24, color: AppColors.outlineVariant),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'الإجمالي',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${cartState.total.toStringAsFixed(0)} جنيه',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (cartState.deliveryFee > 0) ...[
                            const Divider(height: 16, color: AppColors.outlineVariant),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'رسوم التوصيل${cartState.deliveryZoneName != null ? " (${cartState.deliveryZoneName})" : ""}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '+${cartState.deliveryFee.toStringAsFixed(0)} ج',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                ],
                              ),
                            ],
                            if (cartState.discountAmount > 0) ...[
                              const Divider(height: 16, color: AppColors.outlineVariant),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'الخصم',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColors.successOnContainer,
                                    ),
                                  ),
                                  Text(
                                    '-${cartState.discountAmount.toStringAsFixed(0)} ج',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (cartState.deliveryFee > 0 || cartState.discountAmount > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'المبلغ النهائي',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${cartState.finalTotal.toStringAsFixed(0)} جنيه',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      LoadingButton(
                        onPressed: _placeOrder,
                        label: 'تأكيد الطلب',
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon, {
      TextInputType? keyboardType,
      int maxLines = 1,
      String? Function(String?)? validator,
    }) {
      return _CheckoutTextField(
        controller: controller,
        hint: hint,
        icon: icon,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      );
    }
  }

  class _CheckoutSectionCard extends StatelessWidget {
    final String title;
    final IconData icon;
    final Widget child;

    const _CheckoutSectionCard({
      required this.title,
      required this.icon,
      required this.child,
    });

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      );
    }
  }




class _OrderTypeChip extends StatefulWidget {
  final OrderType type;
  final OrderType selected;
  final ValueChanged<OrderType> onSelect;

  const _OrderTypeChip({
    required this.type,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_OrderTypeChip> createState() => _OrderTypeChipState();
}

class _OrderTypeChipState extends State<_OrderTypeChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.type == widget.selected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onSelect(widget.type);
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 12),
            constraints: const BoxConstraints(minHeight: 76),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.type.icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.type.arabicLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ScheduleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ScheduleChip> createState() => _ScheduleChipState();
}

class _ScheduleChipState extends State<_ScheduleChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.selected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surfaceContainerLow,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: widget.selected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.5),
                width: widget.selected ? 1.5 : 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                color: widget.selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatefulWidget {
  final String label;
  final IconData icon;
  final PaymentMethod method;
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelect;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.method,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_PaymentOption> createState() => _PaymentOptionState();
}

class _PaymentOptionState extends State<_PaymentOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.method == widget.selected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onSelect(widget.method);
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _CheckoutTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  State<_CheckoutTextField> createState() => _CheckoutTextFieldState();
}

class _CheckoutTextFieldState extends State<_CheckoutTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final primary = AppColors.primary;
    final outlineVariant = AppColors.outlineVariant;
    final textPrimary = AppColors.textPrimary;
    final textSecondary = AppColors.textSecondary;
    const fill = AppColors.surface;
    
    final hasError = _errorText != null;
    final borderColor = hasError
        ? theme.colorScheme.error
        : (_isFocused 
            ? primary 
            : outlineVariant.withValues(alpha: 0.5));
            
    final shadowColor = hasError ? theme.colorScheme.error : primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 2.0 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: textSecondary.withValues(alpha: 0.6),
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: AnimatedScale(
            scale: _isFocused ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              widget.icon,
              color: _isFocused ? primary : textSecondary,
              size: 20,
            ),
          ),
        ),
        validator: (v) {
          final error = widget.validator?.call(v);
          if (error != _errorText) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _errorText = error;
                });
              }
            });
          }
          return error;
        },
      ),
    );
  }
}
