import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../../application/cart/cart_cubit.dart';

class FloatingCartBar extends StatelessWidget {
  final bool visible;

  const FloatingCartBar({
    super.key,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final hasItems = state.items.isNotEmpty;
        final shouldShow = visible && hasItems;

        return AnimatedSlide(
          offset: shouldShow ? Offset.zero : const Offset(0, 2.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: shouldShow ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !shouldShow,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 4.0),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryShadow,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.push('/cart');
                      },
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                const Icon(
                                  Icons.shopping_cart_rounded,
                                  color: AppColors.onPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${state.totalItems} \u0635\u0646\u0641 \u00b7 ${state.total.toStringAsFixed(0)} \u062c\u0640',
                                  style: AppTypography.subheadline.copyWith(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Text(
                                  '\u0639\u0631\u0636 \u0627\u0644\u0633\u0644\u0629 \u2190',
                                  style: AppTypography.subheadline.copyWith(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
