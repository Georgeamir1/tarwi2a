import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/product.dart';
import '../extensions/price_x.dart';
import 'cart_add_button.dart';
import 'product_image.dart';
import 'tag_selector.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: product.nameAr,
      button: true,
      child: Focus(
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;
            return GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isFocused ? AppColors.primary : AppColors.divider,
                    width: isFocused ? 2 : 1,
                  ),
                  boxShadow: isFocused
                      ? [
                          const BoxShadow(
                              color: AppColors.primaryShadow, blurRadius: 8)
                        ]
                      : [
                          const BoxShadow(
                            color: AppColors.shadowSubtle,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadius.lg)),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ProductImage(
                              imageUrl: product.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                color: AppColors.grey100,
                                child: const Icon(Icons.fastfood,
                                    color: Colors.grey, size: 40),
                              ),
                              errorWidget: Container(
                                color: AppColors.grey100,
                                child: const Center(
                                  child: Icon(Icons.fastfood,
                                      color: Colors.grey, size: 40),
                                ),
                              ),
                            ),
                            if (product.tags.isNotEmpty)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: _buildTagBadge(product.tags.first),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.nameAr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product.preparationTime != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${product.preparationTime} د',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                          ] else ...[
                            AppSpacing.gapH6,
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.price.formatted,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              CartAddButton(
                                product: product,
                                iconSize: 16,
                                buttonSize: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTagBadge(String tagId) {
    final tag = ProductTags.all.firstWhere(
      (t) => t.id == tagId,
      orElse: () => ProductTag(
        id: tagId,
        label: tagId,
        icon: Icons.label_rounded,
        color: AppColors.primary,
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tag.color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tag.icon, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            tag.label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
