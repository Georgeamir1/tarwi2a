import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../application/rating/rating_cubit.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class ProductReviewsScreen extends StatelessWidget {
  final String productId;
  final String productName;

  const ProductReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RatingCubit>(
      create: (context) => sl<RatingCubit>()..loadProductRatings(productId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppTopBar(
          title: 'التقييمات',
          variant: TopBarVariant.withBack,
        ),
        body: BlocBuilder<RatingCubit, RatingState>(
          builder: (context, state) {
            if (state.status == RatingStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.status == RatingStatus.error) {
              return Center(
                child: Text(
                  state.failure?.map(
                        server: (f) => f.message,
                        network: (f) => f.message,
                        validation: (f) => f.message,
                        unexpected: (f) => f.message,
                      ) ??
                      'حدث خطأ غير متوقع أثناء تحميل التقييمات',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            final ratings = state.productRatings;

            double averageRating = 0.0;
            if (ratings.isNotEmpty) {
              final sum = ratings.map((r) => r.rating).reduce((a, b) => a + b);
              averageRating = sum / ratings.length;
            }

            if (ratings.isEmpty) {
              return Column(
                children: [
                  _RatingSummary(
                    productName: productName,
                    averageRating: 0.0,
                    totalReviews: 0,
                  ),
                  const Divider(color: AppColors.outlineVariant),
                  const Expanded(
                    child: EmptyState(
                      icon: Icons.star_outline_rounded,
                      title: 'لا توجد تقييمات بعد',
                      subtitle: 'كن أول من يطلب ويقيم هذا المنتج!',
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _RatingSummary(
                  productName: productName,
                  averageRating: averageRating,
                  totalReviews: ratings.length,
                ),
                const Divider(color: AppColors.outlineVariant),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: ratings.length,
                    itemBuilder: (context, index) {
                      final review = ratings[index];
                      return _ReviewTile(
                        name: review.customerName,
                        date: review.createdAt,
                        rating: review.rating,
                        comment: review.comment ?? 'بدون تعليق',
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final String productName;
  final double averageRating;
  final int totalReviews;

  const _RatingSummary({
    required this.productName,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int roundedRating = averageRating.round();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        Icons.star,
                        size: 20,
                        color: i < roundedRating ? AppColors.statusPending : AppColors.outlineVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($totalReviews تقييم)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
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

class _ReviewTile extends StatelessWidget {
  final String name;
  final DateTime date;
  final int rating;
  final String comment;

  const _ReviewTile({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
  });

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      return 'اليوم، ${DateFormat('hh:mm a').format(dateTime)}';
    } else if (difference.inDays == 1 ||
        (difference.inHours < 48 &&
            dateTime.day ==
                now.subtract(const Duration(days: 1)).day)) {
      return 'أمس، ${DateFormat('hh:mm a').format(dateTime)}';
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _formatRelativeTime(date.toLocal()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: AppColors.statusPending,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              comment,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
