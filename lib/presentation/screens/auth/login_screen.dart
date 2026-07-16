import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/logger/app_logger.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../widgets/error_banner.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/services/biometric_service.dart';
import '../../../domain/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  bool _biometricsAvailable = false;

  // Staggered entry animations
  late AnimationController _staggerController;
  late Animation<double> _headerFade;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  // Email + password focus animations
  bool _emailFocused = false;
  bool _passwordFocused = false;

  // Button press
  late AnimationController _btnPressController;
  late Animation<double> _btnScale;

  // Shimmer animation for loading button
  late AnimationController _shimmerController;

  // Shake animation for validation error
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Ambient breathing background blobs animation
  late AnimationController _ambientController;
  late Animation<double> _ambientAnimation;

  @override
  void initState() {
    super.initState();
    appLogger.d('[LoginScreen] initState');
    _checkBiometricsAvailability();

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
      ),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _btnPressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      value: 1.0,
    );
    _btnScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _btnPressController, curve: Curves.easeOut),
    );

    // Shimmer controller — repeats while loading
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Shake controller — single shot on validation error
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeOut),
    );

    // Listen to focus changes
    _emailFocusNode.addListener(() {
      setState(() => _emailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _passwordFocused = _passwordFocusNode.hasFocus);
    });

    _staggerController.forward();

    // Ambient background blobs loop
    _ambientController = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat(reverse: true);

    _ambientAnimation = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(
        parent: _ambientController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    appLogger.d('[LoginScreen] dispose');
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _staggerController.dispose();
    _btnPressController.dispose();
    _shimmerController.dispose();
    _shakeController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricsAvailability() async {
    try {
      final service = sl<BiometricService>();
      final isSupported = await service.isHardwareSupported;
      final isEnabled = service.isEnabled;
      final hasEnrolled = await service.hasEnrolledBiometrics;
      if (mounted) {
        setState(() {
          _biometricsAvailable = isSupported && isEnabled && hasEnrolled;
        });
      }
    } catch (e) {
      appLogger.e('[LoginScreen] Error checking biometrics availability', error: e);
    }
  }

  Future<void> _loginWithBiometrics() async {
    final biometricService = sl<BiometricService>();
    final isSupported = await biometricService.isHardwareSupported;
    final hasEnrolled = await biometricService.hasEnrolledBiometrics;
    
    if (!isSupported || !hasEnrolled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الخدمة البيومترية غير متوفرة أو لم يتم تسجيل بصمة على هذا الجهاز'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authenticated = await biometricService.authenticate();
    if (!authenticated) return;

    final credentials = await biometricService.getCredentials();
    if (credentials == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم يتم العثور على بيانات تسجيل دخول محفوظة. يرجى تسجيل الدخول يدويًا أولاً وتفعيل البصمة من الإعدادات.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _shimmerController.repeat();

    context.read<AuthCubit>().signIn(
          email: credentials['email']!,
          password: credentials['password']!,
        );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      appLogger.d('[LoginScreen] _login — form validation failed');
      // Trigger shake animation on the form card
      _shakeController.reset();
      _shakeController.forward();
      return;
    }
    appLogger.d('[LoginScreen] _login — attempting login');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Start shimmer animation
    _shimmerController.repeat();

    context.read<AuthCubit>().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is Authenticated) {
      appLogger.d('[LoginScreen] authenticated');
      if (!mounted) return;
      _shimmerController.stop();
      setState(() => _isLoading = false);

      // Save credentials if biometrics is enabled and we have the password from the controller
      final biometricService = sl<BiometricService>();
      if (biometricService.isEnabled && _passwordController.text.isNotEmpty) {
        final email = sl<AuthRepository>().currentUser?.email;
        if (email != null) {
          biometricService.saveCredentials(
            email,
            _passwordController.text,
          );
        }
      }

      if (state.profile.role.isAdmin) {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    } else if (state is AuthError) {
      appLogger.d('[LoginScreen] auth error');
      if (!mounted) return;
      _shimmerController.stop();
      setState(() {
        _isLoading = false;
        _error = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Derived gradient colors from AppColors.primary
    final primaryDark = Color.lerp(AppColors.primary, Colors.black, 0.15)!;
    final heroGradientDark = Color.lerp(AppColors.primary, Colors.black, 0.75)!;
    const heroGradientNearBlack = Color(0xFF1A0A0A);

    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthStateChanged,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Ambient Blobs behind everything
            AnimatedBuilder(
              animation: _ambientAnimation,
              builder: (context, _) {
                return Stack(
                  children: [
                    _AmbientBlob(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.05 : 0.09,
                      ),
                      size: 300,
                      offset: Offset(size.width * 0.85, size.height * 0.35),
                      scale: _ambientAnimation.value,
                    ),
                    _AmbientBlob(
                      color: AppColors.tertiary.withValues(
                        alpha: isDark ? 0.06 : 0.12,
                      ),
                      size: 320,
                      offset: Offset(size.width * 0.15, size.height * 0.58),
                      scale: 2.0 - _ambientAnimation.value,
                    ),
                  ],
                );
              },
            ),
            // ── Hero image header ──────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.48,
              child: FadeTransition(
                opacity: _headerFade,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Food image — local asset
                    Image.asset(
                      'assets/images/onboarding_food.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [heroGradientDark, heroGradientNearBlack],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            color: Colors.white24,
                            size: 72,
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.35, 0.7, 1.0],
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.transparent,
                            const Color(0xFFFAEBE4).withValues(alpha: 0.2),
                            const Color(0xFFFAEBE4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Scrollable form content ────────────────────────────────
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: bottomPad + 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Spacer to push content below hero image
                      SizedBox(height: size.height * 0.36),

                      // ── Floating logo + greeting ─────────────────────
                      FadeTransition(
                        opacity: _headerFade,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo chip
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.xl),
                                  color: AppColors.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.restaurant_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Greeting row with hand icon instead of emoji
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'أهلاً بعودتك',
                                    style: AppTypography.largeTitle.copyWith(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.onSurface.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.waving_hand_rounded,
                                    size: 24,
                                    color: AppColors.tertiary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'سجّل دخولك وهنجيبلك أحلى أكل',
                                style: AppTypography.subheadline.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Glass form card with shake animation ──────────
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          );
                        },
                        child: SlideTransition(
                          position: _formSlide,
                          child: FadeTransition(
                            opacity: _formFade,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xxl),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.13)
                                          : Colors.white
                                              .withValues(alpha: 0.72),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.xxl),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.22)
                                            : Colors.white
                                                .withValues(alpha: 0.85),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black
                                                  .withValues(alpha: 0.4)
                                              : AppColors.secondary
                                                  .withValues(alpha: 0.08),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8),
                                        ),
                                        if (!isDark)
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.03),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Inner glow — thin gradient line at top
                                        Container(
                                          height: 1,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(
                                                  AppRadius.xxl),
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withValues(
                                                    alpha: isDark ? 0.15 : 0.6),
                                                Colors.white.withValues(
                                                    alpha:
                                                        isDark ? 0.05 : 0.15),
                                                Colors.transparent,
                                              ],
                                              stops: const [0.0, 0.4, 1.0],
                                            ),
                                          ),
                                        ),
                                        // Form content
                                        Padding(
                                          padding: const EdgeInsets.all(22),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // Email field
                                              _PremiumField(
                                                label: 'البريد الإلكتروني',
                                                hint: 'name@example.com',
                                                icon: Icons.email_outlined,
                                                controller: _emailController,
                                                focusNode: _emailFocusNode,
                                                isFocused: _emailFocused,
                                                keyboardType:
                                                    TextInputType.emailAddress,
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
                                                onSubmitted: (_) {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          _passwordFocusNode);
                                                },
                                              ),
                                              const SizedBox(height: 16),

                                              // Password field header
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'كلمة المرور',
                                                    style: AppTypography
                                                        .footnote
                                                        .copyWith(
                                                      color: _passwordFocused
                                                          ? AppColors.primary
                                                          : (isDark
                                                              ? Colors.white70
                                                              : AppColors
                                                                  .textSecondary),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  // Forgot password with 44x44 min touch target
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        appLogger.d(
                                                            '[LoginScreen] forgot password');
                                                        context.push(
                                                            '/forgot-password');
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius.md),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 12,
                                                        ),
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              const BoxConstraints(
                                                            minHeight: 44,
                                                            minWidth: 44,
                                                          ),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'نسيت كلمة المرور؟',
                                                              style:
                                                                  AppTypography
                                                                      .footnote
                                                                      .copyWith(
                                                                color: AppColors
                                                                    .primary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

                                              // Password field
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
                                                        : (isDark
                                                            ? Colors.white
                                                                .withValues(
                                                                    alpha: 0.1)
                                                            : AppColors
                                                                .outlineVariant
                                                                .withValues(
                                                                    alpha:
                                                                        0.4)),
                                                    width: _passwordFocused
                                                        ? 2.0
                                                        : 1.0,
                                                  ),
                                                  color: _passwordFocused
                                                      ? (isDark
                                                          ? Colors.white
                                                              .withValues(
                                                                  alpha: 0.08)
                                                          : Colors.white
                                                              .withValues(
                                                                  alpha: 0.8))
                                                      : (isDark
                                                          ? Colors.white
                                                              .withValues(
                                                                  alpha: 0.04)
                                                          : Colors.white
                                                              .withValues(
                                                                  alpha: 0.6)),
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
                                                  focusNode: _passwordFocusNode,
                                                  obscureText: _obscurePassword,
                                                  textDirection:
                                                      TextDirection.ltr,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  style: TextStyle(
                                                      color: isDark
                                                          ? Colors.white
                                                          : AppColors
                                                              .onSurface),
                                                  autofillHints: const [
                                                    AutofillHints.password
                                                  ],
                                                  onFieldSubmitted: (_) =>
                                                      _login(),
                                                  decoration: InputDecoration(
                                                    hintText: '••••••••',
                                                    hintStyle: TextStyle(
                                                        color: isDark
                                                            ? Colors.white30
                                                            : AppColors.outline
                                                                .withValues(
                                                                    alpha:
                                                                        0.5)),
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
                                                    prefixIcon: AnimatedScale(
                                                      scale: _passwordFocused
                                                          ? 1.08
                                                          : 1.0,
                                                      duration: const Duration(
                                                          milliseconds: 200),
                                                      child: Icon(
                                                        Icons
                                                            .lock_outline_rounded,
                                                        color: _passwordFocused
                                                            ? AppColors.primary
                                                            : (isDark
                                                                ? Colors.white54
                                                                : AppColors
                                                                    .outline),
                                                        size: 20,
                                                      ),
                                                    ),
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        _obscurePassword
                                                            ? Icons
                                                                .visibility_off_outlined
                                                            : Icons
                                                                .visibility_outlined,
                                                        color: isDark
                                                            ? Colors.white54
                                                            : AppColors.outline,
                                                        size: 20,
                                                      ),
                                                      onPressed: () {
                                                        setState(() =>
                                                            _obscurePassword =
                                                                !_obscurePassword);
                                                      },
                                                    ),
                                                  ),
                                                  validator: (v) {
                                                    if (v == null ||
                                                        v.isEmpty) {
                                                      return 'أدخل كلمة المرور';
                                                    }
                                                    if (v.length < 6) {
                                                      return 'كلمة المرور أقل من 6 أحرف';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),

                                              // Animated error banner
                                              AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 250),
                                                switchInCurve: Curves.easeOut,
                                                switchOutCurve: Curves.easeIn,
                                                transitionBuilder:
                                                    (child, animation) {
                                                  return SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin:
                                                          const Offset(0, -0.3),
                                                      end: Offset.zero,
                                                    ).animate(animation),
                                                    child: FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                child: _error != null
                                                    ? Padding(
                                                        key: ValueKey(_error),
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 14),
                                                        child: ErrorBanner(
                                                            message: _error!),
                                                      )
                                                    : const SizedBox.shrink(
                                                        key: ValueKey(
                                                            'no-error'),
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
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── CTA row: Login + Biometric ───────────────────
                      SlideTransition(
                        position: _buttonSlide,
                        child: FadeTransition(
                          opacity: _buttonFade,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                // Primary login button with shimmer
                                Expanded(
                                  child: Semantics(
                                    button: true,
                                    label: 'تسجيل الدخول',
                                    child: ScaleTransition(
                                      scale: _btnScale,
                                      child: GestureDetector(
                                        onTapDown: (_) =>
                                            _btnPressController.reverse(),
                                        onTapUp: (_) {
                                          _btnPressController.forward();
                                          if (!_isLoading) _login();
                                        },
                                        onTapCancel: () =>
                                            _btnPressController.forward(),
                                        child: AnimatedBuilder(
                                          animation: _shimmerController,
                                          builder: (context, child) {
                                            return Container(
                                              height: 56,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.xl),
                                                gradient: _isLoading
                                                    ? _buildShimmerGradient(
                                                        _shimmerController
                                                            .value)
                                                    : LinearGradient(
                                                        colors: [
                                                          AppColors.primary,
                                                          primaryDark,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                boxShadow: _isLoading
                                                    ? null
                                                    : [
                                                        BoxShadow(
                                                          color: AppColors
                                                              .primary
                                                              .withValues(
                                                                  alpha: 0.4),
                                                          blurRadius: 18,
                                                          offset: const Offset(
                                                              0, 8),
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
                                                        'تسجيل الدخول',
                                                        style: AppTypography
                                                            .headline
                                                            .copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_biometricsAvailable) ...[
                                  const SizedBox(width: 12),
                                  // Biometric button
                                  Semantics(
                                    button: true,
                                    label: 'تسجيل الدخول بالبصمة',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _loginWithBiometrics,
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.xl),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.xl),
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.06)
                                                : Colors.white
                                                    .withValues(alpha: 0.7),
                                            border: Border.all(
                                              color: AppColors.primary.withValues(
                                                alpha: 0.2 +
                                                    0.15 *
                                                        (_ambientAnimation.value -
                                                            0.88) /
                                                        0.24,
                                              ),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    AppColors.primary.withValues(
                                                  alpha: 0.05 +
                                                      0.08 *
                                                          (_ambientAnimation
                                                                  .value -
                                                              0.88) /
                                                          0.24,
                                                ),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              )
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.fingerprint_rounded,
                                            color: AppColors.primary,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Register link with proper ripple feedback ─────
                      FadeTransition(
                        opacity: _buttonFade,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'مش عندك حساب؟ ',
                              style: AppTypography.body.copyWith(
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  appLogger.d('[LoginScreen] go to register');
                                  context.push('/register');
                                },
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                splashColor:
                                    AppColors.primary.withValues(alpha: 0.12),
                                highlightColor:
                                    AppColors.primary.withValues(alpha: 0.06),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  child: Text(
                                    'سجّل دلوقتي',
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
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

  /// Builds a shimmer gradient that sweeps across the button surface.
  /// [progress] is 0.0 → 1.0 from the shimmer animation controller.
  LinearGradient _buildShimmerGradient(double progress) {
    final primaryDark = Color.lerp(AppColors.primary, Colors.black, 0.15)!;
    final shimmerHighlight = Color.lerp(AppColors.primary, Colors.white, 0.25)!;

    // The shimmer band sweeps from left-to-right (or right-to-left in RTL)
    // by animating stop positions
    final shimmerCenter = progress;
    final shimmerStart = (shimmerCenter - 0.15).clamp(0.0, 1.0);
    final shimmerEnd = (shimmerCenter + 0.15).clamp(0.0, 1.0);

    return LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        AppColors.primary.withValues(alpha: 0.7),
        shimmerStart < shimmerEnd
            ? shimmerHighlight.withValues(alpha: 0.9)
            : AppColors.primary.withValues(alpha: 0.7),
        primaryDark.withValues(alpha: 0.7),
      ],
      stops: [
        shimmerStart,
        (shimmerStart + shimmerEnd) / 2,
        shimmerEnd,
      ],
    );
  }
}

/// Premium input field with animated focus state
class _PremiumField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _PremiumField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.footnote.copyWith(
            color: isFocused
                ? AppColors.primary
                : (isDark ? Colors.white70 : AppColors.textSecondary),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isFocused
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.outlineVariant.withValues(alpha: 0.4)),
              width: isFocused ? 2.0 : 1.0,
            ),
            color: isFocused
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.8))
                : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.6)),
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
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            onFieldSubmitted: onSubmitted,
            validator: validator,
            style:
                TextStyle(color: isDark ? Colors.white : AppColors.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: isDark
                      ? Colors.white30
                      : AppColors.outline.withValues(alpha: 0.5)),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: AnimatedScale(
                scale: isFocused ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isFocused
                      ? AppColors.primary
                      : (isDark ? Colors.white54 : AppColors.outline),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated breathing ambient glow blob for premium background depth
class _AmbientBlob extends StatelessWidget {
  final Color color;
  final double size;
  final Offset offset;
  final double scale;

  const _AmbientBlob({
    required this.color,
    required this.size,
    required this.offset,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx - (size * scale) / 2,
      top: offset.dy - (size * scale) / 2,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
              sigmaX: 72, sigmaY: 72, tileMode: TileMode.decal),
          child: Container(
            width: size * scale,
            height: size * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
