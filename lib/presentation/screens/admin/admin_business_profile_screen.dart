import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_business_profile_cubit.dart';
import '../../../domain/entities/business_profile.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';
import '../../widgets/opening_hours_editor.dart';

class AdminBusinessProfileScreen extends StatefulWidget {
  const AdminBusinessProfileScreen({super.key});

  @override
  State<AdminBusinessProfileScreen> createState() => _AdminBusinessProfileScreenState();
}

class _AdminBusinessProfileScreenState extends State<AdminBusinessProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminBusinessProfileCubit>().loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _ProfileBody();
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBusinessProfileCubit, AdminBusinessProfileState>(
      builder: (context, state) {
        return switch (state.status) {
          AdminBusinessProfileStatus.loading => const Scaffold(
              appBar: AppTopBar(
                title: 'الملف التجاري',
                variant: TopBarVariant.withBack,
              ),
              body: Center(child: CircularProgressIndicator()),
            ),
          AdminBusinessProfileStatus.loaded ||
          AdminBusinessProfileStatus.initial =>
            _ProfileForm(profile: state.profile),
          AdminBusinessProfileStatus.error => Scaffold(
              appBar: const AppTopBar(
                title: 'الملف التجاري',
                variant: TopBarVariant.withBack,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.failure?.message ?? 'حدث خطأ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    AppSpacing.gapH16,
                    AppButton(
                      label: 'إعادة المحاولة',
                      onPressed: () => context
                          .read<AdminBusinessProfileCubit>()
                          .loadProfile(),
                    ),
                  ],
                ),
              ),
            ),
        };
      },
    );
  }
}

class _ProfileForm extends StatefulWidget {
  final BusinessProfile? profile;

  const _ProfileForm({required this.profile});

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _minOrderController;
  late TextEditingController _prepTimeController;
  late TextEditingController _busyMessageController;
  late bool _acceptOrders;
  late bool _isBusy;
  late Map<String, OpeningPeriod> _openingHours;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p?.name ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _minOrderController =
        TextEditingController(text: p?.minOrder.toString() ?? '0');
    _prepTimeController =
        TextEditingController(text: p?.defaultPrepTime.toString() ?? '30');
    _busyMessageController = TextEditingController(text: p?.busyMessage ?? '');
    _acceptOrders = p?.acceptOrders ?? true;
    _isBusy = p?.isBusy ?? false;
    _openingHours = Map<String, OpeningPeriod>.from(p?.openingHours ?? {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _minOrderController.dispose();
    _prepTimeController.dispose();
    _busyMessageController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final hoursJson = _openingHours.map(
      (key, value) => MapEntry(key, {'open': value.open, 'close': value.close}),
    );

    context.read<AdminBusinessProfileCubit>().update({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'min_order': double.tryParse(_minOrderController.text) ?? 0,
      'default_prep_time': int.tryParse(_prepTimeController.text) ?? 30,
      'opening_hours': hoursJson,
      'busy_message': _busyMessageController.text.trim().isEmpty
          ? null
          : _busyMessageController.text.trim(),
    });
  }

  void _toggleAcceptOrders() {
    final newValue = !_acceptOrders;
    final cubit = context.read<AdminBusinessProfileCubit>();
    cubit.toggleAcceptOrders(newValue);
    setState(() => _acceptOrders = newValue);
  }

  void _toggleBusyMode() {
    final newValue = !_isBusy;
    final cubit = context.read<AdminBusinessProfileCubit>();
    cubit.toggleBusyMode(
      isBusy: newValue,
      message: newValue ? _busyMessageController.text.trim() : null,
    );
    setState(() => _isBusy = newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'الملف التجاري',
        variant: TopBarVariant.withBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.store,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapH24,
              AppTextField(
                label: 'اسم المطعم',
                controller: _nameController,
                prefixIcon: Icons.store_outlined,
                validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'رقم التليفون',
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'العنوان',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'الحد الأدنى للطلب (جنيه)',
                controller: _minOrderController,
                prefixIcon: Icons.money_off_outlined,
                keyboardType: TextInputType.number,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'وقت التحضير الافتراضي (دقيقة)',
                controller: _prepTimeController,
                prefixIcon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
              ),
              AppSpacing.gapH24,
              Text(
                'مواعيد العمل',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.gapH12,
              OpeningHoursEditor(
                hours: _openingHours,
                onChanged: (hours) => _openingHours = hours,
              ),
              AppSpacing.gapH24,
              _ToggleTile(
                icon: Icons.shopping_cart_outlined,
                title: 'قبول الطلبات',
                subtitle: _acceptOrders
                    ? 'يتم قبول الطلبات الجديدة'
                    : 'الطلبات الجديدة معلقة',
                value: _acceptOrders,
                onChanged: (_) => _toggleAcceptOrders(),
              ),
              AppSpacing.gapH12,
              _ToggleTile(
                icon: Icons.warning_amber_outlined,
                title: 'وضع الانشغال',
                subtitle: _isBusy ? 'المطعم مشغول حالياً' : 'الخدمة طبيعية',
                value: _isBusy,
                onChanged: (_) => _toggleBusyMode(),
              ),
              if (_isBusy) ...[
                AppSpacing.gapH12,
                AppTextField(
                  label: 'رسالة الانشغال',
                  controller: _busyMessageController,
                  prefixIcon: Icons.message_outlined,
                  hint: 'مثال: وقت التحضير أطول من المعتاد',
                ),
              ],
              AppSpacing.gapH32,
              AppButton(
                label: 'حفظ التغييرات',
                onPressed: _save,
              ),
              AppSpacing.gapH48,
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: value
          ? AppColors.primary.withValues(alpha: 0.06)
          : AppColors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: SwitchListTile(
        secondary: Icon(
          icon,
          color: value ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    );
  }
}
