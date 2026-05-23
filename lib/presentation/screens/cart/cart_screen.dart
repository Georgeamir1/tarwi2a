import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';
import '../../../application/cart/cart_cubit.dart';
import '../../../core/logger/app_logger.dart';
import '../../widgets/empty_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        appLogger.i(
            '[CartScreen] build — items: ${state.items.length}, total: ${state.total}');

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text('سلة التسوق'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                appLogger.i('[CartScreen] back pressed');
                context.pop();
              },
            ),
            actions: [
              if (state.items.isNotEmpty)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg)),
                        title: const Text('مسح السلة'),
                        content:
                            const Text('هل أنت متأكد من مسح جميع الأصناف؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<CartCubit>().clearCart();
                              Navigator.pop(ctx);
                            },
                            child: Text(
                              'مسح',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'مسح الكل',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.error),
                  ),
                ),
            ],
          ),
          body: state.items.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'السلة فاضية',
                  subtitle: 'أضف أصناف من المنيو',
                  actionLabel: 'اطلع على المنيو',
                  onAction: () {
                    appLogger.i('[CartScreen] navigate back to menu');
                    context.pop();
                  },
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => AppSpacing.gapH12,
                        itemBuilder: (context, index) => _CartItemCard(
                          item: state.items[index],
                          onAdd: () {
                            appLogger.i(
                                '[CartScreen] increment item: ${state.items[index].productNameAr}');
                            final item = state.items[index];
                            context.read<CartCubit>().addItem(
                                  Product(
                                    id: item.productId,
                                    name: '',
                                    nameAr: item.productNameAr,
                                    price: item.productPrice,
                                    isAvailable: true,
                                    sortOrder: 0,
                                  ),
                                  selectedOptions: item.selectedOptions,
                                );
                          },
                          onRemove: () {
                            appLogger.i(
                                '[CartScreen] decrement item: ${state.items[index].productNameAr}');
                            final item = state.items[index];
                            context.read<CartCubit>().removeItem(
                                  item.productId,
                                  selectedOptions: item.selectedOptions,
                                );
                          },
                          onDelete: () {
                            appLogger.i(
                                '[CartScreen] delete item: ${state.items[index].productNameAr}');
                            final item = state.items[index];
                            context.read<CartCubit>().deleteItem(
                                  item.productId,
                                  selectedOptions: item.selectedOptions,
                                );
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowSubtle,
                            blurRadius: 20,
                            offset: Offset(0, -8),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المجموع (${state.totalItems} صنف)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${state.total.toStringAsFixed(0)} جنيه',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.gapH16,
                            ElevatedButton(
                              onPressed: () {
                                appLogger
                                    .i('[CartScreen] navigate to /checkout');
                                context.push('/checkout');
                              },
                              child: const Text('إتمام الطلب'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productNameAr,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.selectedOptions.isNotEmpty) ...[
                      AppSpacing.gapH4,
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: item.selectedOptions.map((option) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Text(
                              '${option.name}${option.priceAdjustment > 0 ? ' (+${option.priceAdjustment.toStringAsFixed(0)}ج)' : ''}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    AppSpacing.gapH8,
                    Text(
                      '${item.productPrice.toStringAsFixed(0)} ج / للوحدة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    color: AppColors.error.withValues(alpha: 0.7), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          AppSpacing.gapH12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: AppRadius.smAll,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.remove_rounded,
                            size: 16, color: AppColors.primary),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onAdd,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.add_rounded,
                            size: 16, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.subtotal.toStringAsFixed(0)} ج',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
