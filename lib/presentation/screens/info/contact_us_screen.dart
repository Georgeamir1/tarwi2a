import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال رسالتك بنجاح')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;

    return Scaffold(
      appBar: const AppTopBar(
          title: 'تواصل معانا', variant: TopBarVariant.withBack),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'عندك اقتراح أو مشكلة؟ ابعتلنا رسالة وهنرد عليك في أقرب وقت.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: secondaryColor,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'الاسم',
                hint: 'اسمك الكريم',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'الإيميل',
                hint: 'example@email.com',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v?.trim().isEmpty == true) return 'مطلوب';
                  if (v != null && !v.contains('@')) {
                    return 'إيميل غير صالح';
                  }
                  return null;
                },
              ),
              AppSpacing.gapH16,
              AppTextField(
                label: 'الرسالة',
                hint: 'اكتب رسالتك هنا...',
                controller: _messageController,
                prefixIcon: Icons.message_outlined,
                maxLines: 4,
                validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'إرسال الرسالة',
                onPressed: _onSubmit,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              const _ContactMethod(
                icon: Icons.email_outlined,
                title: 'الإيميل',
                subtitle: 'support@troo2a.com',
              ),
              const SizedBox(height: 16),
              const _ContactMethod(
                icon: Icons.phone_outlined,
                title: 'التليفون',
                subtitle: '+20 100 000 0000',
              ),
              const SizedBox(height: 16),
              const _ContactMethod(
                icon: Icons.location_on_outlined,
                title: 'العنوان',
                subtitle: 'القاهرة، مصر',
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactMethod extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ContactMethod({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.onSurfaceVariant,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
