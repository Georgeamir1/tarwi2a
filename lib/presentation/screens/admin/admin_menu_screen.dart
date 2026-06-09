import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_categories_cubit.dart';
import '../../../application/admin/admin_products_cubit.dart';
import '../../../domain/entities/product.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_image.dart';
import '../../widgets/tag_selector.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh(BuildContext context) async {
    HapticFeedback.mediumImpact();
    await Future.wait([
      context.read<AdminProductsCubit>().loadProducts(),
      context.read<AdminCategoriesCubit>().loadCategories(),
    ]);
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 40),
        title: const Text('حذف الصنف؟'),
        content: Text('هل أنت متأكد من حذف "${product.nameAr}"؟\nلا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
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
            content: Text('تم حذف "${product.nameAr}"'),
            backgroundColor: AppColors.statusCancelled,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AdminProductsCubit, AdminProductsState>(
      builder: (context, productsState) {
        return BlocBuilder<AdminCategoriesCubit, AdminCategoriesState>(
          builder: (context, categoriesState) {
            final isLoading = productsState.status == AdminProductsStatus.loading ||
                categoriesState.status == AdminCategoriesStatus.loading;

            return Scaffold(
              appBar: AppTopBar(
                title: 'إدارة المنيو',
                variant: TopBarVariant.withBack,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.category_rounded),
                    tooltip: 'إدارة الأقسام',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push('/admin/categories');
                    },
                  ),
                ],
              ),
              body: SafeArea(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _refresh(context),
                        color: AppColors.primary,
                        child: _buildBody(productsState, categoriesState, theme),
                      ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/admin/product/new');
                },
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  'صنف جديد',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
    AdminProductsState productsState,
    AdminCategoriesState categoriesState,
    ThemeData theme,
  ) {
    if (productsState.status == AdminProductsStatus.error) {
      return Center(child: Text('خطأ: ${productsState.failure?.message ?? ''}'));
    }
    if (categoriesState.status == AdminCategoriesStatus.error) {
      return Center(child: Text('خطأ: ${categoriesState.failure?.message ?? ''}'));
    }

    final prods = productsState.products;
    final cats = categoriesState.categories;

    if (prods.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const EmptyState(
                icon: Icons.restaurant_menu_rounded,
                title: 'مفيش أصناف لسه',
                subtitle: 'ابدأ بإضافة أول صنف لقائمة الطعام الخاصة بك',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/admin/product/new'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('أضف صنف جديد'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 50),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filter products locally by search query
    final filteredProds = prods.where((p) {
      if (_searchQuery.isEmpty) return true;
      final nameAr = p.nameAr.toLowerCase();
      final nameEn = p.name.toLowerCase();
      final descAr = (p.descriptionAr ?? '').toLowerCase();
      final descEn = (p.description ?? '').toLowerCase();
      return nameAr.contains(_searchQuery) ||
          nameEn.contains(_searchQuery) ||
          descAr.contains(_searchQuery) ||
          descEn.contains(_searchQuery);
    }).toList();

    // Group filtered products
    final Map<String, List<Product>> grouped = {};
    final Map<String, String> catNames = {
      for (var c in cats) c.id: c.nameAr,
    };
    
    grouped['no_category'] = [];
    for (var c in cats) {
      grouped[c.id] = [];
    }
    for (var p in filteredProds) {
      final key = p.categoryId ?? 'no_category';
      grouped.putIfAbsent(key, () => []).add(p);
    }

    final activeGroups = grouped.entries.where((e) => e.value.isNotEmpty).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث عن صنف بالاسم أو الوصف...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),

        // Products list
        Expanded(
          child: activeGroups.isEmpty
              ? const Center(
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'لم يتم العثور على نتائج',
                    subtitle: 'تأكد من كتابة الاسم بشكل صحيح أو جرب كلمة أخرى',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: activeGroups.length,
                  itemBuilder: (context, index) {
                    final entry = activeGroups[index];
                    final catName = entry.key == 'no_category'
                        ? 'بدون فئة'
                        : (catNames[entry.key] ?? 'فئة غير معروفة');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header with count
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8, right: 4),
                          child: Row(
                            children: [
                              Text(
                                catName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  '${entry.value.length}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Products under this category
                        ...entry.value.map(
                          (product) => _DismissibleProductTile(
                            key: ValueKey(product.id),
                            product: product,
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
                            onDismissed: () => _confirmDelete(context, product),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DismissibleProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final void Function(bool) onToggle;
  final VoidCallback onDismissed;

  const _DismissibleProductTile({
    required super.key,
    required this.product,
    required this.onEdit,
    required this.onToggle,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return true; // confirmDelete is handled in onDismissed to not block UI thread
      },
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: _ProductAdminTile(
        product: product,
        onEdit: onEdit,
        onToggle: onToggle,
      ),
    );
  }
}

class _ProductAdminTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final void Function(bool) onToggle;

  const _ProductAdminTile({
    required this.product,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = product.isAvailable;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isAvailable ? 1.0 : 0.65,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isAvailable ? AppColors.surface : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isAvailable ? AppColors.outlineVariant : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: ProductImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
              errorWidget: const Icon(Icons.restaurant_rounded, color: AppColors.textSecondary, size: 24),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  product.nameAr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isAvailable ? AppColors.onSurface : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isAvailable)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'غير متاح',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${product.price.toStringAsFixed(0)} ر.س',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product.preparationTime != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '${product.preparationTime} د',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (product.calories != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.local_fire_department_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '${product.calories} سعرة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              if (product.tags.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: product.tags.map((tagId) {
                    final predefined = ProductTags.all.firstWhere(
                      (t) => t.id == tagId,
                      orElse: () => ProductTag(id: tagId, label: tagId, icon: Icons.label, color: AppColors.textSecondary),
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: predefined.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        predefined.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: predefined.color,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch.adaptive(
                value: product.isAvailable,
                onChanged: onToggle,
                activeTrackColor: AppColors.success,
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                onPressed: onEdit,
                color: AppColors.primary,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
