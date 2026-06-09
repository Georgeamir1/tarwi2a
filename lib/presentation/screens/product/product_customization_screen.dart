import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/app_button.dart';

class ProductCustomizationScreen extends StatefulWidget {
  const ProductCustomizationScreen({super.key});

  @override
  State<ProductCustomizationScreen> createState() =>
      _ProductCustomizationScreenState();
}

class _ProductCustomizationScreenState extends State<ProductCustomizationScreen> {
  int _quantity = 1;
  String _selectedSize = 'وسط';
  final _notesController = TextEditingController();

  final _extras = {'جبنة إضافية': false, 'طحينة': false, 'بطاطس': false};

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'تخصيص الطلب', variant: TopBarVariant.withBack),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الحجم',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['صغير', 'وسط', 'كبير'].map((size) {
                      final selected = _selectedSize == size;
                      return ChoiceChip(
                        label: Text(size),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedSize = size),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: selected ? AppColors.onPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'الإضافات',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._extras.keys.map((extra) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          extra,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        value: _extras[extra],
                        onChanged: (v) => setState(() => _extras[extra] = v ?? false),
                        activeColor: AppColors.primary,
                        checkColor: AppColors.onPrimary,
                        controlAffinity: ListTileControlAffinity.leading,
                      )),
                  const SizedBox(height: 24),
                  Text(
                    'ملاحظات خاصة',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'اكتب أي ملاحظات خاصة هنا...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'الكمية',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  QuantityStepper(
                    quantity: _quantity,
                    onIncrement: () => setState(() => _quantity++),
                    onDecrement: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                    size: 44,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Text(
                    '120 ج',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 160,
                    child: AppButton(
                      label: 'إضافة للسلة',
                      variant: AppButtonVariant.primary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
