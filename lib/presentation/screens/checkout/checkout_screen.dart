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
import '../../../application/cart/cart_cubit.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/orders/customer_orders_cubit.dart';
import '../../widgets/loading_button.dart';

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

  PaymentMethod _paymentMethod = PaymentMethod.cash;
  OrderType _orderType = OrderType.delivery;
  DateTime? _scheduledDateTime;
  bool _isLoading = false;
  bool _scheduleOrder = false;
  String? _selectedAddressId;
  Address? _selectedAddress;

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
    super.dispose();
  }

  Future<void> _placeOrder() async {
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
        totalAmount: cartState.total,
        items: items,
        scheduledFor: _scheduleOrder ? _scheduledDateTime : null,
        orderType: _orderType.value,
      );

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check, color: AppColors.surface, size: 40),
            ),
            AppSpacing.gapH16,
            const Text(
              'تم الطلب بنجاح!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH8,
            const Text(
              'هنتواصل معاك في أقرب وقت',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              appLogger.i('[CheckoutScreen] navigate to /orders after success');
              context.go('/orders');
            },
            child: const Text('شوف طلباتي'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAddress() async {
    final result = await context.push<Address>('/profile/addresses');
    if (result != null && mounted) {
      setState(() {
        _selectedAddress = result;
        _selectedAddressId = result.id;
        _addressController.text = result.address;
      });
    }
  }
  Future<void> _pickScheduleDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text('إتمام الطلب'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                appLogger.i('[CheckoutScreen] back pressed');
                if (Navigator.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/cart');
                }
              },
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _SectionTitle(title: 'نوع الطلب'),
                  AppSpacing.gapH12,
                  Row(
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
                  AppSpacing.gapH24,
                  const _SectionTitle(title: 'بيانات التواصل'),
                  AppSpacing.gapH12,
                  _buildTextField(
                      _nameController, 'الاسم', Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'أدخل اسمك' : null),
                  AppSpacing.gapH12,
                  _buildTextField(
                      _phoneController, 'رقم الهاتف', Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'أدخل رقم الهاتف' : null),
                  if (_orderType == OrderType.delivery) ...[
                    AppSpacing.gapH12,
                    _buildTextField(_addressController, 'العنوان',
                        Icons.location_on_outlined,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'أدخل العنوان' : null),
                    AppSpacing.gapH8,
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickAddress,
                        icon: const Icon(Icons.my_location, size: 18),
                        label: Text(
                          _selectedAddress != null
                              ? 'تم اختيار: ${_selectedAddress!.label}'
                              : 'اختيار من العناوين المحفوظة',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _selectedAddress != null
                              ? AppColors.success
                              : AppColors.primary,
                          side: BorderSide(
                            color: _selectedAddress != null
                                ? AppColors.success
                                : AppColors.outline,
                          ),
                        ),
                      ),
                    ),
                  ],
                  AppSpacing.gapH12,
                  _buildTextField(_notesController, 'ملاحظات (اختياري)',
                      Icons.note_outlined,
                      maxLines: 2),
                  AppSpacing.gapH24,
                  const _SectionTitle(title: 'موعد التوصيل'),
                  AppSpacing.gapH12,
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ScheduleChip(
                                label: 'في أقرب وقت',
                                selected: !_scheduleOrder,
                                onTap: () =>
                                    setState(() => _scheduleOrder = false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ScheduleChip(
                                label: 'جدولة',
                                selected: _scheduleOrder,
                                onTap: () =>
                                    setState(() => _scheduleOrder = true),
                              ),
                            ),
                          ],
                        ),
                        if (_scheduleOrder) ...[
                          AppSpacing.gapH12,
                          GestureDetector(
                            onTap: _pickScheduleDateTime,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: AppRadius.mdAll,
                                border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      color: AppColors.primary, size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _scheduledDateTime != null
                                          ? DateFormat('dd/MM/yyyy - hh:mm a')
                                              .format(_scheduledDateTime!)
                                          : 'اختر التاريخ والوقت',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
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
                  AppSpacing.gapH24,
                  const _SectionTitle(title: 'طريقة الدفع'),
                  AppSpacing.gapH12,
                  _PaymentOption(
                    label: 'كاش عند الاستلام',
                    icon: Icons.money_rounded,
                    method: PaymentMethod.cash,
                    selected: _paymentMethod,
                    onSelect: (v) => setState(() => _paymentMethod = v),
                  ),
                  AppSpacing.gapH8,
                  _PaymentOption(
                    label: 'محفظة إلكترونية',
                    icon: Icons.account_balance_wallet_outlined,
                    method: PaymentMethod.wallet,
                    selected: _paymentMethod,
                    onSelect: (v) => setState(() => _paymentMethod = v),
                  ),
                  AppSpacing.gapH8,
                  _PaymentOption(
                    label: 'InstaPay',
                    icon: Icons.payment_rounded,
                    method: PaymentMethod.instapay,
                    selected: _paymentMethod,
                    onSelect: (v) => setState(() => _paymentMethod = v),
                  ),
                  if (_paymentMethod != PaymentMethod.cash) ...[
                    AppSpacing.gapH12,
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed,
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(
                            color: AppColors.tertiary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.tertiary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'هتدفع ${_paymentMethod.arabicLabel} وترفع لقطة الشاشة دلوقتي أو بعد الطلب',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: AppColors.tertiary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  AppSpacing.gapH24,
                  const _SectionTitle(title: 'ملخص الطلب'),
                  AppSpacing.gapH12,
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        ...cartState.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.productNameAr} × ${item.quantity}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(fontSize: 13),
                                        ),
                                        if (item.selectedOptions.isNotEmpty)
                                          Text(
                                            item.selectedOptions
                                                .map((e) => e.name)
                                                .join(', '),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${item.subtotal.toStringAsFixed(0)} ج',
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الإجمالي',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
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
                      ],
                    ),
                  ),
                  AppSpacing.gapH24,
                  LoadingButton(
                    onPressed: _placeOrder,
                    label: 'تأكيد الطلب',
                    isLoading: _isLoading,
                  ),
                  AppSpacing.gapH24,
                ],
              ),
            ),
          ),
        );
      },
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.surface,
      ),
      validator: validator,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _OrderTypeChip extends StatelessWidget {
  final OrderType type;
  final OrderType selected;
  final ValueChanged<OrderType> onSelect;

  const _OrderTypeChip({
    required this.type,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = type == selected;
    return GestureDetector(
      onTap: () => onSelect(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              type.arabicLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ScheduleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.background,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = method == selected;
    return GestureDetector(
      onTap: () => onSelect(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
