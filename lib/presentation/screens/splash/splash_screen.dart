import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/logger/app_logger.dart';
import '../../../application/auth/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Master timeline controller
  late AnimationController _masterController;

  // Glow ring pulse (looping)
  late AnimationController _glowController;

  // Rotating decorative arc
  late AnimationController _arcController;

  // Animated gradient background shift
  late AnimationController _gradientController;

  // Circular progress ring
  late AnimationController _progressController;

  // Particle shimmer
  late AnimationController _particleController;

  // Background gradient
  late Animation<double> _bgFade;

  // Gradient color shift
  late Animation<Color?> _gradientCenterColor;

  // Glow ring scale + opacity
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;

  // Logo entrance: scale + fade
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  // Tagline: fade + slide
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;

  // Progress ring sweep
  late Animation<double> _progressSweep;
  late Animation<double> _progressFade;

  // Exit fade
  late Animation<double> _exitFade;

  // Arc rotation
  late Animation<double> _arcRotation;

  // Particles
  late List<_ParticleData> _particles;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    appLogger.d('[SplashScreen] initState');

    _masterController = AnimationController(
      duration: const Duration(milliseconds: 3200),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _arcController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _gradientController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );

    _initParticles();
    _setupAnimations();

    _masterController.forward();
    _glowController.repeat(reverse: true);
    _arcController.repeat();
    _gradientController.repeat(reverse: true);
    _progressController.repeat();
    _particleController.repeat();
    _navigate();
  }

  void _initParticles() {
    _particles = List.generate(14, (_) {
      return _ParticleData(
        x: _rng.nextDouble(),
        startY: 0.85 + _rng.nextDouble() * 0.15,
        size: 2.0 + _rng.nextDouble() * 2.0,
        speed: 0.6 + _rng.nextDouble() * 0.4,
        phase: _rng.nextDouble(),
      );
    });
  }

  void _setupAnimations() {
    // Background fade-in
    _bgFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    // Gradient center color shift — deep cherry tones
    _gradientCenterColor = ColorTween(
      begin: const Color(0xFF3D1010),
      end: const Color(0xFF4A1515),
    ).animate(
      CurvedAnimation(
        parent: _gradientController,
        curve: Curves.easeInOut,
      ),
    );

    // Glow ring — pulses via _glowController
    _glowScale = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowOpacity = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Logo — spring physics with elasticOut
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.18, 0.58, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.18, 0.40, curve: Curves.easeOut),
      ),
    );

    // Tagline
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.48, 0.68, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.48, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    // Circular progress ring
    _progressSweep = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.linear,
      ),
    );
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.55, 0.70, curve: Curves.easeOut),
      ),
    );

    // Exit screen — faster interval 0.88-1.0
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.88, 1.0, curve: Curves.easeIn),
      ),
    );

    // Arc rotation
    _arcRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _arcController, curve: Curves.linear),
    );
  }

  Future<void> _navigate() async {
    appLogger.d('[SplashScreen] _navigate — starting parallel auth check');

    // Start minimum display timer and auth check in parallel
    final minDisplayFuture = Future.delayed(const Duration(milliseconds: 3200));

    // Start auth check immediately — read state once it's resolved
    final prefsFuture = SharedPreferences.getInstance();

    // Wait for BOTH minimum timer AND prefs to be ready
    final results = await Future.wait([minDisplayFuture, prefsFuture]);
    if (!mounted) return;

    final prefs = results[1] as SharedPreferences;
    final onboarded = prefs.getBool('onboarding_complete') ?? false;

    // Wait for auth state to be resolved (not initial/loading)
    final authState = await _waitForAuthResolved();
    if (!mounted) return;

    appLogger.d('[SplashScreen] auth resolved: ${authState.runtimeType}');

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

  /// Waits until AuthCubit emits a non-initial, non-loading state,
  /// or returns current state if already resolved.
  Future<AuthState> _waitForAuthResolved() async {
    final cubit = context.read<AuthCubit>();
    final currentState = cubit.state;

    // If already resolved, return immediately
    if (currentState is! AuthInitial && currentState is! AuthLoading) {
      return currentState;
    }

    // Otherwise listen for the first resolved state
    await for (final state in cubit.stream) {
      if (state is! AuthInitial && state is! AuthLoading) {
        return state;
      }
    }

    // Fallback — should not reach here
    return const AuthState.unauthenticated();
  }

  @override
  void dispose() {
    appLogger.d('[SplashScreen] dispose');
    _masterController.dispose();
    _glowController.dispose();
    _arcController.dispose();
    _gradientController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _masterController,
          _glowController,
          _arcController,
          _gradientController,
          _progressController,
          _particleController,
        ]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _exitFade,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Layer 1: Animated gradient background ──────────────
                FadeTransition(
                  opacity: _bgFade,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.2),
                        radius: 1.5,
                        colors: [
                          _gradientCenterColor.value ?? const Color(0xFF3D1010),
                          AppColors.darkBackground.withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Layer 2: Warm vignette overlay ─────────────────────
                FadeTransition(
                  opacity: _bgFade,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.9,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Layer 3: Floating particles ────────────────────────
                FadeTransition(
                  opacity: _bgFade,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _ParticlePainter(
                      particles: _particles,
                      progress: _particleController.value,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                // ── Layer 4: Rotating decorative arc ───────────────────
                Center(
                  child: Opacity(
                    opacity: _bgFade.value * 0.18,
                    child: Transform.rotate(
                      angle: _arcRotation.value,
                      child: CustomPaint(
                        size: const Size(340, 340),
                        painter: _ArcPainter(),
                      ),
                    ),
                  ),
                ),

                // ── Layer 5: Glowing halo ring ─────────────────────────
                Center(
                  child: Transform.scale(
                    scale: _glowScale.value,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: _glowOpacity.value * _bgFade.value,
                            ),
                            blurRadius: 80,
                            spreadRadius: 24,
                          ),
                          BoxShadow(
                            color: AppColors.tertiary.withValues(
                              alpha: _glowOpacity.value * 0.4 * _bgFade.value,
                            ),
                            blurRadius: 120,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Layer 6: Circular progress ring ────────────────────
                Center(
                  child: Opacity(
                    opacity: _progressFade.value,
                    child: CustomPaint(
                      size: const Size(200, 200),
                      painter: _ProgressRingPainter(
                        sweep: _progressSweep.value,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),

                // ── Layer 7: Logo ──────────────────────────────────────
                Center(
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoFade.value,
                      child: Semantics(
                        label: 'شعار ترويقه',
                        child: Image.asset(
                          'assets/images/splash_logo-removebg-preview.png',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.6),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Layer 8: Tagline ───────────────────────────────────
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineFade,
                      child: Text(
                        'أكلات أصيلة، طعم لا يُنسى',
                        textAlign: TextAlign.center,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.darkTextSecondary.withValues(alpha: 0.85),
                          letterSpacing: 0.5,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Data for a single floating particle
class _ParticleData {
  final double x;
  final double startY;
  final double size;
  final double speed;
  final double phase;

  const _ParticleData({
    required this.x,
    required this.startY,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

/// Paints floating shimmer particles that drift upward with fade in/out
class _ParticlePainter extends CustomPainter {
  final List<_ParticleData> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Each particle loops on its own phase-shifted cycle
      final t = (progress + particle.phase) % 1.0;

      // Y position: drifts upward from startY toward top
      final travelDistance = 0.6 * particle.speed;
      final y = particle.startY - t * travelDistance;

      // Skip if particle drifted off-screen
      if (y < -0.05) continue;

      // Fade: ramp in for first 20%, hold, ramp out for last 20%
      double alpha;
      if (t < 0.2) {
        alpha = t / 0.2;
      } else if (t > 0.8) {
        alpha = (1.0 - t) / 0.2;
      } else {
        alpha = 1.0;
      }
      alpha = (alpha * 0.7).clamp(0.0, 1.0);

      final dx = particle.x * size.width;
      final dy = y * size.height;

      // Glow circle
      final glowPaint = Paint()
        ..color = color.withValues(alpha: alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dx, dy), particle.size * 2.5, glowPaint);

      // Core circle
      final corePaint = Paint()
        ..color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(dx, dy), particle.size, corePaint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Circular progress ring that sweeps from 0 to 360 degrees
class _ProgressRingPainter extends CustomPainter {
  final double sweep;
  final Color color;

  _ProgressRingPainter({
    required this.sweep,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Track ring — very subtle
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, trackPaint);

    // Active sweep arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Start from top (-pi/2), sweep the animated amount
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.sweep != sweep;
}

/// Rotating arc painter for decorative background element.
/// Uses separate Paint objects for outer and inner arcs to avoid mutation.
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer arc paint — separate instance
    final outerPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 1.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Outer arc — dashed feel via multiple short arcs
    for (int i = 0; i < 12; i++) {
      final startAngle = (i * 2 * math.pi / 12);
      const sweepAngle = math.pi / 18;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        outerPaint,
      );
    }

    // Inner arc paint — separate instance
    final innerPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 1.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Inner arc
    for (int i = 0; i < 8; i++) {
      final startAngle = (i * 2 * math.pi / 8) + math.pi / 8;
      const sweepAngle = math.pi / 24;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.72),
        startAngle,
        sweepAngle,
        false,
        innerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}