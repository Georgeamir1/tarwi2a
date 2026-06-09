import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_categories_cubit.dart';
import '../../../application/admin/admin_products_cubit.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../widgets/product_image.dart';
import '../../widgets/tag_selector.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String? _selectedCategoryFilterId;

  // Memoisation cache — avoid recomputing filtered/grouped lists on every build
  List<Product>? _cachedFiltered;
  List<({String catId, String catName, List<Product> products})>?
      _cachedGrouped;
  String? _cachedSearchQuery;
  String? _cachedFilterId;
  List<Product>? _cachedRawProducts;
  List<Category>? _cachedRawCategories;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Lazy-load data on first visit — cubits are NOT preloaded at provision
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  void _loadData() {
    context.read<AdminProductsCubit>().loadProducts();
    context.read<AdminCategoriesCubit>().loadCategories();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    if (q != _searchQuery) {
      _invalidateCache();
      setState(() => _searchQuery = q);
    }
  }

  void _onFilterSelected(String? id) {
    HapticFeedback.lightImpact();
    _invalidateCache();
    setState(() {
      _selectedCategoryFilterId = _selectedCategoryFilterId == id ? null : id;
    });
  }

  void _invalidateCache() {
    _cachedFiltered = null;
    _cachedGrouped = null;
    _cachedSearchQuery = null;
    _cachedFilterId = null;
    _cachedRawProducts = null;
    _cachedRawCategories = null;
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── Memoised filter + group (runs only when inputs change) ──────────

  ({
    List<Product> filtered,
    List<({String catId, String catName, List<Product> products})> grouped
  }) _computeFilteredAndGrouped(
      List<Product> products, List<Category> categories) {
    final q = _searchQuery;
    final filterId = _selectedCategoryFilterId;

    // Return cached result when nothing changed
    if (identical(_cachedRawProducts, products) &&
        identical(_cachedRawCategories, categories) &&
        _cachedSearchQuery == q &&
        _cachedFilterId == filterId &&
        _cachedFiltered != null &&
        _cachedGrouped != null) {
      return (filtered: _cachedFiltered!, grouped: _cachedGrouped!);
    }

    _cachedRawProducts = products;
    _cachedRawCategories = categories;
    _cachedSearchQuery = q;
    _cachedFilterId = filterId;

    // Filter
    List<Product> filtered;
    if (filterId == null && q.isEmpty) {
      filtered = products;
    } else {
      filtered = products.where((p) {
        if (filterId != null && p.categoryId != filterId) return false;
        if (q.isEmpty) return true;
        final nameAr = p.nameAr.toLowerCase();
        final nameEn = p.name.toLowerCase();
        final descAr = (p.descriptionAr ?? '').toLowerCase();
        final descEn = (p.description ?? '').toLowerCase();
        return nameAr.contains(q) ||
            nameEn.contains(q) ||
            descAr.contains(q) ||
            descEn.contains(q);
      }).toList(growable: false);
    }

    _cachedFiltered = filtered;

    // Group
    final catNameMap = <String, String>{
      for (final c in categories) c.id: c.nameAr,
    };
    final grouped =
        <({String catId, String catName, List<Product> products})>[];
    final seen = <String>{};

    for (final p in filtered) {
      final cid = p.categoryId ?? 'no_category';
      if (!seen.contains(cid)) {
        seen.add(cid);
        grouped.add((
          catId: cid,
          catName: cid == 'no_category'
              ? 'بدون فئة'
              : (catNameMap[cid] ?? 'فئة غير معروفة'),
          products: [p],
        ));
      } else {
        grouped.lastWhere((g) => g.catId == cid).products.add(p);
      }
    }

    _cachedGrouped = grouped;

    return (filtered: filtered, grouped: grouped);
  }

  // ── Pre-computed category counts ────────────────────────────────────

  Map<String, int> _computeCatCounts(
      List<Product> products, List<Category> categories) {
    final counts = <String, int>{};
    for (final c in categories) {
      counts[c.id] = 0;
    }
    for (final p in products) {
      final cid = p.categoryId ?? 'no_category';
      counts[cid] = (counts[cid] ?? 0) + 1;
    }
    return counts;
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AdminProductsCubit, AdminProductsState>(
      buildWhen: _productsChanged,
      builder: (context, productsState) {
        return BlocBuilder<AdminCategoriesCubit, AdminCategoriesState>(
          buildWhen: _categoriesChanged,
          builder: (context, categoriesState) {
            final products = productsState.products;
            final categories = categoriesState.categories;

            // Only show spinner during initial load (data not yet arrived)
            final isLoading =
                (productsState.status == AdminProductsStatus.loading &&
                        products.isEmpty) ||
                    (categoriesState.status == AdminCategoriesStatus.loading &&
                        categories.isEmpty);

            // Compute once per builder invocation, not per build
            final result = _computeFilteredAndGrouped(products, categories);
            final filteredProds = result.filtered;
            final grouped = result.grouped;

            // Pre-compute category counts (used in filter bar)
            final catCounts = _computeCatCounts(products, categories);

            return Scaffold(
              backgroundColor:
                  isDark ? AppColors.darkBackground : AppColors.background,
              body: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _refresh(context),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _MenuHeader(
                        totalProducts: products.length,
                        activeProducts:
                            products.where((p) => p.isAvailable).length,
                        totalCategories: categories.length,
                        onCategoriesTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/admin/categories');
                        },
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _SearchBar(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            searchQuery: _searchQuery,
                          ),
                          AppSpacing.gapH12,
                          if (categories.isNotEmpty)
                            _CategoryFilterBar(
                              categories: categories,
                              selectedId: _selectedCategoryFilterId,
                              catCounts: catCounts,
                              onSelected: _onFilterSelected,
                            ),
                          AppSpacing.gapH20,
                          if (isLoading)
                            const _ProductsSkeleton()
                          else if (productsState.status ==
                              AdminProductsStatus.error)
                            _ErrorState(
                                message: productsState.failure?.message ??
                                    'خطأ في تحميل البيانات')
                          else if (filteredProds.isEmpty)
                            _buildEmptyState(products.isEmpty, theme, isDark)
                          else
                            _buildProductList(grouped, theme, isDark),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/admin/product/new');
                },
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: _fabLabel(theme),
              ),
            );
          },
        );
      },
    );
  }

  // Only rebuild when products actually change, not on intermediate
  // loading states (e.g. during toggleAvailable → skips the 1st emit).
  static bool _productsChanged(
      AdminProductsState prev, AdminProductsState curr) {
    if (prev.products != curr.products) return true;
    if (prev.products.isEmpty && prev.status != curr.status) return true;
    if (curr.status == AdminProductsStatus.error) return true;
    return false;
  }

  static bool _categoriesChanged(
      AdminCategoriesState prev, AdminCategoriesState curr) {
    if (prev.categories != curr.categories) return true;
    if (prev.categories.isEmpty && prev.status != curr.status) return true;
    if (curr.status == AdminCategoriesStatus.error) return true;
    return false;
  }

  static Widget _fabLabel(ThemeData theme) {
    return Text(
      'صنف جديد',
      style: theme.textTheme.titleSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ── Product list (uses Column with direct children — fine for admin
  //    counts; switch to ListView.builder if lists grow > 50) ───────────

  Widget _buildProductList(
    List<({String catId, String catName, List<Product> products})> grouped,
    ThemeData theme,
    bool isDark,
  ) {
    final children = <Widget>[];
    for (final group in grouped) {
      children.add(
        _SectionHeader(
          title: group.catName,
          action: _sectionCountBadge(group.products.length),
        ),
      );
      children.add(AppSpacing.gapH12);
      for (final product in group.products) {
        children.add(
          _ProductListItem(
            key: ValueKey(product.id),
            product: product,
            isDark: isDark,
            onEdit: () {
              HapticFeedback.lightImpact();
              context.push('/admin/product/edit', extra: product);
            },
            onToggle: (val) async {
              HapticFeedback.lightImpact();
              await context
                  .read<AdminProductsCubit>()
                  .toggleAvailable(product.id, val);
            },
            onDelete: () => _confirmDelete(context, product),
          ),
        );
      }
      children.add(AppSpacing.gapH20);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  static Widget _sectionCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '$count صنف',
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    HapticFeedback.mediumImpact();
    _invalidateCache();
    await Future.wait([
      context.read<AdminProductsCubit>().loadProducts(),
      context.read<AdminCategoriesCubit>().loadCategories(),
    ]);
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_forever_rounded,
            color: AppColors.error, size: 48),
        title: const Text(
          'حذف الصنف',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${product.nameAr}"؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontFamily: 'Cairo', height: 1.5),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء',
                style: TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: const Text('حذف',
                style: TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();
      await context.read<AdminProductsCubit>().deleteProduct(product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('تم حذف "${product.nameAr}"',
                    style: const TextStyle(fontFamily: 'Cairo')),
              ],
            ),
            backgroundColor: AppColors.statusCancelled,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState(bool isTotalEmpty, ThemeData theme, bool isDark) {
    if (isTotalEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.darkDivider
                : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
          boxShadow: const [AppShadows.card],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أصناف بعد',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.onSurface,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ابدأ بإضافة أول صنف لقائمة الطعام',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.secondary.withValues(alpha: 0.7),
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkDivider
              : AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            'لم يتم العثور على نتائج',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'جرب كلمة بحث أخرى أو غير الفلتر',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.secondary.withValues(alpha: 0.7),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              _invalidateCache();
              setState(() {
                _selectedCategoryFilterId = null;
                _searchQuery = '';
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة تعيين',
                style: TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Gradient Header
// ──────────────────────────────────────────────────────────────

class _MenuHeader extends StatelessWidget {
  final int totalProducts;
  final int activeProducts;
  final int totalCategories;
  final VoidCallback onCategoriesTap;

  const _MenuHeader({
    required this.totalProducts,
    required this.activeProducts,
    required this.totalCategories,
    required this.onCategoriesTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hiddenCount = totalProducts - activeProducts;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? const [Color(0xFF3B2423), Color(0xFF2C1918)]
              : [
                  AppColors.primary,
                  const Color(0xFFC02222),
                  const Color(0xFF8B1E1E),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeaderIconBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/admin');
                      }
                    },
                  ),
                  const Spacer(),
                  _HeaderIconBtn(
                    icon: Icons.category_rounded,
                    size: 20,
                    onTap: onCategoriesTap,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.restaurant_menu_rounded,
                          color: Colors.white, size: 26),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إدارة المنيو',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        'الأصناف والفئات والأسعار',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _GlassStatCard(
                      value: '$totalProducts',
                      label: 'إجمالي الأصناف',
                      icon: Icons.restaurant_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GlassStatCard(
                      value: '$activeProducts',
                      label: 'متاح للطلب',
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GlassStatCard(
                      value: '$hiddenCount',
                      label: 'مخفي',
                      icon: Icons.visibility_off_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _GlassStatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Cairo',
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              fontFamily: 'Cairo',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Search Bar
// ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String searchQuery;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.darkDivider
              : AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: const [AppShadows.card],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontFamily: 'Cairo',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن صنف...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            fontFamily: 'Cairo',
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            size: 22,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    controller.clear();
                    focusNode.unfocus();
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Category Filter Bar
// ──────────────────────────────────────────────────────────────

class _CategoryFilterBar extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final Map<String, int> catCounts;
  final ValueChanged<String?> onSelected;

  const _CategoryFilterBar({
    required this.categories,
    required this.selectedId,
    required this.catCounts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final id = isAll ? null : category!.id;
          final isSelected = selectedId == id;
          final count = isAll
              ? catCounts.values.fold<int>(0, (a, b) => a + b)
              : (catCounts[category!.id] ?? 0);

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.full),
                onTap: () => onSelected(isSelected ? null : id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkCard : AppColors.surface),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark
                              ? AppColors.darkDivider
                              : AppColors.outlineVariant
                                  .withValues(alpha: 0.6)),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAll ? 'الكل' : category!.nameAr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected ? Colors.white : AppColors.primary,
                            fontFamily: 'Cairo',
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
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Section Header
// ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.onSurface,
            fontFamily: 'Cairo',
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Product List Item
// ──────────────────────────────────────────────────────────────

class _ProductListItem extends StatelessWidget {
  final Product product;
  final bool isDark;
  final VoidCallback onEdit;
  final void Function(bool) onToggle;
  final VoidCallback onDelete;

  const _ProductListItem({
    required super.key,
    required this.product,
    required this.isDark,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = product.isAvailable;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: key!,
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: Colors.white, size: 28),
        ),
        confirmDismiss: (_) async {
          onDelete();
          return false;
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isAvailable ? 1.0 : 0.65,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColors.darkDivider
                    : AppColors.outlineVariant.withValues(alpha: 0.6),
              ),
              boxShadow: const [AppShadows.card],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      _ProductThumbnail(
                        imageUrl: product.imageUrl,
                        isAvailable: isAvailable,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ProductInfo(
                          nameAr: product.nameAr,
                          nameEn: product.name,
                          price: product.price,
                          prepTime: product.preparationTime,
                          tags: product.tags,
                          isAvailable: isAvailable,
                          isDark: isDark,
                        ),
                      ),
                      _ProductActions(
                        isAvailable: isAvailable,
                        onToggle: onToggle,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  final String? imageUrl;
  final bool isAvailable;
  final bool isDark;

  const _ProductThumbnail({
    required this.imageUrl,
    required this.isAvailable,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkDivider
              : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ProductImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: Container(
              color: isDark
                  ? AppColors.darkDivider
                  : AppColors.surfaceContainerHigh,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
            errorWidget: Container(
              color: isDark
                  ? AppColors.darkDivider
                  : AppColors.surfaceContainerHigh,
              child: const Icon(Icons.restaurant_rounded,
                  color: AppColors.textMuted, size: 28),
            ),
          ),
          if (!isAvailable)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: Icon(Icons.visibility_off_rounded,
                      color: Colors.white70, size: 22),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final String nameAr;
  final String nameEn;
  final double price;
  final int? prepTime;
  final List<String> tags;
  final bool isAvailable;
  final bool isDark;

  const _ProductInfo({
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.prepTime,
    required this.tags,
    required this.isAvailable,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nameAr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isAvailable
                ? (isDark ? AppColors.darkTextPrimary : AppColors.onSurface)
                : AppColors.textSecondary,
            fontFamily: 'Cairo',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${price.toStringAsFixed(0)} ر.س',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                fontFamily: 'Cairo',
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            if (prepTime != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.timer_outlined,
                  size: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.secondary.withValues(alpha: 0.6)),
              const SizedBox(width: 2),
              Text(
                '$prepTime د',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.secondary.withValues(alpha: 0.6),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 6),
          _TagRow(tags: tags),
        ],
      ],
    );
  }
}

class _TagRow extends StatelessWidget {
  final List<String> tags;

  const _TagRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags.take(3).map((tagId) {
        final tag = ProductTags.all.firstWhere(
          (t) => t.id == tagId,
          orElse: () => ProductTag(
              id: tagId,
              label: tagId,
              icon: Icons.label,
              color: AppColors.textSecondary),
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: tag.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            tag.label,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: tag.color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _ProductActions extends StatelessWidget {
  final bool isAvailable;
  final void Function(bool) onToggle;

  const _ProductActions({
    required this.isAvailable,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Semantics(
          label: isAvailable ? 'متاح' : 'غير متاح',
          child: Switch.adaptive(
            value: isAvailable,
            onChanged: onToggle,
            activeTrackColor: AppColors.success,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isAvailable
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isAvailable
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.error.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            isAvailable ? 'متاح' : 'مخفي',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isAvailable ? AppColors.success : AppColors.error,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Skeleton / Error
// ──────────────────────────────────────────────────────────────

class _ProductsSkeleton extends StatelessWidget {
  const _ProductsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'خطأ: $message',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.error,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
