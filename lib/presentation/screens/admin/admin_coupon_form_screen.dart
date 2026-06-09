import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_coupons_cubit.dart';
import '../../../domain/entities/coupon.dart';
import '../../../domain/enums/coupon_type.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';

class AdminCouponFormScreen extends StatefulWidget {
  final Coupon? coupon;

  const AdminCouponFormScreen({super.key, this.coupon});

  @override
  State<AdminCouponFormScreen> createState() => _AdminCouponFormScreenState();
}

class _AdminCouponFormScreenState extends State<AdminCouponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _maxUsesController = TextEditingController();
  String _type = 'percentage';
  bool _saving = false;

  bool get _isEditing => widget.coupon != null;

  @override
  void initState() {
    super.initState();
    if (widget.coupon != null) {
      final c = widget.coupon!;
      _codeController.text = c.code;
      _valueController.text = c.type == CouponType.percentage
          ? c.value.toStringAsFixed(0)
          : c.value.toStringAsFixed(2);
      _minOrderController.text =
          c.minOrder > 0 ? c.minOrder.toStringAsFixed(2) : '';
      _maxDiscountController.text =
          c.maxDiscount != null ? c.maxDiscount.toString() : '';
      _maxUsesController.text = c.maxUses?.toString() ?? '';
      _type = c.type.value;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _minOrderController.dispose();
    _maxDiscountController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = <String, dynamic>{
      'code': _codeController.text.trim(),
      'type': _type,
      'value': double.tryParse(_valueController.text.trim()) ?? 0,
      'min_order': double.tryParse(_minOrderController.text.trim()) ?? 0,
      'max_discount': _maxDiscountController.text.trim().isNotEmpty
          ? double.tryParse(_maxDiscountController.text.trim())
          : null,
      'max_uses': _maxUsesController.text.trim().isNotEmpty
          ? int.tryParse(_maxUsesController.text.trim())
          : null,
    };

    setState(() => _saving = true);

    final cubit = context.read<AdminCouponsCubit>();

    if (_isEditing) {
      await cubit.update(widget.coupon!.id, data);
    } else {
      await cubit.create(data);
    }

    if (!mounted) return;

    final currentState = cubit.state;
    if (currentState.status == AdminCouponsStatus.error) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentState.failure?.message ?? 'حدث خطأ في الحفظ'),
          backgroundColor: AppColors.statusCancelled,
        ),
      );
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تعديل الكوبون' : 'تم حفظ الكوبون'),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: _isEditing ? 'تعديل كوبون' : 'كوبون جديد',
        variant: TopBarVariant.withBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'كود الخصم',
                hint: 'مثال: WELCOME20',
                controller: _codeController,
                prefixIcon: Icons.discount_outlined,
                validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
              ),
              AppSpacing.gapH16,
              Text(
                'نوع الخصم',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'percentage', label: Text('نسبة %')),
                  ButtonSegment(value: 'fixed', label: Text('مبلغ ثابت')),
                ],
                selected: {_type},
                onSelectionChanged: (v) => setState(() => _type = v.first),
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'قيمة الخصم',
                hint: _type == 'percentage' ? 'مثال: 20' : 'مثال: 50',
                controller: _valueController,
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'الحد الأدنى للطلب (اختياري)',
                controller: _minOrderController,
                prefixIcon: Icons.shopping_cart_outlined,
                keyboardType: TextInputType.number,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'أقصى خصم (اختياري)',
                controller: _maxDiscountController,
                prefixIcon: Icons.money_off_outlined,
                keyboardType: TextInputType.number,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'أقصى عدد استخدامات (اختياري)',
                controller: _maxUsesController,
                prefixIcon: Icons.repeat_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: _isEditing ? 'تعديل الكوبون' : 'حفظ الكوبون',
                isLoading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
