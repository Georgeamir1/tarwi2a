import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/product.dart';
import 'cart_add_button.dart';
import 'product_image.dart';

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
                        Text(
                          '${product.price.toStringAsFixed(0)} ج',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: compact ? 13 : 14,
                            color: AppColors.primary,
                          ),
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
      child: ProductImage(
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
    );
  }
}
