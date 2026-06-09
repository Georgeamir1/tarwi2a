import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// Predefined product tags for restaurant items.
class ProductTags {
  static const List<ProductTag> all = [
    ProductTag(id: 'new', label: 'جديد', icon: Icons.fiber_new_rounded, color: Color(0xFF3B82F6)),
    ProductTag(id: 'popular', label: 'الأكثر طلباً', icon: Icons.local_fire_department_rounded, color: Color(0xFFEF4444)),
    ProductTag(id: 'spicy', label: 'حار', icon: Icons.whatshot_rounded, color: Color(0xFFF97316)),
    ProductTag(id: 'vegetarian', label: 'نباتي', icon: Icons.eco_rounded, color: Color(0xFF22C55E)),
    ProductTag(id: 'gluten_free', label: 'خالي من الجلوتين', icon: Icons.grain_rounded, color: Color(0xFF8B5CF6)),
    ProductTag(id: 'chef_pick', label: 'اختيار الشيف', icon: Icons.star_rounded, color: Color(0xFFC68B59)),
  ];
}

class ProductTag {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const ProductTag({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

/// A multi-select chip group for selecting product tags/badges.
class TagSelector extends StatelessWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.label_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'شارات المنتج',
              style: AppTypography.callout.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProductTags.all.map((tag) {
            final isSelected = selectedTags.contains(tag.id);
            return _TagChip(
              tag: tag,
              isSelected: isSelected,
              onTap: () {
                final updated = List<String>.from(selectedTags);
                if (isSelected) {
                  updated.remove(tag.id);
                } else {
                  updated.add(tag.id);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final ProductTag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? tag.color.withValues(alpha: 0.12)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isSelected ? tag.color : AppColors.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tag.icon,
                size: 16,
                color: isSelected ? tag.color : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                tag.label,
                style: AppTypography.footnote.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? tag.color : AppColors.onSurface,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: tag.color,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
