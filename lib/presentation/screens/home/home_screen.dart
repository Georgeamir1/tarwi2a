import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/di/injection_container.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/menu/categories_cubit.dart';
import '../../../application/menu/products_cubit.dart';
import '../../../application/cart/cart_cubit.dart';
import '../../../application/notifications/notifications_cubit.dart';
import '../../../domain/entities/product.dart';
import '../../widgets/product_image.dart';
import '../../widgets/cart_add_button.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/product_compact_tile.dart';
import '../../widgets/tag_selector.dart';
import '../../extensions/price_x.dart';
import '../../../app/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CategoriesCubit>()..loadCategories()),
        BlocProvider(create: (_) => sl<ProductsCubit>()..loadProducts()),
      ],
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final cats = context.read<CategoriesCubit>();
    final prods = context.read<ProductsCubit>();
    final cart = context.read<CartCubit>();
    await Future.wait([
      cats.loadCategories(),
      prods.loadProducts(),
      cart.loadCart(),
    ]);
  }

  Animation<double> _stagger(double start, double end) {
    return CurvedAnimation(
      parent: _staggerCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _stagger(0.0, 0.5),
                  child: const _HomeTopBar(),
                ),
              ),
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _stagger(0.1, 0.55),
                  child: const _HomeSearchBar(),
                ),
              ),
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _stagger(0.2, 0.65),
                  child: const _HomeHeroCarousel(),
                ),
              ),
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _stagger(0.3, 0.75),
                  child: const _HomePopularSection(),
                ),
              ),
              _HomeCategoryPreviews(stagger: _stagger(0.4, 1.0)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _FadeSlide({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final v = animation.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 24),
            child: child,
          ),
        );
      },
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final name = authState is Authenticated
                    ? authState.profile.name.split(' ').first
                    : '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          name.isNotEmpty
                              ? '\u0623\u0647\u0644\u0627\u064b $name'
                              : '\u0623\u0647\u0644\u0627\u064b \u0628\u0643',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.waving_hand_rounded,
                          color: AppColors.tertiary,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '\u0645\u0627\u0630\u0627 \u062a\u0634\u062a\u0647\u064a \u0627\u0644\u064a\u0648\u0645\u061f',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            buildWhen: (prev, curr) => prev.unreadCount != curr.unreadCount,
            builder: (context, notifState) {
              return NotificationBadge(
                icon: Icons.notifications_none_rounded,
                count: notifState.unreadCount,
                color: AppColors.textPrimary,
                iconSize: 22,
                tooltip: 'الإشعارات',
                onTap: () => context.push('/profile/notifications'),
              );
            },
          ),
          const SizedBox(width: 12),
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final count = cartState.totalItems;
              return GestureDetector(
                onTap: () {
                  appLogger.d('[HomeScreen] cart tapped');
                  context.push('/cart');
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary
                            .withValues(alpha: count > 0 ? 0.15 : 0.0),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 22,
                        color: AppColors.textPrimary,
                      ),
                      if (count > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeSearchBar extends StatefulWidget {
  const _HomeSearchBar();

  @override
  State<_HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<_HomeSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onSearchSubmit(String query) {
    _focusNode.unfocus();
    if (query.trim().isNotEmpty) {
      context.go('/menu?search=${Uri.encodeComponent(query.trim())}');
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: _isFocused ? AppColors.surface : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: _isFocused ? AppColors.primary : AppColors.outlineVariant,
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            const SizedBox(width: 18),
            AnimatedScale(
              scale: _isFocused ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.search_rounded,
                color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                textDirection: TextDirection.rtl,
                style: AppTypography.body.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                cursorColor: AppColors.primary,
                onSubmitted: _onSearchSubmit,
                decoration: const InputDecoration(
                  hintText:
                      '\u0627\u0628\u062d\u062b \u0639\u0646 \u0637\u0628\u0642\u2026',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.tune_rounded,
                size: 20,
                color: _isFocused ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _HomeHeroCarousel extends StatefulWidget {
  const _HomeHeroCarousel();

  @override
  State<_HomeHeroCarousel> createState() => _HomeHeroCarouselState();
}

class _HomeHeroCarouselState extends State<_HomeHeroCarousel> {
  int _current = 0;
  Timer? _timer;
  bool _userInteracting = false;
  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.92);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _userInteracting) return;
      final products = context.read<ProductsCubit>().state.allProducts;
      final heroes = products.where((p) => p.showInBanner).toList();
      if (heroes.length < 2) return;
      final next = (_current + 1) % heroes.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _onUserInteractionStart() {
    _userInteracting = true;
  }

  void _onUserInteractionEnd() {
    _userInteracting = false;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, prodState) {
        if (prodState.status == ProductsStatus.loading) {
          return const _HeroSkeleton();
        }

        final heroes =
            prodState.allProducts.where((p) => p.showInBanner).toList();
        if (heroes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            SizedBox(
              height: 220,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _onUserInteractionStart();
                  } else if (notification is ScrollEndNotification) {
                    _onUserInteractionEnd();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: heroes.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (context, index) {
                    final hero = heroes[index];
                    return _HeroCard(
                      product: hero,
                      isActive: index == _current,
                      onTap: () {
                        appLogger.d('[HomeScreen] hero tapped: ${hero.nameAr}');
                        context.push('/product/${hero.id}', extra: hero);
                      },
                    );
                  },
                ),
              ),
            ),
            if (heroes.length > 1) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  heroes.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    width: i == _current ? 28 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _current
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: i == _current
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HeroCard extends StatefulWidget {
  final Product product;
  final bool isActive;
  final VoidCallback onTap;

  const _HeroCard({
    required this.product,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.symmetric(horizontal: widget.isActive ? 0 : 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                if (widget.isActive)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 220,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(
                      imageUrl: widget.product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          Container(color: AppColors.surfaceContainerLow),
                      errorWidget: Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: AppColors.textSecondary,
                          size: 48,
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.2, 0.55, 1.0],
                          colors: [
                            Colors.transparent,
                            Color(0x40000000),
                            Color(0xDD000000),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department_rounded,
                                size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '\u0639\u0631\u0636 \u0627\u0644\u064a\u0648\u0645',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.product.nameAr,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Color(0x40000000),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    textDirection: TextDirection.rtl,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          widget.product.price.formatted,
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (widget.product.descriptionAr !=
                                          null) ...[
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            widget.product.descriptionAr!,
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 12,
                                              color: Colors.white
                                                  .withValues(alpha: 0.85),
                                              height: 1.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.5),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '\u0627\u0637\u0644\u0628 \u0627\u0644\u0622\u0646',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

class _HomePopularSection extends StatelessWidget {
  const _HomePopularSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, prodState) {
        if (prodState.status == ProductsStatus.loading ||
            prodState.allProducts.length < 2) {
          return const SizedBox.shrink();
        }

        final popular = prodState.allProducts.skip(1).take(5).toList();
        if (popular.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  const Text(
                    '\u0627\u0644\u0623\u0643\u062b\u0631 \u0637\u0644\u0628\u0627\u064b',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.local_fire_department_rounded,
                      size: 20, color: AppColors.primary),
                  const Spacer(),
                  Text(
                    '\u0639\u0631\u0636 \u0627\u0644\u0643\u0644',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 235,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: popular.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final product = popular[index];
                  return _PopularCard(
                    product: product,
                    onTap: () {
                      appLogger
                          .d('[HomeScreen] popular tapped: ${product.nameAr}');
                      context.push('/product/${product.id}', extra: product);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PopularCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const _PopularCard({required this.product, required this.onTap});

  @override
  State<_PopularCard> createState() => _PopularCardState();
}

class _PopularCardState extends State<_PopularCard> {
  bool _pressed = false;

  Widget _buildTagBadge(Product p) {
    final String tagId = p.tags.isNotEmpty
        ? p.tags.first
        : p.id.hashCode % 3 == 0
            ? 'chef_pick'
            : p.id.hashCode % 3 == 1
                ? 'spicy'
                : 'popular';

    final tag = ProductTags.all.firstWhere(
      (t) => t.id == tagId,
      orElse: () => ProductTag(
        id: tagId,
        label: tagId,
        icon: Icons.label_rounded,
        color: AppColors.primary,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tag.color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tag.icon, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            tag.label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: 158,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 58,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: ProductImage(
                            imageUrl: p.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: Container(
                              color: AppColors.surfaceContainerLow,
                            ),
                            errorWidget: Container(
                              color: AppColors.surfaceContainerLow,
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: AppColors.textSecondary,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _buildTagBadge(p),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 42,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p.nameAr,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                          ),
                          Row(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                p.price.formatted,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              CartAddButton(
                                product: p,
                                iconSize: 16,
                                buttonSize: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class _HomeCategoryPreviews extends StatelessWidget {
  final Animation<double> stagger;

  const _HomeCategoryPreviews({required this.stagger});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, catState) {
        if (catState.status != CategoriesStatus.loaded) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, prodState) {
            if (prodState.status != ProductsStatus.loaded) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            final activeCategories = catState.categories
                .where((c) => c.isActive)
                .toList()
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            // Select 2-3 categories max
            final previewCategories = activeCategories.take(3).toList();

            if (previewCategories.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, catIndex) {
                  final category = previewCategories[catIndex];
                  final catProducts = prodState.allProducts
                      .where((p) => p.categoryId == category.id)
                      .take(5) // max 4-6 items
                      .toList();

                  if (catProducts.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Category Header (Name + "View All")
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                category.nameAr,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  context.go('/menu?category=${category.id}');
                                },
                                child: const Text(
                                  '\u0639\u0631\u0636 \u0627\u0644\u0643\u0644', // عرض الكل
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // List of items in this category
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          itemCount: catProducts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final product = catProducts[index];
                            return AnimatedBuilder(
                              animation: stagger,
                              builder: (context, _) {
                                final delay = (index * 0.04).clamp(0.0, 0.5);
                                final itemAnim = Interval(
                                  delay,
                                  (delay + 0.4).clamp(0.0, 1.0),
                                  curve: Curves.easeOutCubic,
                                ).transform(stagger.value);
                                return Opacity(
                                  opacity: itemAnim.clamp(0.0, 1.0),
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - itemAnim) * 16),
                                    child: ProductCompactTile(
                                      product: product,
                                      onTap: () {
                                        context.push('/product/${product.id}',
                                            extra: product);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
                childCount: previewCategories.length,
              ),
            );
          },
        );
      },
    );
  }
}
