import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppRadius.lg,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.grey200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SkeletonCard(borderRadius: AppRadius.lg),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonCard(width: 80, height: 14, borderRadius: AppRadius.sm),
                AppSpacing.gapH8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonCard(
                        width: 50, height: 14, borderRadius: AppRadius.sm),
                    SkeletonCard(width: 30, height: 30, borderRadius: 15),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonCard(width: 100, height: 16, borderRadius: AppRadius.sm),
              SkeletonCard(width: 60, height: 20, borderRadius: AppRadius.full),
            ],
          ),
          AppSpacing.gapH8,
          SkeletonCard(width: 150, height: 12, borderRadius: AppRadius.sm),
          AppSpacing.gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonCard(width: 80, height: 12, borderRadius: AppRadius.sm),
              SkeletonCard(width: 60, height: 14, borderRadius: AppRadius.sm),
            ],
          ),
        ],
      ),
    );
  }
}
