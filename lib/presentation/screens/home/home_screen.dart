import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/di/injection_container.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/menu/categories_cubit.dart';
import '../../../application/menu/products_cubit.dart';
import '../../../application/cart/cart_cubit.dart';
import '../../../domain/entities/product.dart';
import '../../widgets/product_image.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/animated_cart_button.dart';
import '../../widgets/cart_add_button.dart';
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
      duration: const Duration(milliseconds: 350),
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
                  animation: _stagger(0.15, 0.65),
                  child: const _HomeSearchBar(),
                ),
              ),
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _stagger(0.25, 0.75),
                  child: const _HomeCategoriesChips(),
                ),
              ),
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _stagger(0.3, 0.8),
                  child: const _HomeHeroCarousel(),
                ),
              ),
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _stagger(0.4, 0.9),
                  child: const _HomePopularSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _stagger(0.45, 1.0),
                  child: const _HomeMenuHeader(),
                ),
              ),
              _HomeProductList(stagger: _stagger(0.5, 1.0)),
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
            offset: Offset(0, (1 - v) * 20),
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
                            fontSize: 22,
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
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '\u0645\u0627\u0630\u0627 \u062a\u0634\u062a\u0647\u064a \u0627\u0644\u064a\u0648\u0645\u061f',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
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
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final count = cartState.totalItems;
              return GestureDetector(
                onTap: () {
                  appLogger.d('[HomeScreen] cart tapped');
                  context.push('/cart');
                },
                child: Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          appLogger.d('[HomeScreen] cart tapped');
                          context.push('/cart');
                        },
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        top: 0,
                        right: 0,
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
                              color: AppColors.background,
                              width: 2,
                            ),
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

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
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
        height: 48,
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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search,
              color: _isFocused ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                textDirection: TextDirection.rtl,
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                cursorColor: AppColors.primary,
                decoration: const InputDecoration(
                  hintText:
                      '\u0627\u0628\u062d\u062b \u0639\u0646 \u0637\u0628\u0642\u2026',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
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
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _HomeCategoriesChips extends StatelessWidget {
  const _HomeCategoriesChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, catState) {
        if (catState.status != CategoriesStatus.loaded) {
          return const SizedBox(height: 48);
        }
        return BlocBuilder<ProductsCubit, ProductsState>(
          buildWhen: (prev, next) =>
              prev.selectedCategoryId != next.selectedCategoryId ||
              prev.allProducts != next.allProducts,
          builder: (context, prodState) {
            final activeCategoryIds =
                prodState.allProducts.map((p) => p.categoryId).toSet();

            final filterCategories = catState.categories
                .where((c) => c.isActive && activeCategoryIds.contains(c.id))
                .toList()
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            if (filterCategories.isEmpty && prodState.allProducts.isEmpty) {
              return const SizedBox.shrink();
            }

            final allChips = [
              const _ChipOption(
                  label: '\u0627\u0644\u0643\u0644', categoryId: null),
              ...filterCategories.map(
                (c) => _ChipOption(label: c.nameAr, categoryId: c.id),
              ),
            ];

            return SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: allChips.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final option = allChips[index];
                  final isSelected =
                      prodState.selectedCategoryId == option.categoryId;
                  return _CategoryChip(
                    label: option.label,
                    isSelected: isSelected,
                    onTap: () {
                      appLogger.d(
                        '[HomeScreen] category: ${option.categoryId ?? "all"}',
                      );
                      context.read<ProductsCubit>().selectCategory(
                            isSelected ? null : option.categoryId,
                          );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    return Semantics(
      button: true,
      selected: isSelected,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipOption {
  final String label;
  final String? categoryId;
  const _ChipOption({required this.label, this.categoryId});
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
    _pageCtrl = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _userInteracting) return;
      final products = context.read<ProductsCubit>().state.products;
      final heroes = products.where((p) => p.showInBanner).toList();
      if (heroes.length < 2) return;
      final next = (_current + 1) % heroes.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
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

        final heroes = prodState.products.where((p) => p.showInBanner).toList();
        if (heroes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            0,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 180,
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
                        onTap: () {
                          appLogger
                              .d('[HomeScreen] hero tapped: ${hero.nameAr}');
                          context.push('/product/${hero.id}', extra: hero);
                        },
                      );
                    },
                  ),
                ),
              ),
              if (heroes.length > 1) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    heroes.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      width: i == _current ? 24 : 6,
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
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _HeroCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [AppShadows.elevated],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(
                    imageUrl: product.imageUrl,
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
                        stops: [0.35, 1.0],
                        colors: [Colors.transparent, Color(0xE6000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              size: 13, color: Colors.white),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                  product.nameAr,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                ),
                                if (product.descriptionAr != null) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    product.descriptionAr!,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color:
                                          Colors.white.withValues(alpha: 0.75),
                                      height: 1.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${product.price.toStringAsFixed(0)} \u062c.\u0645',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  '\u0627\u0637\u0644\u0628 \u0627\u0644\u0622\u0646',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
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
            prodState.products.length < 2) {
          return const SizedBox.shrink();
        }

        final popular = prodState.products.skip(1).take(5).toList();
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.local_fire_department_rounded,
                      size: 18, color: AppColors.primary),
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
              height: 220,
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

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final tagText = p.id.hashCode % 3 == 0
        ? '\u0645\u0645\u064a\u0632'
        : p.id.hashCode % 3 == 1
            ? '\u062d\u0627\u0631'
            : '\u0637\u0627\u0632\u062c';
    final tagBg = p.id.hashCode % 3 == 0
        ? AppColors.tertiaryContainer
        : p.id.hashCode % 3 == 1
            ? AppColors.primaryContainer
            : AppColors.infoContainer;
    final tagFg = p.id.hashCode % 3 == 0
        ? AppColors.onTertiaryContainer
        : p.id.hashCode % 3 == 1
            ? AppColors.onPrimaryContainer
            : AppColors.infoOnContainer;

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
          width: 152,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
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
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            tagText,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: tagFg,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 42,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          p.nameAr,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                '${p.price.toStringAsFixed(0)} \u062c',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
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
      ),
    );
  }
}

