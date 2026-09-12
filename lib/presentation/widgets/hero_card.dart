import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/product.dart';
import '../extensions/price_x.dart';
import 'product_image.dart';

class HeroCard extends StatelessWidget {
  final Product product;
  final String tag;
  final VoidCallback onTap;

  const HeroCard({
    super.key,
    required this.product,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ProductImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                placeholder: Container(color: AppColors.grey200),
                errorWidget: Container(
                  color: AppColors.grey200,
                  child: const Icon(Icons.fastfood,
                      color: AppColors.grey400, size: 48),
                ),
              )
            else
              Container(
                color: AppColors.grey200,
                child: const Center(
                  child:
                      Icon(Icons.fastfood, color: AppColors.grey400, size: 48),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.textPrimary.withValues(alpha: 0.15),
                      AppColors.textPrimary.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: null,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  tag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.nameAr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price.formatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey300,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
