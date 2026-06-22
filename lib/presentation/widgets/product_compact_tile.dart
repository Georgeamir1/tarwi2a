import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../application/cart/cart_cubit.dart';
import '../extensions/price_x.dart';
import 'product_image.dart';
import 'animated_cart_button.dart';

class ProductCompactTile extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCompactTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCompactTile> createState() => _ProductCompactTileState();
}

class _ProductCompactTileState extends State<ProductCompactTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final description = p.descriptionAr ?? p.description;
    final hasDescription = description != null && description.trim().isNotEmpty;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final cartItem = cartState.items.firstWhere(
          (item) => item.productId == p.id,
          orElse: () => const CartItem(
            productId: '',
            productNameAr: '',
            productPrice: 0,
            quantity: 0,
          ),
        );
        final inCart = cartItem.quantity > 0;

        return GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: inCart
                    ? AppColors.primary.withValues(alpha: 0.04)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: inCart
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.outlineVariant,
                  width: inCart ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: inCart
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  // Product Image (80x80)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: ProductImage(
                        imageUrl: p.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: Container(
                          color: AppColors.surfaceContainerLow,
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                        ),
                        errorWidget: Container(
                          color: AppColors.surfaceContainerLow,
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Name, Price, Stepper
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            // Product Name (Expanded to take available space)
                            Expanded(
                              child: Text(
                                p.nameAr,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Price
                            Text(
                              p.price.formatted,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(width: 8),
                            // Compact Stepper/Add Button
                            AnimatedCartButton(
                              product: p,
                              compact: true,
                            ),
                          ],
                        ),
                        // Row 2: Description (collapses if empty)
                        if (hasDescription) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.textSecondary,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
