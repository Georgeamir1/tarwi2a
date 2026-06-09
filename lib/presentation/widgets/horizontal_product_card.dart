import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/product.dart';
import 'cart_add_button.dart';
import 'product_image.dart';
import 'tag_selector.dart';

class HorizontalProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool compact;

  const HorizontalProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: compact ? 88 : 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            _buildImage(compact),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: compact ? 10 : 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nameAr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: compact ? 13 : 14,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!compact && product.descriptionAr != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            product.descriptionAr!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${product.price.toStringAsFixed(0)} ج',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: compact ? 13 : 14,
                                color: AppColors.primary,
                              ),
                            ),
                            if (!compact &&
                                (product.preparationTime != null ||
                                    product.calories != null)) ...[
                              const SizedBox(width: 8),
                              if (product.preparationTime != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined,
                                        size: 11,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${product.preparationTime} د',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (product.calories != null) ...[
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.local_fire_department_outlined,
                                        size: 11,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${product.calories} سعرة',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                        CartAddButton(
                          product: product,
                          iconSize: compact ? 16 : 18,
                          buttonSize: compact ? 26 : 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(bool compact) {
    final width = compact ? 88.0 : 120.0;

    return SizedBox(
      width: width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ProductImage(
            imageUrl: product.imageUrl,
            fit: BoxFit.cover,
            width: width,
            height: double.infinity,
            placeholder: Container(color: AppColors.grey200),
            errorWidget: Container(
              color: AppColors.grey200,
              child: Icon(Icons.fastfood,
                  color: AppColors.grey400, size: compact ? 28 : 36),
            ),
          ),
          if (product.tags.isNotEmpty)
            Positioned(
              top: 6,
              right: 6,
              child: _buildTagBadge(product.tags.first),
            ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
          Icon(tag.icon, size: 9, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            tag.label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
