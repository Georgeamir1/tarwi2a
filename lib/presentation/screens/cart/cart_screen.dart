import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';
import '../../../application/cart/cart_cubit.dart';
import '../../../core/logger/app_logger.dart';
import '../../extensions/price_x.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        appLogger.i(
            '[CartScreen] build — items: ${state.items.length}, total: ${state.total}');

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.95),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(
              '\u0627\u0644\u0633\u0644\u0629${state.items.isNotEmpty ? ' (${state.totalItems})' : ''}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              if (state.items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextButton(
                    onPressed: () => _showClearCartDialog(context),
                    child: const Text(
                      '\u0645\u0633\u062d \u0627\u0644\u0643\u0644',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: state.items.isEmpty
              ? _EmptyCartView()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: index < state.items.length - 1 ? 12 : 0,
                          ),
                          child: Dismissible(
                            key: ValueKey(
                                '${state.items[index].productId}-${state.items[index].selectedOptions.map((o) => o.optionId).join(',')}'),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              final item = state.items[index];
                              HapticFeedback.mediumImpact();
                              context.read<CartCubit>().deleteItem(
                                    item.productId,
                                    selectedOptions: item.selectedOptions,
                                  );
                            },
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 24),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                                size: 24,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              return await _confirmDelete(context);
                            },
                            child: _CartItemCard(
                              item: state.items[index],
                              onAdd: () {
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
                                final item = state.items[index];
                                HapticFeedback.lightImpact();
                                context.read<CartCubit>().removeItem(
                                      item.productId,
                                      selectedOptions: item.selectedOptions,
                                    );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    _CheckoutBar(
                        total: state.total, totalItems: state.totalItems),
                  ],
                ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        backgroundColor: AppColors.surface,
        title: const Text(
          '\u062d\u0630\u0641 \u0627\u0644\u0635\u0646\u0641\u061f',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          '\u0647\u0644 \u062a\u0631\u064a\u062f \u062d\u0630\u0641 \u0647\u0630\u0627 \u0627\u0644\u0635\u0646\u0641 \u0645\u0646 \u0627\u0644\u0633\u0644\u0629\u061f',
          style: TextStyle(fontFamily: 'Cairo'),
          textDirection: TextDirection.rtl,
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              '\u0625\u0644\u063a\u0627\u0621',
              style: TextStyle(
                  fontFamily: 'Cairo', color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '\u062d\u0630\u0641',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        backgroundColor: AppColors.surface,
        title: const Text(
          '\u0645\u0633\u062d \u0627\u0644\u0633\u0644\u0629',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          '\u0647\u0644 \u0623\u0646\u062a \u0645\u062a\u0623\u0643\u062f \u0645\u0646 \u0645\u0633\u062d \u062c\u0645\u064a\u0639 \u0627\u0644\u0623\u0635\u0646\u0627\u0641\u061f',
          style: TextStyle(fontFamily: 'Cairo'),
          textDirection: TextDirection.rtl,
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '\u0625\u0644\u063a\u0627\u0621',
              style: TextStyle(
                  fontFamily: 'Cairo', color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              Navigator.pop(ctx);
            },
            child: const Text(
              '\u0645\u0633\u062d',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '\u0627\u0644\u0633\u0644\u0629 \u0641\u0627\u0636\u064a\u0629',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            const Text(
              '\u0634\u0648\u0641 \u0627\u0644\u0642\u0627\u0626\u0645\u0629 \u0648\u0627\u062e\u062a\u0627\u0631 \u0627\u0644\u0623\u0643\u0644\u0627\u062a \u0627\u0644\u0644\u064a \u062a\u0639\u062c\u0628\u0643',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                ),
                child: const Text(
                  '\u062a\u0635\u0641\u062d \u0627\u0644\u0642\u0627\u0626\u0645\u0629',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final int totalItems;

  const _CheckoutBar({required this.total, required this.totalItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  '\u0627\u0644\u0645\u062c\u0645\u0648\u0639',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  total.formatted,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$totalItems \u0635\u0646\u0641',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  appLogger.i('[CartScreen] navigate to /checkout');
                  context.push('/checkout');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 4,
                  shadowColor: AppColors.primaryShadow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: const [
                    Icon(Icons.check_circle_outline_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                        '\u0625\u062a\u0645\u0627\u0645 \u0627\u0644\u0637\u0644\u0628'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productNameAr,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.selectedOptions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: item.selectedOptions.map((option) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer
                              .withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${option.name}${option.priceAdjustment > 0 ? ' +${option.priceAdjustment.toStringAsFixed(0)}' : ''}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onTertiaryContainer,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: [
                    _QuantityControl(
                      quantity: item.quantity,
                      onAdd: onAdd,
                      onRemove: onRemove,
                    ),
                    Text(
                      item.subtotal.formatted,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityControl({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRemove();
            },
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.remove_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onAdd();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_rounded,
                size: 18,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
