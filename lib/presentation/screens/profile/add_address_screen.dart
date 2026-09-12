import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/entities/delivery_zone.dart';
import '../../../domain/repositories/delivery_zone_repository.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/address/address_cubit.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';

enum AddressType { home, work, custom }

class AddAddressScreen extends StatefulWidget {
  final Address? addressToEdit;

  const AddAddressScreen({
    super.key,
    this.addressToEdit,
  });

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
  List<DeliveryZone> _zones = [];
  DeliveryZone? _selectedZone;
  bool _isLoadingZones = true;

  AddressType _selectedType = AddressType.home;
  late final AddressCubit _addressCubit;

  @override
  void initState() {
    super.initState();
    _addressCubit = sl<AddressCubit>();
    _initFields();
    _loadZones();
  }

  void _initFields() {
    if (widget.addressToEdit != null) {
      final address = widget.addressToEdit!;
      _labelController.text = address.label;
      _addressController.text = address.address;
      _buildingController.text = address.building ?? '';
      _floorController.text = address.floor ?? '';
      _apartmentController.text = address.apartment ?? '';
      _notesController.text = address.notes ?? '';
      _isDefault = address.isDefault;

      // Detect type
      final labelLower = address.label.trim().toLowerCase();
      if (labelLower == 'البيت' || labelLower == 'home') {
        _selectedType = AddressType.home;
      } else if (labelLower == 'العمل' ||
          labelLower == 'الشغل' ||
          labelLower == 'work') {
        _selectedType = AddressType.work;
      } else {
        _selectedType = AddressType.custom;
      }
    } else {
      // Default type for new address
      _selectedType = AddressType.home;
      _labelController.text = 'البيت';
    }
  }

  Future<void> _loadZones() async {
    final result = await sl<DeliveryZoneRepository>().getAll();
    if (mounted) {
      result.fold(
        (_) => setState(() {
          _zones = [];
          _isLoadingZones = false;
        }),
        (zones) => setState(() {
          _zones = zones.where((z) => z.isActive).toList();
          _isLoadingZones = false;

          // Pre-select zone if editing
          if (widget.addressToEdit != null &&
              widget.addressToEdit!.deliveryZoneId != null) {
            final matching = _zones.where(
              (z) => z.id == widget.addressToEdit!.deliveryZoneId,
            );
            _selectedZone = matching.isNotEmpty ? matching.first : null;
          }
        }),
      );
    }
  }

