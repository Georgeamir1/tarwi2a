import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
          title: 'أسئلة شائعة', variant: TopBarVariant.withBack),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: faqs
            .map((faq) => _FaqTile(
                  question: faq.$1,
                  answer: faq.$2,
                ))
            .toList(),
      ),
    );
  }

  static const faqs = [
    (
      'إزاي أعمل طلب؟',
      'اختار الأكلات اللي عايزها من القائمة، ضيفها للسلة، وبعدين ادفع. الطلب بتاعك هيوصلك في 30-45 دقيقة.'
    ),
    (
      'إيه طرق الدفع المتاحة؟',
      'تقدر تدفع كاش عند الاستلام، أو عن طريق المحفظة الإلكترونية، أو انستا باي.'
    ),
    (
      'إزاي أتابع طلبي؟',
      'تقدر تتابع حالة طلبك من صفحة "طلباتي". هيجيلك إشعارات بكل تحديث في حالة الطلب.'
    ),
    (
      'هل ممكن ألغي الطلب؟',
      'أيوه، تقدر تلغي الطلب قبل ما المطعم يبدأ في تجهيزه. لو الطلب بدأ يتجهز، مش هتقدر تكنسله.'
    ),
    (
      'إزاي أضيف عنوان توصيل؟',
      'ادخل على حسابي > عناويني > إضافة عنوان جديد، واكتب بيانات العنوان.'
    ),
    (
      'هل في حد أدنى للطلب؟',
      'الحد الأدنى للطلب 50 جنيه. بعض المناطق ممكن يكون فيها حد أدنى مختلف.'
    ),
    (
      'الأسعار شاملة الضريبة؟',
      'أيوه، كل الأسعار المعروضة شاملة ضريبة القيمة المضافة.'
    ),
    (
      'إزاي أستخدم كود الخصم؟',
      'في صفحة السلة، اكتب كود الخصم في المكان المخصص واضغط "تطبيق".'
    ),
  ];
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Text(
              widget.answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
