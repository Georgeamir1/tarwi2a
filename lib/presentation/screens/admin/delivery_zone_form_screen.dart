import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_delivery_zones_cubit.dart';
import '../../../domain/entities/delivery_zone.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';

class DeliveryZoneFormScreen extends StatefulWidget {
  final DeliveryZone? zone;

  const DeliveryZoneFormScreen({super.key, this.zone});

  @override
  State<DeliveryZoneFormScreen> createState() => _DeliveryZoneFormScreenState();
}

class _DeliveryZoneFormScreenState extends State<DeliveryZoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _feeController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  bool _saving = false;

  bool get _isEditing => widget.zone != null;

  @override
  void initState() {
    super.initState();
    if (widget.zone != null) {
      final z = widget.zone!;
      _nameController.text = z.name;
      _feeController.text = z.fee.toString();
      _minOrderController.text =
          z.minOrderAmount > 0 ? z.minOrderAmount.toString() : '';
      _estimatedTimeController.text = z.estimatedTime ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _feeController.dispose();
    _minOrderController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'fee': double.tryParse(_feeController.text.trim()) ?? 0,
      'min_order': double.tryParse(_minOrderController.text.trim()) ?? 0,
      if (_estimatedTimeController.text.trim().isNotEmpty)
        'estimated_time': _estimatedTimeController.text.trim(),
    };

    setState(() => _saving = true);

    final cubit = context.read<AdminDeliveryZonesCubit>();

    await cubit.upsert(data, id: _isEditing ? widget.zone!.id : null);

    if (!mounted) return;

    final currentState = cubit.state;
    if (currentState.status == AdminDeliveryZonesStatus.error) {
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
          content: Text(
              _isEditing ? 'تم تعديل منطقة التوصيل' : 'تم إضافة منطقة التوصيل'),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: _isEditing ? 'تعديل منطقة توصيل' : 'منطقة توصيل جديدة',
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
                label: 'اسم المنطقة',
                hint: 'مثال: وسط البلد',
                controller: _nameController,
                prefixIcon: Icons.map,
                validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'رسوم التوصيل (ج.م)',
                controller: _feeController,
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
                label: 'الوقت المتوقع للتوصيل (اختياري)',
                hint: 'مثال: 30-45 دقيقة',
                controller: _estimatedTimeController,
                prefixIcon: Icons.access_time,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: _isEditing ? 'تعديل المنطقة' : 'إضافة المنطقة',
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