class _HomeMenuHeader extends StatelessWidget {
  const _HomeMenuHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Text(
            '\u0642\u0627\u0626\u0645\u0629 \u0627\u0644\u0637\u0639\u0627\u0645',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
    );
  }
}

class _HomeProductList extends StatelessWidget {
  final Animation<double> stagger;

  const _HomeProductList({required this.stagger});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.status == ProductsStatus.loading ||
            state.status == ProductsStatus.initial) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList.separated(
              itemCount: 4,
              itemBuilder: (context, index) => const SkeletonListTile(),
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
            ),
          );
        }

        if (state.status == ProductsStatus.error) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  AppSpacing.gapH16,
                  const Text(
                    '\u062d\u0635\u0644 \u062e\u0637\u0623 \u0641\u064a \u0627\u0644\u062a\u062d\u0645\u064a\u0644',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  AppSpacing.gapH12,
                  TextButton(
                    onPressed: () {
                      context.read<ProductsCubit>().loadProducts();
                    },
                    child: const Text(
                      '\u062d\u0627\u0648\u0644 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final products = state.products;

        if (products.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xxxl,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.restaurant_menu_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  AppSpacing.gapH16,
                  Text(
                    state.selectedCategoryId != null
                        ? '\u0644\u0627 \u062a\u0648\u062c\u062f \u0623\u0635\u0646\u0627\u0641 \u0641\u064a \u0647\u0630\u0627 \u0627\u0644\u0642\u0633\u0645'
                        : '\u0644\u0627 \u062a\u0648\u062c\u062f \u0623\u0635\u0646\u0627\u0641 \u062d\u0627\u0644\u064a\u0627\u064b',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  if (state.selectedCategoryId != null) ...[
                    AppSpacing.gapH12,
                    TextButton(
                      onPressed: () =>
                          context.read<ProductsCubit>().selectCategory(null),
                      child: const Text(
                        '\u0639\u0631\u0636 \u0627\u0644\u0643\u0644',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final product = products[index];
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
                      offset: Offset(0, (1 - itemAnim) * 12),
                      child: _MenuCompactTile(
                        product: product,
                        onTap: () {
                          appLogger.d(
                            '[HomeScreen] product tapped: ${product.nameAr}',
                          );
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
        );
      },
    );
  }
}

class _MenuCompactTile extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const _MenuCompactTile({required this.product, required this.onTap});

  @override
  State<_MenuCompactTile> createState() => _MenuCompactTileState();
}

class _MenuCompactTileState extends State<_MenuCompactTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final tags = p.options.isNotEmpty
        ? p.options.map((o) => o.nameAr ?? o.name).take(3).join(' \u2022 ')
        : p.descriptionAr ??
            '\u0645\u0643\u0648\u0646\u0627\u062a \u0637\u0627\u0632\u062c\u0629';

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: ProductImage(
                    imageUrl: p.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: AppColors.surfaceContainerLow,
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                    errorWidget: Container(
                      color: AppColors.surfaceContainerLow,
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nameAr,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tags,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Text(
                            '${p.price.toStringAsFixed(0)} \u062c.\u0645',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedCartButton(product: p),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
