import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;

    return Scaffold(
      appBar:
          const AppTopBar(title: 'عن التطبيق', variant: TopBarVariant.withBack),
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
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.restaurant,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ترويئه',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الإصدار 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'ترويئه هو تطبيق طلبات أكل عربي أصيل. بنوصلك أشهى الأكلات من أفضل المطاعم لحد باب بيتك. تقدر تتصفح القوائم، تطلب بسهولة، وتتابع طلبك خطوة بخطوة.',
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            const _InfoRow(
              icon: Icons.rocket_launch_outlined,
              title: 'مهمتنا',
              subtitle: 'توصيل أشهى الأكلات العربية بسرعة وجودة عالية',
            ),
            const SizedBox(height: 24),
            const _InfoRow(
              icon: Icons.visibility_outlined,
              title: 'رؤيتنا',
              subtitle: 'نكون المنصة الأولى لتوصيل الطعام العربي في المنطقة',
            ),
            const SizedBox(height: 24),
            const _InfoRow(
              icon: Icons.handshake_outlined,
              title: 'قيمنا',
              subtitle: 'الجودة، السرعة، الأمانة، والاهتمام بالعميل',
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
