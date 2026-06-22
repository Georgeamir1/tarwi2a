import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class NotificationBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color? color;
  final double iconSize;
  final VoidCallback? onTap;
  final String? tooltip;

  const NotificationBadge({
    super.key,
    required this.icon,
    required this.count,
    this.color,
    this.iconSize = 24,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.onSurface;
    final badge = Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: AppColors.background,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );

    if (onTap == null && tooltip == null) return badge;
    return IconButton(
      icon: badge,
      tooltip: tooltip,
      onPressed: onTap,
      splashRadius: 22,
    );
  }
}
