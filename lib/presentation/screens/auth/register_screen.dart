import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../widgets/error_banner.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    appLogger.d('[RegisterScreen] initState');
  }

  @override
  void dispose() {
    appLogger.d('[RegisterScreen] dispose');
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      appLogger.d('[RegisterScreen] _register — form validation failed');
      return;
    }
    appLogger.d(
        '[RegisterScreen] _register — name: ${_nameController.text.trim()}, email: ${_emailController.text.trim()}');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    context.read<AuthCubit>().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
  }

  Future<void> _onAuthStateChanged(
      BuildContext context, AuthState state) async {
    if (state is Authenticated) {
      appLogger.d('[RegisterScreen] _onAuthStateChanged — authenticated');
      if (_phoneController.text.isNotEmpty) {
        appLogger.d('[RegisterScreen] updating phone number');
        final profileRepo = sl<ProfileRepository>();
        await profileRepo.updateProfile(
          state.profile.copyWith(phone: _phoneController.text.trim()),
        );
        appLogger.d('[RegisterScreen] phone saved to profile');
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      appLogger.d('[RegisterScreen] navigating to /home');
      if (!context.mounted) return;
      GoRouter.of(context).go('/home');
    } else if (state is AuthError) {
      appLogger.d('[RegisterScreen] _onAuthStateChanged — error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'حصل خطأ أثناء التسجيل، حاول تاني';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthStateChanged,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.onSurface),
            onPressed: () {
              appLogger.d('[RegisterScreen] back pressed');
              context.pop();
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'سجّل معانا 👋',
                    style: AppTypography.largeTitle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'بياناتك بتظل آمنة معانا',
                    style: AppTypography.body.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Name Field
                  _buildInputField(
                    label: 'الاسم',
                    controller: _nameController,
                    hintText: 'محمد أحمد',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'أدخل اسمك' : null,
                  ),
                  const SizedBox(height: 16),
                  // Phone Field
                  _buildInputField(
                    label: 'رقم الهاتف',
                    controller: _phoneController,
                    hintText: '01xxxxxxxxx',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  // Email Field
                  _buildInputField(
                    label: 'البريد الإلكتروني',
                    controller: _emailController,
                    hintText: 'name@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'أدخل البريد الإلكتروني';
                      }
                      if (!v.contains('@')) return 'بريد إلكتروني غير صحيح';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'كلمة المرور',
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: '6 أحرف على الأقل',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppColors.onSurfaceVariant),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () {
                              appLogger.d(
                                  '[RegisterScreen] toggle password visibility');
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                          if (v.length < 6) return 'على الأقل 6 أحرف';
                          return null;
                        },
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    ErrorBanner(message: _error!),
                  ],
                  const SizedBox(height: 32),
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : Text(
                              'إنشاء الحساب',
                              style: AppTypography.headline.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'عندك حساب؟ ',
                        style: AppTypography.body.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          appLogger.d('[RegisterScreen] navigate to /login');
                          context.pop();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'سجّل دخول',
                          style: AppTypography.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.footnote.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
