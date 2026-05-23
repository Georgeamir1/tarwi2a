import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class CouponInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;
  final bool isLoading;

  const CouponInput({
    super.key,
    required this.controller,
    required this.onApply,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {final isDark = Theme.of(context).brightness == Brightness.dark;

return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.discount_outlined,
              color: AppColors.secondary, size: 22),
          AppSpacing.gapW8,
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'كود الخصم',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          AppSpacing.gapW8,
          SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: isLoading ? null : onApply,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('تطبيق'),
            ),
          ),
        ],
      ),
    );
  }
}
