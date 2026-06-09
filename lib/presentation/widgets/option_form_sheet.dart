import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_theme.dart';
import '../../domain/entities/product_option.dart';

/// Bottom sheet form for adding/editing a product option.
/// Returns the option data map on save, or null on cancel.
class OptionFormSheet extends StatefulWidget {
  final ProductOption? option;

  const OptionFormSheet({super.key, this.option});

  /// Shows the bottom sheet and returns the option data map or null.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    ProductOption? option,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OptionFormSheet(option: option),
    );
  }

  @override
  State<OptionFormSheet> createState() => _OptionFormSheetState();
}

class _OptionFormSheetState extends State<OptionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nameArController;
  late final TextEditingController _priceController;
  late final TextEditingController _maxSelectionsController;
  late bool _isRequired;

  bool get _isEditing => widget.option != null;

  @override
  void initState() {
    super.initState();
    final opt = widget.option;
    _nameController = TextEditingController(text: opt?.name ?? '');
    _nameArController = TextEditingController(text: opt?.nameAr ?? '');
    _priceController = TextEditingController(
      text: opt != null && opt.priceDelta != 0
          ? opt.priceDelta.toStringAsFixed(0)
          : '',
    );
    _maxSelectionsController = TextEditingController(
      text: opt?.maxSelections.toString() ?? '1',
    );
    _isRequired = opt?.isRequired ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _priceController.dispose();
    _maxSelectionsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'name_ar': _nameArController.text.trim(),
      'price_delta': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'is_required': _isRequired,
      'max_selections':
          int.tryParse(_maxSelectionsController.text.trim()) ?? 1,
    };

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  _isEditing ? 'تعديل الخيار' : 'إضافة خيار جديد',
                  style: AppTypography.headline.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Name fields
                _SectionLabel(icon: Icons.text_fields_rounded, label: 'اسم الخيار'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameArController,
                  decoration: const InputDecoration(
                    hintText: 'بالعربية (مثل: جبن إضافي)',
                    prefixIcon: Icon(Icons.translate_rounded, size: 20),
                  ),
                  textDirection: TextDirection.rtl,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'In English (e.g. Extra Cheese)',
                    prefixIcon: Icon(Icons.language_rounded, size: 20),
                  ),
                  textDirection: TextDirection.ltr,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 20),

                // Price delta
                _SectionLabel(icon: Icons.payments_rounded, label: 'السعر الإضافي'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    hintText: '0',
                    suffixText: 'ر.س',
                    prefixIcon: Icon(Icons.add_circle_outline_rounded, size: 20),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                ),
                const SizedBox(height: 20),

                // Max selections
                _SectionLabel(icon: Icons.tune_rounded, label: 'الحد الأقصى للاختيارات'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _maxSelectionsController,
                  decoration: const InputDecoration(
                    hintText: '1',
                    prefixIcon: Icon(Icons.format_list_numbered_rounded, size: 20),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 16),

                // Required toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'خيار إجباري',
                          style: AppTypography.callout.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Switch(
                        value: _isRequired,
                        onChanged: (v) => setState(() => _isRequired = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded),
                  label: Text(_isEditing ? 'حفظ التعديلات' : 'إضافة الخيار'),
                ),
                const SizedBox(height: 8),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.footnote.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
