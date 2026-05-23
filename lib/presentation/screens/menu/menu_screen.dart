import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/menu/products_cubit.dart';
import '../../../core/di/injection_container.dart';
import '../../widgets/product_card.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/empty_state.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {return BlocProvider(
      create: (_) => sl<ProductsCubit>()..loadProducts(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('القائمة'),
          centerTitle: true,
        ),
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            return switch (state.status) {
              ProductsStatus.loading => GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => const SkeletonProductCard(),
                ),
              ProductsStatus.loaded => state.products.isEmpty
                  ? const Center(
                      child: EmptyState(
                        icon: Icons.restaurant_menu_outlined,
                        title: 'لا توجد منتجات',
                        subtitle: 'لم تتم إضافة منتجات بعد',
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (_, index) {
                        final product = state.products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {},
                        );
                      },
                    ),
              ProductsStatus.error => Center(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'حدث خطأ',
                    subtitle: state.failure?.message ?? '',
                    actionLabel: 'إعادة المحاولة',
                    onAction: () =>
                        context.read<ProductsCubit>().loadProducts(),
                  ),
                ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonCard(height: 220);
  }
}
