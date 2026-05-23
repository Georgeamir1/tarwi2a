import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/logger/app_logger.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/error_banner.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _sent = true;
        });
      }
    } catch (e) {
      appLogger.e('[ForgotPassword] error', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'حصل خطأ. تأكد من البريد الإلكتروني وحاول تاني';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نسيت كلمة المرور'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _sent
              ? const _ForgotPasswordSuccess()
              : _ForgotPasswordForm(
                  formKey: _formKey,
                  emailController: _emailController,
                  isLoading: _isLoading,
                  error: _error,
                  onSendResetLink: _sendResetLink,
                ),
        ),
      ),
    );
  }
}

class _ForgotPasswordSuccess extends StatelessWidget {
  const _ForgotPasswordSuccess();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const SizedBox(
            width: 80,
            height: 80,
            child: Icon(
              Icons.mark_email_read_rounded,
              size: 40,
              color: AppColors.success,
            ),
          ),
        ),
        AppSpacing.gapH24,
        Text(
          'تم إرسال الرابط',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        AppSpacing.gapH8,
        Text(
          'بعتنا لك رابط إعادة تعيين كلمة المرور\nعلى بريدك الإلكتروني. راجعه واتبع التعليمات',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapH32,
        ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Text('العودة لتسجيل الدخول'),
        ),
      ],
    );
  }
}

class _ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final String? error;
  final VoidCallback onSendResetLink;

  const _ForgotPasswordForm({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.error,
    required this.onSendResetLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.gapH16,
          Text(
            'أدخل بريدك الإلكتروني',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.gapH4,
          Text(
            'هنبعت لك رابط عشان تعيد تعيين كلمة المرور',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.gapH32,
          Text(
            'البريد الإلكتروني',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.gapH8,
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              hintText: 'example@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'أدخل البريد الإلكتروني';
              if (!v.contains('@')) return 'بريد إلكتروني غير صحيح';
              return null;
            },
          ),
          if (error != null) ...[
            AppSpacing.gapH12,
            ErrorBanner(message: error!),
          ],
          AppSpacing.gapH32,
          LoadingButton(
            onPressed: onSendResetLink,
            label: 'إرسال رابط التعيين',
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
