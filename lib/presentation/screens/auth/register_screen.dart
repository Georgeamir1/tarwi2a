import 'dart:ui';
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

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  bool _nameFocused = false;
  bool _phoneFocused = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  // Current step (0-3) — for progress indicator
  int _activeField = 0;

  // Password strength (0-4)
  int _passwordStrength = 0;

  // Stagger animation
  late AnimationController _staggerController;
  late Animation<double> _headerFade;
  late Animation<double> _field1Fade;
  late Animation<Offset> _field1Slide;
  late Animation<double> _field2Fade;
  late Animation<Offset> _field2Slide;
  late Animation<double> _field3Fade;
  late Animation<Offset> _field3Slide;
  late Animation<double> _field4Fade;
  late Animation<Offset> _field4Slide;
  late Animation<double> _ctaFade;

  // Button press
  late AnimationController _btnController;
  late Animation<double> _btnScale;

  // Step indicator line animation
  late AnimationController _stepLineController;

  @override
  void initState() {
    super.initState();
    appLogger.d('[RegisterScreen] initState');

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    _headerFade = _makeInterval(0.0, 0.3);

    _field1Fade = _makeInterval(0.2, 0.45);
    _field1Slide = _makeSlide(0.2, 0.45);
    _field2Fade = _makeInterval(0.35, 0.58);
    _field2Slide = _makeSlide(0.35, 0.58);
    _field3Fade = _makeInterval(0.48, 0.70);
    _field3Slide = _makeSlide(0.48, 0.70);
    _field4Fade = _makeInterval(0.60, 0.82);
    _field4Slide = _makeSlide(0.60, 0.82);
    _ctaFade = _makeInterval(0.75, 1.0);

    _btnController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      value: 1.0,
    );
    _btnScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeOut),
    );

    _stepLineController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Focus listeners
    _nameFocusNode.addListener(() {
      setState(() {
        _nameFocused = _nameFocusNode.hasFocus;
        if (_nameFocused) _updateActiveField(0);
      });
    });
    _phoneFocusNode.addListener(() {
      setState(() {
        _phoneFocused = _phoneFocusNode.hasFocus;
        if (_phoneFocused) _updateActiveField(1);
      });
    });
    _emailFocusNode.addListener(() {
      setState(() {
        _emailFocused = _emailFocusNode.hasFocus;
        if (_emailFocused) _updateActiveField(2);
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordFocused = _passwordFocusNode.hasFocus;
        if (_passwordFocused) _updateActiveField(3);
      });
    });

    // Password strength listener
    _passwordController.addListener(_calculatePasswordStrength);

    _staggerController.forward();
  }

  void _updateActiveField(int field) {
    _activeField = field;
    _stepLineController.forward(from: 0.0);
  }

  void _calculatePasswordStrength() {
    final password = _passwordController.text;
    int strength = 0;

    if (password.length >= 6) strength = 1; // weak
    if (password.length >= 8 && password.contains(RegExp(r'[0-9]'))) {
      strength = 2; // medium
    }
    if (password.length >= 8 &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[A-Z]'))) {
      strength = 3; // strong
    }
    if (password.length >= 10 &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      strength = 4; // very strong
    }

    if (strength != _passwordStrength) {
      setState(() => _passwordStrength = strength);
    }
  }

  Animation<double> _makeInterval(double start, double end) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _makeSlide(double start, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    appLogger.d('[RegisterScreen] dispose');
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _staggerController.dispose();
    _btnController.dispose();
    _stepLineController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      appLogger.d('[RegisterScreen] validation failed');
      return;
    }
    appLogger.d('[RegisterScreen] registering...');
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
      appLogger.d('[RegisterScreen] authenticated');
      if (_phoneController.text.isNotEmpty) {
        final profileRepo = sl<ProfileRepository>();
        await profileRepo.updateProfile(
          state.profile.copyWith(phone: _phoneController.text.trim()),
        );
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (!context.mounted) return;
      GoRouter.of(context).go('/home');
    } else if (state is AuthError) {
      appLogger.d('[RegisterScreen] auth error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'حصل خطأ أثناء التسجيل، حاول تاني';
      });
    }
  }

  bool _isFieldDone(int index) {
    switch (index) {
      case 0:
        return _nameController.text.isNotEmpty;
      case 1:
        return _phoneController.text.isNotEmpty;
      case 2:
        return _emailController.text.isNotEmpty;
      case 3:
        return _passwordController.text.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;

    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthStateChanged,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ── Decorative header with gradient mesh ─────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topPad + 200,
              child: FadeTransition(
                opacity: _headerFade,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Dark base gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2D0E0E),
                            Color(0xFF1A0A0A),
                          ],
                        ),
                      ),
                    ),
                    // Procedural gradient mesh — primary radial
                    Positioned(
                      top: -30,
                      left: -50,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Procedural gradient mesh — tertiary radial
                    Positioned(
                      top: 20,
                      right: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.tertiary.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Procedural gradient mesh — primary center glow
                    Positioned(
                      top: 60,
                      left: 80,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.06),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom gradient fade to background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.background,
                          ],
                          stops: const [0.55, 1.0],
                        ),
                      ),
                    ),
                    // Decorative accent circle top-right
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Scrollable content ───────────────────────────────────
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: bottomPad + 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: topPad + 16),

                      // ── Back button (44x44 touch target) ──────────
                      FadeTransition(
                        opacity: _headerFade,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Semantics(
                                button: true,
                                label: 'رجوع',
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      appLogger
                                          .d('[RegisterScreen] back pressed');
                                      context.pop();
                                    },
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.lg),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 8, sigmaY: 8),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.18),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    AppRadius.lg),
                                            border: Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Title & subtitle ─────────────────────────
                      FadeTransition(
                        opacity: _headerFade,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'حساب ',
                                      style:
                                          AppTypography.largeTitle.copyWith(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'جديد',
                                      style:
                                          AppTypography.largeTitle.copyWith(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'بياناتك بتظل آمنة معانا',
                                    style:
                                        AppTypography.subheadline.copyWith(
                                      color: Colors.white
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.shield_rounded,
                                    size: 16,
                                    color: AppColors.tertiary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Step indicator with checkmarks ────────────
                      FadeTransition(
                        opacity: _field1Fade,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: AnimatedBuilder(
                            animation: _stepLineController,
                            builder: (context, _) {
                              return _buildStepIndicator();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Form card with top-edge glow ──────────────
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // Top edge gradient glow line
                            Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primary
                                        .withValues(alpha: 0.5),
                                    AppColors.primary,
                                    AppColors.primary
                                        .withValues(alpha: 0.5),
                                    Colors.transparent,
                                  ],
                                  stops: const [
                                    0.0,
                                    0.25,
                                    0.5,
                                    0.75,
                                    1.0
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xxl),
                                border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withValues(alpha: 0.6),
                                ),
                                boxShadow: const [AppShadows.elevated],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // Name field
                                  SlideTransition(
                                    position: _field1Slide,
                                    child: FadeTransition(
                                      opacity: _field1Fade,
                                      child: _RegisterField(
                                        label: 'الاسم الكامل',
                                        hint: 'محمد أحمد',
                                        icon:
                                            Icons.person_outline_rounded,
                                        controller: _nameController,
                                        focusNode: _nameFocusNode,
                                        isFocused: _nameFocused,
                                        textInputAction:
                                            TextInputAction.next,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                                ? 'أدخل اسمك'
                                                : null,
                                        onSubmitted: (_) =>
                                            FocusScope.of(context)
                                                .requestFocus(
                                                    _phoneFocusNode),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Phone field
                                  SlideTransition(
                                    position: _field2Slide,
                                    child: FadeTransition(
                                      opacity: _field2Fade,
                                      child: _RegisterField(
                                        label: 'رقم الهاتف',
                                        hint: '01xxxxxxxxx',
                                        icon: Icons.phone_outlined,
                                        controller: _phoneController,
                                        focusNode: _phoneFocusNode,
                                        isFocused: _phoneFocused,
                                        keyboardType:
                                            TextInputType.phone,
                                        textInputAction:
                                            TextInputAction.next,
                                        onSubmitted: (_) =>
                                            FocusScope.of(context)
                                                .requestFocus(
                                                    _emailFocusNode),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Email field
                                  SlideTransition(
                                    position: _field3Slide,
                                    child: FadeTransition(
                                      opacity: _field3Fade,
                                      child: _RegisterField(
                                        label: 'البريد الإلكتروني',
                                        hint: 'name@example.com',
                                        icon: Icons.email_outlined,
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        isFocused: _emailFocused,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textDirection: TextDirection.ltr,
                                        textInputAction:
                                            TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email
                                        ],
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return 'أدخل البريد الإلكتروني';
                                          }
                                          if (!v.contains('@')) {
                                            return 'بريد إلكتروني غير صحيح';
                                          }
                                          return null;
                                        },
                                        onSubmitted: (_) =>
                                            FocusScope.of(context)
                                                .requestFocus(
                                                    _passwordFocusNode),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Password field
                                  SlideTransition(
                                    position: _field4Slide,
                                    child: FadeTransition(
                                      opacity: _field4Fade,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'كلمة المرور',
                                            style: AppTypography.footnote
                                                .copyWith(
                                              color: _passwordFocused
                                                  ? AppColors.primary
                                                  : AppColors
                                                      .textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.lg),
                                              border: Border.all(
                                                color: _passwordFocused
                                                    ? AppColors.primary
                                                    : AppColors
                                                        .outlineVariant,
                                                width: _passwordFocused
                                                    ? 2.0
                                                    : 1.0,
                                              ),
                                              color: AppColors
                                                  .surfaceContainerLow,
                                              boxShadow: _passwordFocused
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors
                                                            .primary
                                                            .withValues(
                                                                alpha:
                                                                    0.12),
                                                        blurRadius: 12,
                                                        offset:
                                                            const Offset(
                                                                0, 4),
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: TextFormField(
                                              controller:
                                                  _passwordController,
                                              focusNode:
                                                  _passwordFocusNode,
                                              obscureText:
                                                  _obscurePassword,
                                              textDirection:
                                                  TextDirection.ltr,
                                              textInputAction:
                                                  TextInputAction.done,
                                              autofillHints: const [
                                                AutofillHints.newPassword
                                              ],
                                              onFieldSubmitted: (_) =>
                                                  _register(),
                                              decoration: InputDecoration(
                                                hintText:
                                                    '6 أحرف على الأقل',
                                                filled: false,
                                                border: InputBorder.none,
                                                enabledBorder:
                                                    InputBorder.none,
                                                focusedBorder:
                                                    InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal: 16,
                                                  vertical: 14,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons
                                                      .lock_outline_rounded,
                                                  color: _passwordFocused
                                                      ? AppColors.primary
                                                      : AppColors.outline,
                                                  size: 20,
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscurePassword
                                                        ? Icons
                                                            .visibility_off_outlined
                                                        : Icons
                                                            .visibility_outlined,
                                                    color:
                                                        AppColors.outline,
                                                    size: 20,
                                                  ),
                                                  onPressed: () =>
                                                      setState(() =>
                                                          _obscurePassword =
                                                              !_obscurePassword),
                                                ),
                                              ),
                                              validator: (v) {
                                                if (v == null ||
                                                    v.isEmpty) {
                                                  return 'أدخل كلمة المرور';
                                                }
                                                if (v.length < 6) {
                                                  return 'على الأقل 6 أحرف';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),

                                          // Password strength indicator
                                          if (_passwordController
                                              .text.isNotEmpty)
                                            _buildPasswordStrength(),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Error banner
                                  if (_error != null) ...[
                                    const SizedBox(height: 14),
                                    ErrorBanner(message: _error!),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── CTA button ────────────────────────────────
                      FadeTransition(
                        opacity: _ctaFade,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: ScaleTransition(
                            scale: _btnScale,
                            child: GestureDetector(
                              onTapDown: (_) =>
                                  _btnController.reverse(),
                              onTapUp: (_) {
                                _btnController.forward();
                                if (!_isLoading) _register();
                              },
                              onTapCancel: () =>
                                  _btnController.forward(),
                              child: Container(
                                height: 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.xl),
                                  gradient: _isLoading
                                      ? null
                                      : LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            Color.lerp(
                                                AppColors.primary,
                                                Colors.black,
                                                0.15)!,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  color: _isLoading
                                      ? AppColors.primary
                                          .withValues(alpha: 0.6)
                                      : null,
                                  boxShadow: _isLoading
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.4),
                                            blurRadius: 18,
                                            offset:
                                                const Offset(0, 8),
                                          ),
                                        ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'إنشاء الحساب',
                                          style: AppTypography.headline
                                              .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Login link with InkWell ripple ────────────
                      FadeTransition(
                        opacity: _ctaFade,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'عندك حساب بالفعل؟ ',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  appLogger.d(
                                      '[RegisterScreen] go to login');
                                  context.pop();
                                },
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  child: Text(
                                    'سجّل دخول',
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      decoration:
                                          TextDecoration.underline,
                                      decorationColor: AppColors.primary
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step indicator builder ──────────────────────────────────────────
  Widget _buildStepIndicator() {
    const stepLabels = ['الاسم', 'الهاتف', 'البريد', 'المرور'];

    return Row(
      children: List.generate(7, (i) {
        // Even indices (0,2,4,6) = circles, odd indices (1,3,5) = lines
        if (i.isEven) {
          final stepIndex = i ~/ 2;
          final isActive = stepIndex == _activeField;
          final isDone = _isFieldDone(stepIndex) && stepIndex < _activeField;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.primary
                      : isActive
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : Text(
                          '${stepIndex + 1}',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stepLabels[stepIndex],
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: isActive
                      ? AppColors.primary
                      : isDone
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          );
        } else {
          // Connecting line
          final lineIndex = i ~/ 2; // line between step lineIndex and lineIndex+1
          final isLineFilled = _isFieldDone(lineIndex) && lineIndex < _activeField;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Stack(
                children: [
                  // Background line
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      color: AppColors.outlineVariant,
                    ),
                  ),
                  // Animated fill line
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    height: 2,
                    width: isLineFilled ? double.infinity : 0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  // ── Password strength builder ───────────────────────────────────────
  Widget _buildPasswordStrength() {
    const strengthLabels = ['', 'ضعيفة', 'متوسطة', 'قوية', 'قوية جداً'];
    const strengthColors = [
      Colors.transparent,
      Color(0xFFD32F2F), // red
      Color(0xFFF57C00), // orange
      Color(0xFF388E3C), // green
      Color(0xFF1B5E20), // dark green
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4-segment bar
          Row(
            children: List.generate(4, (i) {
              final segmentIndex = i + 1;
              final isFilled = _passwordStrength >= segmentIndex;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i < 3 ? 3 : 0,
                    right: i > 0 ? 0 : 0,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isFilled
                          ? strengthColors[_passwordStrength]
                          : AppColors.outlineVariant,
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_passwordStrength > 0) ...[
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                strengthLabels[_passwordStrength],
                key: ValueKey(_passwordStrength),
                style: AppTypography.caption.copyWith(
                  color: strengthColors[_passwordStrength],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Reusable animated field for register form
class _RegisterField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _RegisterField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    this.keyboardType,
    this.textDirection,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.footnote.copyWith(
            color: isFocused ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isFocused ? AppColors.primary : AppColors.outlineVariant,
              width: isFocused ? 2.0 : 1.0,
            ),
            color: AppColors.surfaceContainerLow,
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textDirection: textDirection,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            onFieldSubmitted: onSubmitted,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: isFocused ? AppColors.primary : AppColors.outline,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
