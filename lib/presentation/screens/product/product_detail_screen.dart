import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_option.dart';
import '../../../domain/entities/selected_option.dart';
import '../../../application/cart/cart_cubit.dart';
import '../../../application/admin/admin_product_options_cubit.dart';
import '../../../core/logger/app_logger.dart';
import '../../widgets/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  final List<SelectedOption> _selectedOptions = [];
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    appLogger.i(
        '[ProductDetailScreen] initState — product: ${widget.product.nameAr}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AdminProductOptionsCubit>()
          .loadByProductId(widget.product.id);
    });
  }

  double get _itemPrice {
    final optionsTotal =
        _selectedOptions.fold(0.0, (sum, o) => sum + o.priceAdjustment);
    return widget.product.price + optionsTotal;
  }

  double get _totalPrice => _itemPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () {
                    appLogger.i('[ProductDetailScreen] back pressed');
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  child: IconButton(
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      size: 20,
                      color:
                          _isFavorite ? AppColors.error : AppColors.textPrimary,
                    ),
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite);
                      appLogger.i(
                          '[ProductDetailScreen] favorite toggled: $_isFavorite');
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: Container(color: AppColors.grey100),
                    errorWidget: Container(
                      color: AppColors.grey100,
                      child: const Icon(Icons.fastfood,
                          size: 80, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.surface.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.nameAr,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Text(
                          '${product.price.toStringAsFixed(0)} ج',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (product.descriptionAr != null &&
                      product.descriptionAr!.isNotEmpty) ...[
                    AppSpacing.gapH12,
                    Text(
                      product.descriptionAr!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                  AppSpacing.gapH32,
                  const _SectionTitle(title: 'الكمية'),
                  AppSpacing.gapH12,
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                              appLogger.i(
                                  '[ProductDetailScreen] quantity decreased to $_quantity');
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_quantity',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add_rounded,
                          onTap: () {
                            setState(() => _quantity++);
                            appLogger.i(
                                '[ProductDetailScreen] quantity increased to $_quantity');
                          },
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapH32,
                  BlocBuilder<AdminProductOptionsCubit,
                      AdminProductOptionsState>(
                    builder: (context, state) {
                      if (state.status == AdminProductOptionsStatus.loading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          ),
                        );
                      }
                      if (state.options.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _OptionGroups(
                        options: state.options,
                        selectedOptions: _selectedOptions,
                        onChanged: (selected) => setState(() => _selectedOptions
                          ..clear()
                          ..addAll(selected)),
                      );
                    },
                  ),
                  AppSpacing.gapH24,
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          final inCartQty = cartState.items
              .where((item) => item.productId == product.id)
              .fold(0, (sum, item) => sum + item.quantity);
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowSubtle,
                  blurRadius: 20,
                  offset: Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإجمالي',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${_totalPrice.toStringAsFixed(0)} جنيه',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        if (inCartQty > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            'في السلة: $inCartQty',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        appLogger.i(
                            '[ProductDetailScreen] add to cart — ${product.nameAr} x $_quantity');
                        for (int i = 0; i < _quantity; i++) {
                          context.read<CartCubit>().addItem(product,
                              selectedOptions: _selectedOptions);
                        }
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'تمت إضافة $_quantity x ${product.nameAr}'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.smAll),
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          ),
                        );
                        setState(() => _quantity = 1);
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                      label: Text(inCartQty > 0
                          ? 'أضف المزيد ($_quantity)'
                          : 'أضف للسلة'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: AppRadius.smAll,
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _OptionGroups extends StatelessWidget {
  final List<ProductOption> options;
  final List<SelectedOption> selectedOptions;
  final ValueChanged<List<SelectedOption>> onChanged;

  const _OptionGroups({
    required this.options,
    required this.selectedOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'خيارات إضافية'),
        AppSpacing.gapH12,
        ...options.map((option) {
          final isSelected =
              selectedOptions.any((s) => s.optionId == option.id);
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color:
                    isSelected ? AppColors.primary : AppColors.outlineVariant,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () {
                if (isSelected) {
                  onChanged(
                    selectedOptions
                        .where((s) => s.optionId != option.id)
                        .toList(),
                  );
                } else {
                  final newList = [...selectedOptions];
                  if (option.maxSelections > 1 &&
                      newList.length >= option.maxSelections) {
                    newList.removeAt(0);
                  }
                  newList.add(SelectedOption(
                    optionId: option.id,
                    name: option.nameAr ?? option.name,
                    priceAdjustment: option.priceDelta,
                  ));
                  onChanged(newList);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 22,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    AppSpacing.gapW8,
                    Expanded(
                      child: Text(
                        option.nameAr ?? option.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                      ),
                    ),
                    if (option.priceDelta > 0)
                      Text(
                        '+${option.priceDelta.toInt()} ج',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
