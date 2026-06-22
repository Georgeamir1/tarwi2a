import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme/app_theme.dart';
import '../../application/cart/cart_cubit.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';

class AnimatedCartButton extends StatelessWidget {
  final Product product;
  final double size; // kept for signature compatibility
  final bool compact;

  const AnimatedCartButton({
    super.key,
    required this.product,
    this.size = 40,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // If the product has options: tap goes to ProductDetailScreen, no stepper/button on card
    if (product.options.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final inCart = state.items.firstWhere(
          (item) => item.productId == product.id,
          orElse: () => const CartItem(
            productId: '',
            productNameAr: '',
            productPrice: 0,
            quantity: 0,
          ),
        );
        final quantity = inCart.quantity;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) {
            return FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: anim,
                child: child,
              ),
            );
          },
          child: quantity == 0
              ? _buildAddButton(context)
              : _buildStepper(context, quantity),
        );
      },
    );
  }

  // "+ أضف" Capsule Button
  Widget _buildAddButton(BuildContext context) {
    final h = compact ? 34.0 : 48.0;
    return Semantics(
      label: '\u0625\u0636\u0627\u0641\u0629 \u0644\u0644\u0633\u0644\u0629', // إضافة للسلة
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.read<CartCubit>().addItem(product);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            key: const ValueKey('add_btn'),
            height: h,
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: compact ? 6 : 10,
                  offset: Offset(0, compact ? 2 : 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: compact ? 14 : 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '\u0623\u0636\u0641', // أضف
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: compact ? 11 : 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Stepper Controller
  Widget _buildStepper(BuildContext context, int quantity) {
    final h = compact ? 34.0 : 48.0;
    final btnW = compact ? 34.0 : 48.0;
    return Container(
      key: const ValueKey('stepper_btn'),
      height: h,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          // Plus button
          Semantics(
            label: '\u0632\u064a\u0627\u062f\u0629 \u0627\u0644\u0643\u0645\u064a\u0629',
            button: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<CartCubit>().addItem(product);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: btnW,
                  height: h,
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: compact ? 16 : 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Quantity indicator
          Container(
            constraints: BoxConstraints(minWidth: compact ? 18 : 24),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Text(
                  '$quantity',
                  key: ValueKey('qty_$quantity'),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: compact ? 13 : 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

          // Minus button
          Semantics(
            label: '\u062a\u0642\u0644\u064a\u0644 \u0627\u0644\u0643\u0645\u064a\u0629',
            button: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<CartCubit>().removeItem(product.id);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: btnW,
                  height: h,
                  child: Center(
                    child: Icon(
                      Icons.remove_rounded,
                      size: compact ? 16 : 20,
                      color: AppColors.primary,
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
