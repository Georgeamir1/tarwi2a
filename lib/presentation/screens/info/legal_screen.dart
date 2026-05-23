import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;

    return Scaffold(
      appBar: const AppTopBar(
          title: 'الشروط والأحكام', variant: TopBarVariant.withBack),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الشروط والأحكام',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'آخر تحديث: 2025',
              style: theme.textTheme.bodySmall?.copyWith(color: secondaryColor),
            ),
            const SizedBox(height: 24),
            const _Section(
              title: '1. مقدمة',
              content:
                  'باستخدامك لتطبيق ترويقه، انت بتوافق على الشروط والأحكام دي. لو مش موافق، من فضلك متستخدمش التطبيق. بنحتفظ بحقنا في تعديل الشروط في أي وقت، والتعديلات هتسري فور نشرها.',
            ),
            const _Section(
              title: '2. الحساب',
              content:
                  'لازم يكون عندك 18 سنة على الأقل عشان تعمل حساب. انت مسؤول عن الحفاظ على سرية بيانات حسابك وكلمة السر. أي نشاط بيحصل من خلال حسابك هو مسؤوليتك.',
            ),
            const _Section(
              title: '3. الطلبات',
              content:
                  'كل الطلبات بتعتبر عروض شراء وبتخضع للقبول من المطعم. بنحتفظ بحقنا في رفض أو إلغاء أي طلب لأي سبب. الأسعار قابلة للتغيير بدون إشعار مسبق.',
            ),
            const _Section(
              title: '4. الدفع',
              content:
                  'طرق الدفع المتاحة: كاش عند الاستلام، محفظة إلكترونية، انستا باي. كل المدفوعات بالجنيه المصري. الضرائب مشمولة في الأسعار المعروضة.',
            ),
            const _Section(
              title: '5. الإلغاء والاسترجاع',
              content:
                  'تقدر تلغي الطلب قبل ما المطعم يبدأ في تجهيزه. بعد بدء التجهيز، مش هتقدر تلغي الطلب. في حالة وجود مشكلة في الطلب، تقدر تتواصل معانا خلال 24 ساعة.',
            ),
            const _Section(
              title: '6. الخصوصية',
              content:
                  'بنحمي خصوصيتك. البيانات الشخصية بتستخدم بس عشان نقدملك الخدمة ومش هنشاركها مع أي طرف تالت غير المطعم اللي بتطلب منه. للمزيد، راجع سياسة الخصوصية.',
            ),
            const _Section(
              title: '7. حدود المسؤولية',
              content:
                  'ترويقه مجرد وسيط بينك وبين المطاعم. مش مسؤولين عن جودة الأكل أو التأخير اللي بيحصل من المطعم أو عامل التوصيل. بنسعى دايمًا لحل أي مشكلة بشكل ودي.',
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
