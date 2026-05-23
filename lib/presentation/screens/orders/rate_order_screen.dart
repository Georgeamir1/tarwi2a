import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';

class RateOrderScreen extends StatefulWidget {
  const RateOrderScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);return Scaffold(
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
                color: AppColors.statusPending.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.star_outline,
                size: 40,
                color: AppColors.statusPending,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'إيه رأيك في الطلب؟',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 44,
                      color: AppColors.statusPending,
                    ),
                  ),
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
                        const SnackBar(content: Text('شكراً لتقييمك!')),
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
