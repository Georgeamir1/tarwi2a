import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/logger/app_logger.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  double _pageValue = 0.0;
  bool _hasEverSwiped = false;

  // ── Content transition animations ──────────────────────────────────
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  // ── CTA button press scale ─────────────────────────────────────────
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  // ── Swipe hint chevron (first page only) ───────────────────────────
  late AnimationController _swipeHintController;
  late Animation<double> _swipeHintOffset;
  late Animation<double> _swipeHintOpacity;

  // ── CTA glow pulse (last page only) ────────────────────────────────
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final _pages = const [
    _OnboardingData(
      imageAsset: 'assets/images/onboarding_food.png',
      icon: Icons.restaurant_rounded,
      tag: 'أكل طازج يومياً',
      title: 'أكلات أصيلة',
      titleHighlight: 'ولا أروع',
      description:
          'استمتع بأغنى نكهات المطبخ الشرقي من مطاعم مختارة بعناية، بتوصل لبيتك وهي ساخنة',
      gradientColors: [Color(0xFF1A0A0A), Color(0xCC2D0E0E), Color(0x44000000)],
    ),
    _OnboardingData(
      imageAsset: 'assets/images/onboarding_delivery.png',
      icon: Icons.delivery_dining_rounded,
      tag: 'توصيل في 30 دقيقة',
      title: 'سريع',
      titleHighlight: 'زي البرق',
      description:
          'طلبك بيوصل لباب بيتك في أسرع وقت ممكن مع تتبع لحظي لحالة طلبك خطوة بخطوة',
      gradientColors: [Color(0xFF0A1A0E), Color(0xCC0E2D16), Color(0x44000000)],
    ),
    _OnboardingData(
      imageAsset: 'assets/images/onboarding_payment.png',
      icon: Icons.account_balance_wallet_rounded,
      tag: 'دفع آمن ومريح',
      title: 'ادفع',
      titleHighlight: 'بطريقتك',
      description:
          'اختار طريقة الدفع اللي بتريح قلبك، كاش أو بطاقة أو محفظة إلكترونية، كل ده بضغطة واحدة',
      gradientColors: [Color(0xFF0A0E1A), Color(0xCC0E162D), Color(0x44000000)],
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Track page scroll position for parallax
    _pageController.addListener(_onPageScroll);

    // ── Content fade + slide ──────────────────────────────────────────
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    // ── Button press scale ────────────────────────────────────────────
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      value: 1.0,
    );
    _buttonScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    // ── Swipe hint pulsing chevron ────────────────────────────────────
    _swipeHintController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _swipeHintOffset = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _swipeHintController,
        curve: Curves.easeInOut,
      ),
    );

    _swipeHintOpacity = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _swipeHintController,
        curve: Curves.easeInOut,
      ),
    );

    _swipeHintController.repeat(reverse: true);

    // ── CTA glow pulse ────────────────────────────────────────────────
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _contentController.forward();
  }

  void _onPageScroll() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page ?? 0.0;
    setState(() => _pageValue = page);
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    appLogger.d('[Onboarding] marked complete');
  }

  void _animateContentTransition(VoidCallback afterAnimation) {
    _contentController.reverse().then((_) {
      if (!mounted) return;
      afterAnimation();
      _contentController.forward();
    });
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _animateContentTransition(() {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      });
    } else {
      _completeOnboarding();
      context.go('/login');
    }
  }

  void _onSkip() {
    _completeOnboarding();
    context.go('/login');
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    _swipeHintController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _pages.length - 1;
    final isFirstPage = _currentPage == 0;
    final page = _pages[_currentPage];

    // Manage glow animation based on page
    if (isLastPage && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!isLastPage && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.value = 0.25;
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-bleed PageView with parallax ────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) {
              if (!_hasEverSwiped && i != 0) {
                setState(() => _hasEverSwiped = true);
              }
              setState(() => _currentPage = i);
            },
            itemBuilder: (_, index) => _OnboardingSlide(
              page: _pages[index],
              parallaxOffset: (_pageValue - index) * size.width * 0.3,
            ),
          ),

          // ── Top bar: Logo + Skip ─────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // App logo mark
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    // Skip button — min 44×44 touch target
                    Semantics(
                      label: 'تخطي المقدمة',
                      button: true,
                      child: GestureDetector(
                        onTap: _onSkip,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                widthFactor: 1,
                                child: Text(
                                  'تخطي',
                                  style: AppTypography.footnote.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
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
          ),

          // ── Tag badge (center) ────────────────────────────────────────
          Positioned(
            top: size.height * 0.38,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _contentController,
              builder: (_, child) => FadeTransition(
                opacity: _contentFade,
                child: child,
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            page.icon,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            page.tag,
                            style: AppTypography.footnote.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
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

          // ── Swipe hint chevron (first page only) ──────────────────────
          if (isFirstPage && !_hasEverSwiped)
            Positioned(
              bottom: size.height * 0.42,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _swipeHintController,
                builder: (_, __) => Opacity(
                  opacity: _swipeHintOpacity.value,
                  child: Transform.translate(
                    // RTL: animate to the left (negative) to hint swipe direction
                    offset: Offset(-_swipeHintOffset.value, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 32,
                        ),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white.withValues(alpha: 0.35),
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Bottom glassmorphism card ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 28,
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.62),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.5,
                      ),
                    ),
                    // Subtle top gradient border effect
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                      stops: const [0.0, 0.12],
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _contentController,
                    builder: (_, child) => FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: child,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Animated dot indicators ──────────────────
                        Row(
                          children: List.generate(
                            _pages.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(right: 6),
                              width: _currentPage == i ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == i
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.3),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ── Title ────────────────────────────────────
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${page.title} ',
                                style: AppTypography.largeTitle.copyWith(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                              TextSpan(
                                text: page.titleHighlight,
                                style: AppTypography.largeTitle.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Description ──────────────────────────────
                        Text(
                          page.description,
                          style: AppTypography.subheadline.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── CTA Button (with glow on last page) ─────
                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (_, child) => ScaleTransition(
                            scale: _buttonScale,
                            child: Semantics(
                              label: isLastPage ? 'ابدأ الآن' : 'الصفحة التالية',
                              button: true,
                              child: GestureDetector(
                                onTapDown: (_) =>
                                    _buttonController.reverse(),
                                onTapUp: (_) {
                                  _buttonController.forward();
                                  _onNext();
                                },
                                onTapCancel: () =>
                                    _buttonController.forward(),
                                child: Container(
                                  height: 58,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.xl),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        HSLColor.fromColor(AppColors.primary)
                                            .withLightness(
                                              (HSLColor.fromColor(
                                                            AppColors.primary)
                                                        .lightness -
                                                    0.08)
                                                .clamp(0.0, 1.0),
                                            )
                                            .toColor(),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: isLastPage
                                              ? _glowAnimation.value
                                              : 0.45,
                                        ),
                                        blurRadius: isLastPage ? 28 : 20,
                                        spreadRadius: isLastPage ? 2 : 0,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isLastPage ? 'يلا نبدأ!' : 'التالي',
                                          style:
                                              AppTypography.headline.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 17,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isLastPage
                                              ? Icons.celebration_rounded
                                              : Icons.arrow_back_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed slide with local asset image + parallax + rich gradient
class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData page;
  final double parallaxOffset;

  const _OnboardingSlide({
    required this.page,
    required this.parallaxOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image with parallax
        Transform.translate(
          offset: Offset(parallaxOffset, 0),
          child: Image.asset(
            page.imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: page.gradientColors,
                  center: Alignment.center,
                  radius: 1.2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white24,
                  size: 80,
                ),
              ),
            ),
          ),
        ),

        // Multi-stop gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.85),
              ],
              stops: const [0.0, 0.3, 0.55, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingData {
  final String imageAsset;
  final IconData icon;
  final String tag;
  final String title;
  final String titleHighlight;
  final String description;
  final List<Color> gradientColors;

  const _OnboardingData({
    required this.imageAsset,
    required this.icon,
    required this.tag,
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.gradientColors,
  });
}
