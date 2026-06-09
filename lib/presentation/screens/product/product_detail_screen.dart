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
import '../../widgets/tag_selector.dart';

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
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: AppColors.surface.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: AppColors.textPrimary),
                  onPressed: () {
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
                  backgroundColor: AppColors.surface.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      size: 20,
                      color: _isFavorite
                          ? AppColors.tertiary
                          : AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite);
                      HapticFeedback.lightImpact();
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
                    placeholder:
                        Container(color: AppColors.surfaceContainerLow),
                    errorWidget: Container(
                      color: AppColors.surfaceContainerLow,
                      child: const Icon(Icons.fastfood,
                          size: 80, color: AppColors.textSecondary),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.background,
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.nameAr,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Text(
                          '${product.price.toStringAsFixed(0)} \u062c.\u0645',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (product.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.tags.map((tagId) {
                        final tag = ProductTags.all.firstWhere(
                          (t) => t.id == tagId,
                          orElse: () => ProductTag(
                            id: tagId,
                            label: tagId,
                            icon: Icons.label_rounded,
                            color: AppColors.primary,
                          ),
                        );
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: tag.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: tag.color.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(tag.icon, size: 14, color: tag.color),
                              const SizedBox(width: 4),
                              Text(
                                tag.label,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: tag.color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (product.preparationTime != null ||
                      product.calories != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (product.preparationTime != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.outlineVariant
                                    .withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  '${product.preparationTime} دقيقة',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (product.calories != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.outlineVariant
                                    .withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department_outlined,
                                    size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  '${product.calories} سعرة حرارية',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (product.descriptionAr != null &&
                      product.descriptionAr!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      product.descriptionAr!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.7,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  const _SectionTitle(
                      title: '\u0627\u0644\u0643\u0645\u064a\u0629'),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                          color:
                              AppColors.outlineVariant.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                              HapticFeedback.lightImpact();
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Text(
                              '$_quantity',
                              key: ValueKey<int>(_quantity),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add_rounded,
                          onTap: () {
                            setState(() => _quantity++);
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
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
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          final inCartQty = cartState.items
              .where((item) => item.productId == product.id)
              .fold(0, (sum, item) => sum + item.quantity);
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '\u0627\u0644\u0625\u062c\u0645\u0627\u0644\u064a',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              _totalPrice.toStringAsFixed(0),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '\u062c.\u0645',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (inCartQty > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '\u0641\u064a \u0627\u0644\u0633\u0644\u0629: $inCartQty',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.statusReady,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Semantics(
                      label:
                          '\u0625\u0636\u0627\u0641\u0629 \u0644\u0644\u0633\u0644\u0629\u060c \u0632\u0631',
                      button: true,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          for (int i = 0; i < _quantity; i++) {
                            context.read<CartCubit>().addItem(product,
                                selectedOptions: _selectedOptions);
                          }
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '\u062a\u0645\u062a \u0625\u0636\u0627\u0641\u0629 $_quantity \u00d7 ${product.nameAr}',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: AppColors.primary,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md)),
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            ),
                          );
                          setState(() => _quantity = 1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 4,
                          shadowColor: AppColors.primaryShadow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        icon: const Icon(Icons.add_shopping_cart_rounded,
                            size: 20),
                        label: Text(inCartQty > 0
                            ? '\u0623\u0636\u0641 \u0627\u0644\u0645\u0632\u064a\u062f ($_quantity)'
                            : '\u0623\u0636\u0641 \u0644\u0644\u0633\u0644\u0629'),
                      ),
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
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
        const _SectionTitle(
            title:
                '\u062e\u064a\u0627\u0631\u0627\u062a \u0625\u0636\u0627\u0641\u064a\u0629'),
        const SizedBox(height: 12),
        ...options.map((option) {
          final isSelected =
              selectedOptions.any((s) => s.optionId == option.id);
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.statusReady.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected
                    ? AppColors.statusReady
                    : AppColors.outlineVariant.withValues(alpha: 0.6),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () {
                HapticFeedback.lightImpact();
                if (isSelected) {
                  onChanged(selectedOptions
                      .where((s) => s.optionId != option.id)
                      .toList());
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        key: ValueKey(isSelected),
                        size: 22,
                        color: isSelected
                            ? AppColors.statusReady
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        option.nameAr ?? option.name,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (option.priceDelta > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primaryContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '+${option.priceDelta.toInt()} \u062c',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
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
