import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 260,
      color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLow,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'لوحة التحكم',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 32),
          ..._items.asMap().entries.map(
                (entry) => _SidebarItem(
                  icon: entry.value.icon,
                  label: entry.value.label,
                  isSelected: entry.key == selectedIndex,
                  onTap: () => onItemSelected(entry.key),
                ),
              ),
        ],
      ),
    );
  }

  static const _items = [
    (icon: Icons.dashboard_outlined, label: 'لوحة القيادة'),
    (icon: Icons.receipt_long_outlined, label: 'الطلبات'),
    (icon: Icons.restaurant_menu_outlined, label: 'المنتجات'),
    (icon: Icons.category_outlined, label: 'الأقسام'),
    (icon: Icons.people_outline, label: 'العملاء'),
    (icon: Icons.discount_outlined, label: 'الكوبونات'),
    (icon: Icons.analytics_outlined, label: 'التقارير'),
    (icon: Icons.map_outlined, label: 'مناطق التوصيل'),
    (icon: Icons.store_outlined, label: 'الملف التجاري'),
  ];
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDark ? AppColors.inversePrimary : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: isSelected
            ? selectedColor.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? selectedColor
                      : isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? selectedColor
                            : isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
