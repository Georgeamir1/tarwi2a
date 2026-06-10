import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/enums/order_status.dart';
import '../extensions/order_status_x.dart';

enum OrderStatusTrackerVariant { compact, horizontal, vertical }

class OrderStatusTracker extends StatelessWidget {
  final OrderStatus status;
  final OrderStatusTrackerVariant variant;
  final bool showDescriptions;
  final bool showCurrentDescriptionOnly;

  const OrderStatusTracker({
    super.key,
    required this.status,
    this.variant = OrderStatusTrackerVariant.horizontal,
    this.showDescriptions = false,
    this.showCurrentDescriptionOnly = false,
  });

  const OrderStatusTracker.compact({
    super.key,
    required this.status,
  })  : variant = OrderStatusTrackerVariant.compact,
        showDescriptions = false,
        showCurrentDescriptionOnly = false;

  const OrderStatusTracker.horizontal({
    super.key,
    required this.status,
  })  : variant = OrderStatusTrackerVariant.horizontal,
        showDescriptions = false,
        showCurrentDescriptionOnly = false;

  const OrderStatusTracker.vertical({
    super.key,
    required this.status,
    this.showDescriptions = true,
  })  : variant = OrderStatusTrackerVariant.vertical,
        showCurrentDescriptionOnly = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final steps = OrderStatusX.steps;
    final activeIndex = status.progressIndex;
    final isCancelled = status == OrderStatus.cancelled;

    switch (variant) {
      case OrderStatusTrackerVariant.compact:
        return _buildCompact(context, steps, activeIndex, isCancelled, isDark);
      case OrderStatusTrackerVariant.horizontal:
        return _buildHorizontal(
            context, steps, activeIndex, isCancelled, isDark);
      case OrderStatusTrackerVariant.vertical:
        return _buildVertical(
          context,
          theme,
          steps,
          activeIndex,
          isCancelled,
          isDark,
        );
    }
  }

  Widget _buildCompact(
    BuildContext context,
    List<Map<String, dynamic>> steps,
    int activeIndex,
    bool isCancelled,
    bool isDark,
  ) {
    if (isCancelled) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Row(
      children: List.generate(5, (index) {
        final isCompleted = index <= activeIndex;
        final isCurrent = index == activeIndex;
        final stepColor = isCompleted
            ? (isCurrent ? AppColors.primary : AppColors.statusReady)
            : (isDark ? AppColors.darkDivider : AppColors.outlineVariant);

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 0
                          ? Colors.transparent
                          : (index <= activeIndex
                              ? AppColors.statusReady
                              : (isDark
                                  ? AppColors.darkDivider
                                  : AppColors.outlineVariant)),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isCurrent ? 12 : 8,
                    height: isCurrent ? 12 : 8,
                    decoration: BoxDecoration(
                      color: stepColor,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 4
                          ? Colors.transparent
                          : (index < activeIndex
                              ? AppColors.statusReady
                              : (isDark
                                  ? AppColors.darkDivider
                                  : AppColors.outlineVariant)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                steps[index]['label'] as String,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                  color: isCurrent
                      ? AppColors.primary
                      : (isCompleted
                          ? (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.onSurface)
                          : AppColors.textMuted),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHorizontal(
    BuildContext context,
    List<Map<String, dynamic>> steps,
    int activeIndex,
    bool isCancelled,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant, width: 0.8),
        boxShadow: const [AppShadows.card],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isActive = !isCancelled && index <= activeIndex;
          final isCurrent = !isCancelled && index == activeIndex;
          final color = isCancelled
              ? AppColors.error
              : (isActive ? AppColors.primary : AppColors.textMuted);
          final bg = isCancelled
              ? AppColors.error.withValues(alpha: 0.1)
              : (isActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceContainerLow);

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: index == 0
                          ? const SizedBox.shrink()
                          : Container(
                              height: 2,
                              color: index <= activeIndex && !isCancelled
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                            ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                        border: isCurrent || isCancelled
                            ? Border.all(color: color, width: 1.5)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Icon(
                        isCancelled
                            ? Icons.cancel_outlined
                            : (steps[index]['icon'] as IconData),
                        size: 16,
                        color: color,
                      ),
                    ),
                    Expanded(
                      child: index == steps.length - 1
                          ? const SizedBox.shrink()
                          : Container(
                              height: 2,
                              color: index < activeIndex && !isCancelled
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isCancelled && isCurrent
                      ? 'ملغي'
                      : (steps[index]['label'] as String),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: isActive || isCancelled
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: isActive || (isCancelled && isCurrent)
                        ? AppColors.onSurface
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVertical(
    BuildContext context,
    ThemeData theme,
    List<Map<String, dynamic>> steps,
    int activeIndex,
    bool isCancelled,
    bool isDark,
  ) {
    final inactiveColor = AppColors.outlineVariant;
    final inactiveBg = AppColors.surfaceContainerLow;
    final inactiveLine = AppColors.outlineVariant;

    return Column(
      children: List.generate(steps.length, (index) {
        final isActive = !isCancelled && index <= activeIndex;
        final isCurrent = !isCancelled && index == activeIndex;
        final color = isCancelled
            ? AppColors.error
            : (isActive ? AppColors.primary : AppColors.textMuted);

        return SizedBox(
          height: showDescriptions ? 84 : 56,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    if (index != 0)
                      Container(
                        width: 2,
                        height: 12,
                        color: isActive ? AppColors.primary : inactiveLine,
                      ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : inactiveBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.primary
                              : (isCancelled ? AppColors.error : inactiveColor),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isCancelled
                            ? Icons.cancel_outlined
                            : (steps[index]['icon'] as IconData),
                        size: 15,
                        color: color,
                      ),
                    ),
                    if (index != steps.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isActive ? AppColors.primary : inactiveLine,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      isCancelled && isCurrent
                          ? 'ملغي'
                          : (steps[index]['label'] as String),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isActive || (isCancelled && isCurrent)
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isActive || (isCancelled && isCurrent)
                            ? AppColors.onSurface
                            : AppColors.textMuted,
                      ),
                    ),
                    if (showDescriptions) ...[
                      const SizedBox(height: 2),
                      Text(
                        steps[index]['desc'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isActive
                              ? AppColors.textSecondary
                              : AppColors.textMuted,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
