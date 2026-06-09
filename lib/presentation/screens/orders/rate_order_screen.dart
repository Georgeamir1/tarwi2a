import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/logger/app_logger.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';

class RateOrderScreen extends StatefulWidget {
  final String orderId;

  const RateOrderScreen({super.key, required this.orderId});

  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getFeedbackText(int rating) {
    switch (rating) {
      case 1:
        return 'سيء جداً 😞';
      case 2:
        return 'مقبول 😐';
      case 3:
        return 'جيد 🙂';
      case 4:
        return 'رائع جداً 😄';
      case 5:
        return 'ممتاز! عاشت الأيادي 😍';
      default:
        return 'اضغط على النجوم لتقييم الطلب';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    appLogger.i('[RateOrderScreen] build — orderId: ${widget.orderId}');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'قيم طلبك', variant: TopBarVariant.withBack),
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
                color: AppColors.tertiary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.star_outline_rounded,
                size: 40,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'إيه رأيك في الطلب؟',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _getFeedbackText(_rating),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _rating > 0 ? AppColors.tertiary : AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1;
                final isSelected = starVal <= _rating;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: isSelected ? 1.12 : 1.0),
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: GestureDetector(
                        onTap: () => setState(() => _rating = starVal),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 48,
                            color: isSelected ? AppColors.tertiary : AppColors.outlineVariant,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 32),
            AppTextField(
              label: 'تعليقك (اختياري)',
              hint: 'اكتب رأيك في الأكل والخدمة...',
              controller: _commentController,
              prefixIcon: Icons.edit_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'إرسال التقييم',
              onPressed: _rating > 0
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('شكراً لتقييمك!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      context.pop();
                    }
                  : null,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
