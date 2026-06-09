import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/logger/app_logger.dart';
import '../../../application/menu/categories_cubit.dart';
import '../../../application/menu/products_cubit.dart';
import '../../../domain/entities/product.dart';
import '../../widgets/product_image.dart';
import '../../widgets/animated_cart_button.dart';

// Design tokens local to this screen
const _kBrand = Color(0xFFE02B2B);
const _kBg = Color(0xFFFDF8F7);
const _kSurface = Color(0xFFFFFFFF);
const _kSurface2 = Color(0xFFFCF5F4);
const _kBorder = Color(0xFFE0D2D0);
const _kTextPrimary = Color(0xFF2C2120);
const _kTextSecondary = Color(0xFF7A6B69);
const _kTextMuted = Color(0xFF8C7B79);

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CategoriesCubit>()..loadCategories()),
        BlocProvider(create: (_) => sl<ProductsCubit>()..loadProducts()),
      ],
      child: const _MenuBody(),
    );
  }
}

class _MenuBody extends StatefulWidget {
  const _MenuBody();

  @override
  State<_MenuBody> createState() => _MenuBodyState();
}

class _MenuBodyState extends State<_MenuBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<CategoriesCubit>().loadCategories(),
      context.read<ProductsCubit>().loadProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            const _MenuHeader(),
            const SizedBox(height: 12),
            const _CategoryTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: _kBrand,
                backgroundColor: _kSurface,
                child: _ProductGrid(animCtrl: _animCtrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\u0642\u0627\u0626\u0645\u0629 \u0627\u0644\u0637\u0639\u0627\u0645', // قائمة الطعام
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Tabs ────────────────────────────────────────────────────────────

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, catState) {
        if (catState.status != CategoriesStatus.loaded) {
          return const SizedBox(height: 44);
        }

        return BlocBuilder<ProductsCubit, ProductsState>(
          buildWhen: (prev, next) =>
              prev.selectedCategoryId != next.selectedCategoryId,
          builder: (context, prodState) {
            final allTabs = [
              const _TabOption(label: '\u0627\u0644\u0643\u0644', categoryId: null), // الكل
              ...catState.categories
                  .map((c) => _TabOption(label: c.nameAr, categoryId: c.id)),
            ];

            return SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: allTabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final option = allTabs[index];
                  final isSelected =
                      prodState.selectedCategoryId == option.categoryId;
                  return _TabItem(
                    label: option.label,
                    isSelected: isSelected,
                    onTap: () {
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

class _TabOption {
  final String label;
  final String? categoryId;
  const _TabOption({required this.label, this.categoryId});
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _kBrand : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _kBrand : _kBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : _kTextSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Product Grid ─────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  final AnimationController animCtrl;
  const _ProductGrid({required this.animCtrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.status == ProductsStatus.loading ||
            state.status == ProductsStatus.initial) {
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => _buildSkeleton(),
          );
        }

        if (state.status == ProductsStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: _kBrand),
                const SizedBox(height: 16),
                const Text(
                  '\u062d\u0635\u0644 \u062e\u0637\u0623',
                  style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 18, color: _kTextPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  state.failure?.message ?? '',
                  style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 14, color: _kTextMuted),
                ),
              ],
            ),
          );
        }

        if (state.products.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu_outlined, size: 64, color: _kBorder),
                SizedBox(height: 16),
                Text(
                  '\u0644\u0627 \u062a\u0648\u062c\u062f \u0645\u0646\u062a\u062c\u0627\u062a',
                  style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 18, color: _kTextSecondary),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.62,
          ),
          itemCount: state.products.length,
          itemBuilder: (context, index) {
            final product = state.products[index];
            final delay = (index * 0.05).clamp(0.0, 0.5);
            final animation = CurvedAnimation(
              parent: animCtrl,
              curve: Interval(
                delay,
                (delay + 0.4).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              ),
            );

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Opacity(
                  opacity: animation.value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - animation.value) * 20),
                    child: child,
                  ),
                );
              },
              child: _MenuGridCard(
                product: product,
                onTap: () {
                  appLogger.d('[MenuScreen] tapped: ${product.nameAr}');
                  context.push('/product/${product.id}', extra: product);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ─── Grid Card ────────────────────────────────────────────────────────────────

class _MenuGridCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const _MenuGridCard({required this.product, required this.onTap});

  @override
  State<_MenuGridCard> createState() => _MenuGridCardState();
}

class _MenuGridCardState extends State<_MenuGridCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kBorder, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image 60%
              Expanded(
                flex: 60,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: ProductImage(
                    imageUrl: widget.product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: Container(color: _kSurface2),
                    errorWidget: Container(
                      color: _kSurface2,
                      child: const Icon(Icons.restaurant_menu,
                          color: _kTextMuted, size: 32),
                    ),
                  ),
                ),
              ),
              // Content 40%
              Expanded(
                flex: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // [Name + Price row]
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.nameAr,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _kTextPrimary,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Price Badge with white text and charcoal background
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2120), // Premium Dark Charcoal
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.product.price.toStringAsFixed(0)} \u062c.\u0645',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white, // #FFFFFF
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                      // [Stepper or AddButton]
                      SizedBox(
                        height: 40,
                        child: Center(
                          child: AnimatedCartButton(
                            product: widget.product,
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
    );
  }
}
