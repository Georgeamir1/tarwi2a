import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_button.dart';

class PaymentProofScreen extends StatefulWidget {
  const PaymentProofScreen({super.key});

  @override
  State<PaymentProofScreen> createState() => _PaymentProofScreenState();
}

class _PaymentProofScreenState extends State<PaymentProofScreen> {
  bool _uploaded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: const AppTopBar(
        title: 'إثبات الدفع',
        variant: TopBarVariant.withBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ارفع صورة إثبات الدفع',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'من فضلك ارفع صورة إيصال التحويل عشان نقدر نأكد طلبك',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => setState(() => _uploaded = true),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: _uploaded
                    ? const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: AppColors.statusReady,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'اضغط لاختيار صورة',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'تأكيد الرفع',
              variant: _uploaded
                  ? AppButtonVariant.primary
                  : AppButtonVariant.secondary,
              onPressed: _uploaded ? () => context.pop() : null,
            ),
          ],
        ),
      ),
    );
  }
}
