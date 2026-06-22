import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme/app_theme.dart';
import '../../application/cart/cart_cubit.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/selected_option.dart';

class CartAddButton extends StatelessWidget {
  final Product product;
  final List<SelectedOption> selectedOptions;
  final double iconSize;
  final double buttonSize;

  const CartAddButton({
    super.key,
    required this.product,
    this.selectedOptions = const [],
    this.iconSize = 20,
    this.buttonSize = 34,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final inCart = state.items.firstWhere(
          (item) =>
              item.productId == product.id &&
              _optionsMatch(item.selectedOptions, selectedOptions),
          orElse: () => CartItem(
            productId: product.id,
            productNameAr: '',
            productPrice: 0,
            quantity: 0,
          ),
        );
        final quantity = inCart.productId == product.id ? inCart.quantity : 0;

        if (quantity == 0) {
          return _AddButton(
            iconSize: iconSize,
            buttonSize: buttonSize,
            onPressed: () {
              HapticFeedback.lightImpact();
              context
                  .read<CartCubit>()
                  .addItem(product, selectedOptions: selectedOptions);
            },
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context
                      .read<CartCubit>()
                      .removeItem(product.id, selectedOptions: selectedOptions);
                },
                child: SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: const Icon(Icons.remove,
                      color: Colors.white, size: 18),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                child: Center(
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context
                      .read<CartCubit>()
                      .addItem(product, selectedOptions: selectedOptions);
                },
                child: SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: const Icon(Icons.add,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _optionsMatch(
      List<SelectedOption> a, List<SelectedOption> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.optionId).toList()..sort();
    final bIds = b.map((e) => e.optionId).toList()..sort();
    return aIds.join(',') == bIds.join(',');
  }
}

class _AddButton extends StatefulWidget {
  final double iconSize;
  final double buttonSize;
  final VoidCallback onPressed;

  const _AddButton({
    required this.iconSize,
    required this.buttonSize,
    required this.onPressed,
  });

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: widget.buttonSize,
          height: widget.buttonSize,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: widget.iconSize,
          ),
        ),
      ),
    );
  }
}
