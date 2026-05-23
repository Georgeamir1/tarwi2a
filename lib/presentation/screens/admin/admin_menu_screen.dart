import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_categories_cubit.dart';
import '../../../application/admin/admin_products_cubit.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/product.dart';

class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AdminProductsCubit, AdminProductsState>(
      builder: (context, productsState) {
        return BlocBuilder<AdminCategoriesCubit, AdminCategoriesState>(
          builder: (context, categoriesState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('إدارة المنيو'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    onPressed: () {
                      appLogger.d(
                          '[AdminMenuScreen] navigate to /admin/product/new');
                      context.push('/admin/product/new');
                    },
                  ),
                ],
              ),
              body: SafeArea(
                child: () {
                  if (productsState.status == AdminProductsStatus.loading ||
                      categoriesState.status == AdminCategoriesStatus.loading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (productsState.status == AdminProductsStatus.error) {
                    return Center(
                        child: Text(
                            'خطأ: ${productsState.failure?.message ?? ''}'));
                  }
                  if (categoriesState.status == AdminCategoriesStatus.error) {
                    return Center(
                        child: Text(
                            'خطأ: ${categoriesState.failure?.message ?? ''}'));
                  }

                  final prods = productsState.products;
                  final cats = categoriesState.categories;

                  appLogger.d(
                      '[AdminMenuScreen] loaded products: ${prods.length}, categories: ${cats.length}');

                  if (prods.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: AppColors.grey300,
                          ),
                          AppSpacing.gapH16,
                          const Text(
                            'مفيش أصناف لسه',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          AppSpacing.gapH24,
                          ElevatedButton.icon(
                            onPressed: () => context.push('/admin/product/new'),
                            icon: const Icon(Icons.add),
                            label: const Text('أضف صنف جديد'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(180, 48),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final Map<String, List<Product>> grouped = {};
                  final Map<String, String> catNames = {
                    for (var c in cats) c.id: c.nameAr,
                  };
                  grouped['no_category'] = [];
                  for (var c in cats) {
                    grouped[c.id] = [];
                  }
                  for (var p in prods) {
                    final key = p.categoryId ?? 'no_category';
                    grouped.putIfAbsent(key, () => []).add(p);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        grouped.entries.where((e) => e.value.isNotEmpty).length,
                    itemBuilder: (context, index) {
                      final entries = grouped.entries
                          .where((e) => e.value.isNotEmpty)
                          .toList();
                      final entry = entries[index];
                      final catName = entry.key == 'no_category'
                          ? 'بدون فئة'
                          : (catNames[entry.key] ?? 'فئة غير معروفة');

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              catName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          ...entry.value.map(
                            (product) => _ProductAdminTile(
                              product: product,
                              onEdit: () {
                                appLogger.d(
                                    '[AdminMenuScreen] edit product: ${product.nameAr}');
                                context.push('/admin/product/edit',
                                    extra: product);
                              },
                              onToggle: (val) async {
                                appLogger.d(
                                    '[AdminMenuScreen] toggle product ${product.id} availability to $val');
                                await context
                                    .read<AdminProductsCubit>()
                                    .toggleAvailable(product.id, val);
                              },
                            ),
                          ),
                          AppSpacing.gapH8,
                        ],
                      );
                    },
                  );
                }(),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  appLogger.d('[AdminMenuScreen] FAB — new product');
                  context.push('/admin/product/new');
                },
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: AppColors.surface),
                label: Text(
                  'صنف جديد',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.surface,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Text(
          product.nameAr,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: product.isAvailable
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          '${product.price.toStringAsFixed(0)} جنيه',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: product.isAvailable,
              activeTrackColor: AppColors.primary,
              onChanged: onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
