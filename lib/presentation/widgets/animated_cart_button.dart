import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/cart/cart_cubit.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _kBrand = Color(0xFFE02B2B);

class AnimatedCartButton extends StatelessWidget {
  final Product product;
  final double size; // kept for signature compatibility

  const AnimatedCartButton({
    super.key,
    required this.product,
    this.size = 40,
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
          duration: const Duration(milliseconds: 300),
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

  // "+ أضف" Capsule Button with 48px Touch Target
  Widget _buildAddButton(BuildContext context) {
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
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _kBrand,
              borderRadius: BorderRadius.circular(999), // full pill shape
              boxShadow: [
                BoxShadow(
                  color: _kBrand.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox(width: 4),
                Text(
                  '\u0623\u0636\u0641', // أضف
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
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

  // Stepper Controller with 48px Buttons and Stepper Background: #C8102E
  Widget _buildStepper(BuildContext context, int quantity) {
    return Container(
      key: const ValueKey('stepper_btn'),
      height: 48,
      decoration: BoxDecoration(
        color: _kBrand, // Stepper background: #C8102E / Cherry Red
        borderRadius: BorderRadius.circular(999), // Matching full pill shape
        boxShadow: [
          BoxShadow(
            color: _kBrand.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          // Plus button (48px Touch Target)
          Semantics(
            label: '\u0632\u064a\u0627\u062f\u0629 \u0627\u0644\u0643\u0645\u064a\u0629',
            button: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<CartCubit>().addItem(product);
              },
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Quantity indicator
          Container(
            constraints: const BoxConstraints(minWidth: 24),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Text(
                  '$quantity',
                  key: ValueKey('qty_$quantity'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Minus button (48px Touch Target)
          Semantics(
            label: '\u062a\u0642\u0644\u064a\u0644 \u0627\u0644\u0643\u0645\u064a\u0629',
            button: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<CartCubit>().removeItem(product.id);
              },
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(
                      Icons.remove_rounded,
                      size: 20,
                      color: Colors.white,
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
