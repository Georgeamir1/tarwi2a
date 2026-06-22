import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/logger/app_logger.dart';
import '../../../application/menu/categories_cubit.dart';
import '../../../application/menu/products_cubit.dart';
import '../../widgets/product_compact_tile.dart';

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
  String? _lastCategoryQuery;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routerState = GoRouterState.of(context);
    final categoryQuery = routerState.uri.queryParameters['category'];
    if (categoryQuery != _lastCategoryQuery) {
      _lastCategoryQuery = categoryQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ProductsCubit>().selectCategory(categoryQuery);
        }
      });
    }
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
      backgroundColor: AppColors.background,
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
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: _ProductList(animCtrl: _animCtrl),
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
              color: AppColors.onSurface,
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
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Product List ─────────────────────────────────────────────────────────────

class _ProductList extends StatelessWidget {
  final AnimationController animCtrl;
  const _ProductList({required this.animCtrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.status == ProductsStatus.loading ||
            state.status == ProductsStatus.initial) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => _buildSkeleton(),
          );
        }

        if (state.status == ProductsStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  '\u062d\u0635\u0644 \u062e\u0637\u0623', // حصل خطأ
                  style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 18, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  state.failure?.message ?? '',
                  style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 14, color: AppColors.textMuted),
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
                Icon(Icons.restaurant_menu_outlined, size: 64, color: AppColors.outlineVariant),
                SizedBox(height: 16),
                Text(
                  '\u0644\u0627 \u062a\u0648\u062c\u062f \u0645\u0646\u062a\u062c\u0627\u062a', // لا توجد منتجات
                  style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 18, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          itemCount: state.products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                    offset: Offset(0, (1 - animation.value) * 15),
                    child: child,
                  ),
                );
              },
              child: ProductCompactTile(
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
      height: 104,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
    );
  }
}