  @override
  void dispose() {
    _addressCubit.close();
    _labelController.dispose();
    _addressController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return;

    setState(() => _isSaving = true);

    String finalLabel = '';
    if (_selectedType == AddressType.home) {
      finalLabel = 'البيت';
    } else if (_selectedType == AddressType.work) {
      finalLabel = 'العمل';
    } else {
      finalLabel = _labelController.text.trim();
    }

    final data = {
      'label': finalLabel,
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
      // Pass a default latitude/longitude for pinning
      'latitude': 30.0444,
      'longitude': 31.2357,
      if (_selectedZone != null) 'delivery_zone_id': _selectedZone!.id,
      if (_selectedZone != null) 'delivery_zone_name': _selectedZone!.name,
      if (_selectedZone != null) 'delivery_fee': _selectedZone!.fee,
    };

    try {
      final result = widget.addressToEdit != null
          ? await _addressCubit.updateAddress(
              widget.addressToEdit!.id, data, authState.profile.id)
          : await _addressCubit.createAddress(authState.profile.id, data);

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (_) {
          HapticFeedback.mediumImpact();
          Navigator.of(context).pop(true);
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حصل خطأ أثناء الحفظ، حاول تاني'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildTypeChip(AddressType type, String label, IconData outlineIcon,
      IconData filledIcon) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: isSelected ? AppColors.primaryContainer : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedType = type;
              if (type == AddressType.home) {
                _labelController.text = 'البيت';
              } else if (type == AddressType.work) {
                _labelController.text = 'العمل';
              } else if (widget.addressToEdit == null ||
                  _getTypeFromLabel(widget.addressToEdit!.label) !=
                      AddressType.custom) {
                _labelController.clear();
              } else {
                _labelController.text = widget.addressToEdit!.label;
              }
            });
          },
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color:
                    isSelected ? AppColors.primary : AppColors.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? filledIcon : outlineIcon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? AppColors.onPrimaryContainer
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AddressType _getTypeFromLabel(String label) {
    final labelLower = label.trim().toLowerCase();
    if (labelLower == 'البيت' || labelLower == 'home') {
      return AddressType.home;
    } else if (labelLower == 'العمل' ||
        labelLower == 'الشغل' ||
        labelLower == 'work') {
      return AddressType.work;
    } else {
      return AddressType.custom;
    }
  }

  Widget _buildMockMap() {
    final theme = Theme.of(context);
    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MockMapPainter(),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: const [AppShadows.card],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.gps_fixed,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'تم تحديد موقع الدليفرى',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.successOnContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _PulsingPin(),
                  const SizedBox(height: 4),
                  Container(
                    width: 12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneDropdown() {
    final theme = Theme.of(context);
    if (_isLoadingZones) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }
    if (_zones.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.tertiary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'مفيش مناطق توصيل متاحة حالياً — هيضيفها الأدمن',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return DropdownButtonFormField<DeliveryZone>(
      initialValue: _selectedZone,
      decoration: InputDecoration(
        labelText: 'منطقة التوصيل',
        prefixIcon: const Icon(Icons.map_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      isExpanded: true,
      hint: Text(
        'اختر المنطقة لتاكيد التوصيل',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: AppColors.textSecondary),
      ),
      items: _zones.map((zone) {
        return DropdownMenuItem<DeliveryZone>(
          value: zone,
          child: Text(
            zone.name,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textPrimary),
          ),
        );
      }).toList(),
      validator: (value) => value == null ? 'مطلوب اختيار منطقة التوصيل' : null,
      onChanged: (zone) => setState(() => _selectedZone = zone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = widget.addressToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: isEditMode ? 'تعديل العنوان' : 'عنوان جديد',
        variant: TopBarVariant.withBack,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SECTION 1: نوع العنوان
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اسم العنوان',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTypeChip(
                              AddressType.home,
                              'البيت',
                              Icons.home_outlined,
                              Icons.home_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildTypeChip(
                              AddressType.work,
                              'العمل',
                              Icons.work_outline,
                              Icons.work_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildTypeChip(
                              AddressType.custom,
                              'أخرى',
                              Icons.label_outline,
                              Icons.label_important_rounded,
                            ),
                          ],
                        ),
                        if (_selectedType == AddressType.custom) ...[
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'اسم العنوان المخصص',
                            hint: 'مثال: الجيم، بيت العيلة',
                            controller: _labelController,
                            prefixIcon: Icons.label_important_outline,
                            validator: (v) => v?.trim().isEmpty == true
                                ? 'أدخل اسم العنوان'
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // SECTION 2: تفاصيل الموقع
                Card(
                  margin: const EdgeInsets.only(top: AppSpacing.lg),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل الموقع',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildMockMap(),
                        _buildZoneDropdown(),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'العنوان بالتفصيل',
                          hint: 'مثال: شارع 9، بجوار صيدلية العزبي، المعادي',
                          controller: _addressController,
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 2,
                          validator: (v) => v?.trim().isEmpty == true
                              ? 'مطلوب تحديد العنوان بالتفصيل'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                // SECTION 3: تفاصيل المبنى
                Card(
                  margin: const EdgeInsets.only(top: AppSpacing.lg),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل المبنى (اختياري)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'رقم العمارة / اسم المبنى',
                          hint: 'مثال: عمارة رقم 5 ب',
                          controller: _buildingController,
                          prefixIcon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'الدور',
                                hint: 'مثال: الخامس',
                                controller: _floorController,
                                prefixIcon: Icons.layers_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'الشقة',
                                hint: 'مثال: شقة 10',
                                controller: _apartmentController,
                                prefixIcon: Icons.door_front_door_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'ملاحظات للتوصيل',
                          hint: 'مثال: رن جرس الباب، أو سيبه مع البواب',
                          controller: _notesController,
                          prefixIcon: Icons.note_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'تعيين كعنوان افتراضي',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'هيتم اختياره تلقائياً وقت الشراء',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          value: _isDefault,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) => setState(() => _isDefault = v),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: isEditMode ? 'تحديث العنوان' : 'حفظ العنوان الجديد',
                  onPressed: _isSaving ? null : _onSave,
                  isLoading: _isSaving,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingPin extends StatefulWidget {
  const _PulsingPin();

  @override
  State<_PulsingPin> createState() => _PulsingPinState();
}

class _PulsingPinState extends State<_PulsingPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * _controller.value),
          child: const Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 38,
          ),
        );
      },
    );
  }
}

class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintRoad = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.7)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintPark = Paint()
      ..color = Colors.green.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Draw a park rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(16, 16, size.width * 0.35, size.height * 0.5),
        const Radius.circular(8),
      ),
      paintPark,
    );

    // Draw roads paths
    final path = Path();
    // Road 1 (horizontal)
    path.moveTo(0, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);

    // Road 2 (vertical)
    path.moveTo(size.width * 0.6, 0);
    path.lineTo(size.width * 0.6, size.height);

    // Road 3 (diagonal)
    path.moveTo(size.width * 0.1, 0);
    path.lineTo(size.width * 0.9, size.height);

    canvas.drawPath(path, paintRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
