import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/address/address_cubit.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return;

    setState(() => _isSaving = true);

    final data = {
      'label': _labelController.text.trim(),
      'address': _addressController.text.trim(),
      'building': _buildingController.text.trim().isEmpty
          ? null
          : _buildingController.text.trim(),
      'floor': _floorController.text.trim().isEmpty
          ? null
          : _floorController.text.trim(),
      'apartment': _apartmentController.text.trim().isEmpty
          ? null
          : _apartmentController.text.trim(),
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      'is_default': _isDefault,
    };

    try {
      await sl<AddressCubit>().createAddress(authState.profile.id, data);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حصل خطأ، حاول تاني')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
          title: 'عنوان جديد', variant: TopBarVariant.withBack),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'اسم العنوان',
                hint: 'مثال: البيت، الشغل',
                controller: _labelController,
                prefixIcon: Icons.label_outline,
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'مطلوب' : null,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'العنوان بالتفصيل',
                hint: 'الشارع، المنطقة',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'مطلوب' : null,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'رقم العمارة (اختياري)',
                controller: _buildingController,
                prefixIcon: Icons.business_outlined,
              ),
              AppSpacing.gapH16,
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'الدور',
                      controller: _floorController,
                      prefixIcon: Icons.layers_outlined,
                    ),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: AppTextField(
                      label: 'الشقة',
                      controller: _apartmentController,
                      prefixIcon: Icons.door_front_door_outlined,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'ملاحظات (اختياري)',
                controller: _notesController,
                prefixIcon: Icons.note_outlined,
                maxLines: 2,
              ),
              AppSpacing.gapH16,
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('تعيين كعنوان افتراضي'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                activeTrackColor: AppColors.primary,
              ),
              AppSpacing.gapH24,
              AppButton(
                label: 'حفظ العنوان',
                onPressed: _isSaving ? null : _onSave,
                isLoading: _isSaving,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
