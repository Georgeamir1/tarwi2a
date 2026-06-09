import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.statusReady.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 56,
                  color: AppColors.statusReady,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'تم الطلب بنجاح!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'رقم الطلب: #${orderId.substring(0, 8)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'طلبك قيد المراجعة وهنبلغك بكل التحديثات',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              AppButton(
                label: 'تتبع الطلب',
                onPressed: () => context.go('/orders'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'العودة للرئيسية',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go('/home'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
