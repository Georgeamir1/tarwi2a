import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class FoodCardLarge extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String? description;
  final List<String>? tags;
  final double price;
  final double? rating;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const FoodCardLarge({
    super.key,
    required this.imageUrl,
    required this.name,
    this.description,
    this.tags,
    required this.price,
    this.rating,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppRadius.xl),
              ),
              child: Image.network(
                imageUrl,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 140,
                  height: 140,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child:
                      const Icon(Icons.fastfood, color: Colors.grey, size: 48),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null) ...[
                      AppSpacing.gapH4,
                      Text(
                        description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (tags != null && tags!.isNotEmpty) ...[
                      AppSpacing.gapH8,
                      Wrap(
                        spacing: 4,
                        children: tags!
                            .map((tag) => Chip(
                                  label: Text(tag,
                                      style: theme.textTheme.labelSmall),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ))
                            .toList(),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (rating != null) ...[
                              const Icon(Icons.star,
                                  size: 16, color: AppColors.statusPending),
                              Text(
                                ' $rating',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppSpacing.gapW8,
                            ],
                            Text(
                              '$price ج',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        IconButton.filled(
                          onPressed: onAddToCart,
                          icon: const Icon(Icons.add, size: 18),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(36, 36),
                            padding: EdgeInsets.zero,
                          ),
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
}
