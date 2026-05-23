import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/logger/app_logger.dart';
import '../../../application/auth/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    appLogger.d('[SplashScreen] initState');
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    appLogger.d('[SplashScreen] _navigate — waiting 2 seconds');
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final onboarded = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      appLogger.d('[SplashScreen] authenticated, checking role');
      if (authState.profile.role.isAdmin) {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    } else {
      if (!onboarded) {
        context.go('/onboarding');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    appLogger.d('[SplashScreen] dispose');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Logo Container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: const [
                        AppShadows.card,
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                  AppSpacing.gapH24,
                  // App Name
                  Text(
                    AppConstants.appName,
                    style: AppTypography.largeTitle.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  AppSpacing.gapH8,
                  // Tagline
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'أطيب الأكلات على بابك',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Progress Indicator
                  Column(
                    children: [
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: const LinearProgressIndicator(
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 3,
                          ),
                        ),
                      ),
                      AppSpacing.gapH12,
                      Text(
                        'جاري التحميل...',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
