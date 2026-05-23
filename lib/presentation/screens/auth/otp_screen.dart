import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/logger/app_logger.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/error_banner.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _verified = false;
  String? _error;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(String value, int index) {
    if (value.length > 1) {
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[index].text.length),
      );
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isNotEmpty) {
      setState(() {});
    }
  }

  void _onKey(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    final otp = _otp;
    if (otp.length < 6) {
      setState(() => _error = 'أدخل رمز التحقق كامل (6 أرقام)');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.recovery,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _verified = true;
        });
      }
    } catch (e) {
      appLogger.e('[OTP] verify error', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'الرمز غير صحيح أو منتهي الصلاحية. حاول تاني';
        });
      }
    }
  }

  Future<void> _resend() async {
    setState(() {
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        widget.email,
      );
      _startTimer();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      appLogger.e('[OTP] resend error', error: e);
      if (mounted) {
        setState(() => _error = 'حصل خطأ في إعادة الإرسال. حاول تاني');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الرمز'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _verified
              ? const _OtpVerified()
              : _OtpForm(
                  email: widget.email,
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  isLoading: _isLoading,
                  error: _error,
                  secondsRemaining: _secondsRemaining,
                  onDigitChanged: _onDigitChanged,
                  onKey: _onKey,
                  onVerify: _verify,
                  onResend: _resend,
                ),
        ),
      ),
    );
  }
}

class _OtpVerified extends StatelessWidget {
  const _OtpVerified();

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
              Icons.verified_user_rounded,
              size: 40,
              color: AppColors.success,
            ),
          ),
        ),
        AppSpacing.gapH24,
        Text(
          'تم التحقق',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        AppSpacing.gapH8,
        Text(
          'تم تأكيد الرمز بنجاح.\nتقدر دلوقتي تعيد تعيين كلمة المرور',
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

class _OtpForm extends StatelessWidget {
  final String email;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isLoading;
  final String? error;
  final int secondsRemaining;
  final void Function(String, int) onDigitChanged;
  final void Function(KeyEvent, int) onKey;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _OtpForm({
    required this.email,
    required this.controllers,
    required this.focusNodes,
    required this.isLoading,
    required this.error,
    required this.secondsRemaining,
    required this.onDigitChanged,
    required this.onKey,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.gapH16,
        Text(
          'رمز التحقق',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        AppSpacing.gapH4,
        RichText(
          text: TextSpan(
            text: 'أدخل الرمز اللي اتبعت على ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapH32,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.ltr,
          children: List.generate(6, (i) {
            final isFilled = controllers[i].text.isNotEmpty;
            return DecoratedBox(
              decoration: const BoxDecoration(),
              child: SizedBox(
                width: 48,
                height: 56,
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => onKey(event, i),
                  child: TextField(
                    controller: controllers[i],
                    focusNode: focusNodes[i],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: isFilled
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(
                          color:
                              isFilled ? AppColors.primary : AppColors.divider,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(
                          color:
                              isFilled ? AppColors.primary : AppColors.divider,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (v) => onDigitChanged(v, i),
                  ),
                ),
              ),
            );
          }),
        ),
        if (error != null) ...[
          AppSpacing.gapH16,
          ErrorBanner(message: error!),
        ],
        AppSpacing.gapH32,
        LoadingButton(
          onPressed: onVerify,
          label: 'تأكيد',
          isLoading: isLoading,
        ),
        AppSpacing.gapH16,
        Center(
          child: secondsRemaining > 0
              ? Text(
                  'إعادة الإرسال بعد $secondsRemaining ثانية',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              : TextButton(
                  onPressed: onResend,
                  child: Text(
                    'إعادة إرسال الرمز',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
