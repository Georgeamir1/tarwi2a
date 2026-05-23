import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/di/injection_container.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/menu/categories_cubit.dart';
import '../../../application/menu/products_cubit.dart';
import '../../../application/cart/cart_cubit.dart';
import '../../../domain/entities/product.dart';
import '../../widgets/product_image.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_card.dart';

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

class _HomeBodyState extends State<_HomeBody> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          child: const CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HomeGreeting()),
              SliverToBoxAdapter(child: _HomeSearchBar()),
              SliverToBoxAdapter(child: _HomeCategoriesChips()),
              SliverToBoxAdapter(child: _HomeHeroBanner()),
              SliverToBoxAdapter(child: _HomePopularSection()),
              SliverToBoxAdapter(child: _HomeMenuHeader()),
              _HomeMenuList(),
              SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeGreeting extends StatelessWidget {
  const _HomeGreeting();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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
                    Text(
                      name.isNotEmpty ? 'أهلاً $name 👋' : 'أهلاً بك 👋',
                      style: AppTypography.largeTitle.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ماذا تشتهي اليوم؟',
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
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
              return Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 22,
                      ),
                      onPressed: () {
                        appLogger.d('[HomeScreen] cart tapped');
                        context.push('/cart');
                      },
                      padding: EdgeInsets.zero,
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
                              color: AppColors.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search, color: AppColors.outline, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث عن طبق أو مطعم...',
                  hintStyle: AppTypography.subheadline.copyWith(
                    color: AppColors.outline,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
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

  static const _chipIcons = {
    'الكل': Icons.check_circle,
    'المزيد': Icons.apps,
    'سندوتشات': Icons.bakery_dining,
    'مشروبات': Icons.local_drink,
    'صويت': Icons.rice_bowl,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, catState) {
        if (catState.status != CategoriesStatus.loaded) {
          return const SizedBox(height: 56);
        }

        return BlocBuilder<ProductsCubit, ProductsState>(
          buildWhen: (prev, next) =>
              prev.selectedCategoryId != next.selectedCategoryId,
          builder: (context, prodState) {
            final allChips = [
              const _ChipOption(label: 'الكل', categoryId: null),
              ...catState.categories
                  .map((c) => _ChipOption(label: c.nameAr, categoryId: c.id)),
            ];

            return SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final option = allChips[index];
                  final isSelected =
                      prodState.selectedCategoryId == option.categoryId;
                  final icon = _chipIcons[option.label];
                  return _CategoryChip(
                    label: option.label,
                    icon: icon,
                    isSelected: isSelected,
                    onTap: () {
                      appLogger.d(
                          '[HomeScreen] category selected: ${option.categoryId ?? 'all'}');
                      context.read<ProductsCubit>().selectCategory(
                            prodState.selectedCategoryId == option.categoryId
                                ? null
                                : option.categoryId,
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE02B2B) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF6B4C2A) : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTypography.subheadline.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
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

class _HomeHeroBanner extends StatelessWidget {
  const _HomeHeroBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, prodState) {
        if (prodState.status == ProductsStatus.loading ||
            prodState.products.isEmpty) {
          return const SizedBox.shrink();
        }

        final hero = prodState.products.first;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: GestureDetector(
            onTap: () {
              appLogger.d('[HomeScreen] hero tapped: ${hero.nameAr}');
              context.push('/product/${hero.id}', extra: hero);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(
                      imageUrl: hero.imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          Container(color: AppColors.surfaceContainerHigh),
                      errorWidget: Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: AppColors.outline,
                          size: 48,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // "عرض يومية" badge top right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'عرض يومية',
                              style: AppTypography.footnote.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Product info on the left side
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hero.nameAr,
                              style: AppTypography.headline.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hero.descriptionAr ?? 'طازجة من الفرن',
                              style: AppTypography.footnote.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            if (hero.descriptionAr != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'بمكونات مختارة بعناية',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'اطلب الآن',
                                    style: AppTypography.footnote.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_back_ios,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Price on the right side
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Text(
                        '${hero.price.toStringAsFixed(0)} رس',
                        style: AppTypography.headline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    'الأكثر طلباً',
                    style: AppTypography.headline.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const Text(' 🔥'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          'عرض الكل',
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_back_ios,
                          size: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: popular.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
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

class _PopularCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _PopularCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: onTap,
                    child: ProductImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          Container(color: AppColors.surfaceContainerHigh),
                      errorWidget: Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: AppColors.outline,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  // Heart icon top left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_outline,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  // Add button bottom left
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.nameAr,
                  style: AppTypography.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.price.toStringAsFixed(0)} رس',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeMenuHeader extends StatelessWidget {
  const _HomeMenuHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Text(
            'قائمة الطعام',
            style: AppTypography.headline.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.restaurant_menu, size: 18),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  'عرض الكل',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_back_ios,
                  size: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeMenuList extends StatelessWidget {
  const _HomeMenuList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.status == ProductsStatus.loading ||
            state.status == ProductsStatus.initial) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: 4,
              itemBuilder: (context, index) => const SkeletonListTile(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
            ),
          );
        }

        if (state.status == ProductsStatus.error) {
          return const SliverFillRemaining(
            child: Center(
              child: Text('حصل خطأ', textDirection: TextDirection.rtl),
            ),
          );
        }

        if (state.products.isEmpty) {
          return const SliverFillRemaining(
            child: EmptyState(
              icon: Icons.restaurant_menu,
              title: 'مفيش أصناف في هذه الفئة',
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return _MenuListItem(
                product: product,
                onTap: () {
                  appLogger.d('[HomeScreen] product tapped: ${product.nameAr}');
                  context.push('/product/${product.id}', extra: product);
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        );
      },
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _MenuListItem({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Build tags like "عجينة طازجة • جبنة سوزاريلا • خضار"
    final tags = product.options.isNotEmpty
        ? product.options.map((o) => o.nameAr ?? o.name).take(3).join(' • ')
        : product.descriptionAr ?? 'مكونات طازجة';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Add button on the far left (RTL far-left)
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              onPressed: () {
                context.read<CartCubit>().addItem(product);
              },
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12),
          // Product info (right side in RTL)
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.nameAr,
                    style: AppTypography.callout.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tags,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0)} رس',
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Image on the right side (RTL right)
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: 80,
                height: 80,
                child: ProductImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: Container(color: AppColors.surfaceContainerHigh),
                  errorWidget: Container(
                    color: AppColors.surfaceContainerHigh,
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: AppColors.outline,
                      size: 28,
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
