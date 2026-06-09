import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_categories_cubit.dart';
import '../../../application/admin/admin_products_cubit.dart';
import '../../../domain/entities/category.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_button.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminProductsCubit, AdminProductsState>(
      builder: (context, productsState) {
        return BlocBuilder<AdminCategoriesCubit, AdminCategoriesState>(
          builder: (context, state) {
            final isLoading = state.status == AdminCategoriesStatus.loading;

            return Scaffold(
              appBar: AppTopBar(
                title: 'إدارة الأقسام',
                variant: TopBarVariant.withBack,
                actions: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showCategoryBottomSheet(context);
                    },
                    icon: const Icon(Icons.add_rounded),
                    tooltip: 'قسم جديد',
                  ),
                ],
              ),
              body: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _buildBody(context, state, productsState),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AdminCategoriesState state,
    AdminProductsState productsState,
  ) {
    if (state.categories.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const EmptyState(
                icon: Icons.category_outlined,
                title: 'لا توجد أقسام',
                subtitle: 'أضف أول قسم لتنظيم قائمة الطعام الخاصة بك',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showCategoryBottomSheet(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('أضف قسم جديد'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 50),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: state.categories.length,
      itemBuilder: (_, index) {
        final cat = state.categories[index];
        
        // Calculate product count under this category
        final productCount = productsState.products
            .where((p) => p.categoryId == cat.id)
            .length;

        return _CategoryCard(
          category: cat,
          productCount: productCount,
          onEdit: () => _showCategoryBottomSheet(context, category: cat),
          onDelete: () => _confirmDeleteCategory(context, cat, productCount),
          onToggle: (v) {
            HapticFeedback.lightImpact();
            context.read<AdminCategoriesCubit>().toggleActive(cat.id, v);
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    Category category,
    int productCount,
  ) async {
    HapticFeedback.vibrate();

    // Guard: Prevent deletion if category has products
    if (productCount > 0) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 48),
          title: const Text('لا يمكن الحذف'),
          content: Text(
            'هذا القسم يحتوي على ($productCount) من الأصناف.\nيرجى نقل أو حذف الأصناف أولاً قبل حذف القسم.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 48),
        title: const Text('حذف القسم؟'),
        content: Text('هل أنت متأكد من حذف قسم "${category.nameAr}"؟\nلا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();
      await context.read<AdminCategoriesCubit>().deleteCategory(category.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف قسم "${category.nameAr}"'),
            backgroundColor: AppColors.statusCancelled,
          ),
        );
      }
    }
  }

  void _showCategoryBottomSheet(BuildContext context, {Category? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryFormSheet(category: category),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int productCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _CategoryCard({
    required this.category,
    required this.productCount,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = category.isActive;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isActive ? AppColors.outlineVariant : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icon / Emoji Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                    ? Text(
                        category.imageUrl!,
                        style: const TextStyle(fontSize: 26),
                      )
                    : const Icon(
                        Icons.category_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category.nameAr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isActive ? AppColors.onSurface : AppColors.textSecondary,
                          ),
                        ),
                        if (!isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              'معطل',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.error,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Sort Order Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sort_rounded, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'الترتيب: ${category.sortOrder}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Product Count Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            '$productCount صنف',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Switch.adaptive(
                    value: category.isActive,
                    onChanged: onToggle,
                    activeTrackColor: AppColors.success,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        color: AppColors.primary,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        color: AppColors.error,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  final Category? category;

  const _CategoryFormSheet({this.category});

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameArController;
  late final TextEditingController _nameController;
  late final TextEditingController _sortOrderController;
  String? _selectedEmoji;
  bool _isActive = true;
  bool _isLoading = false;

  bool get _isEditing => widget.category != null;

  // Food Emojis lists
  final List<String> _emojis = [
    '🍔', '🍕', '🥤', '🍰', '🥗', '🍦', '🍗', '🍟', '🌮', '🍝',
    '🍳', '☕', '🍱', '🍩', '🍎', '🍇', '🍣', '🌶️', '🍖', '🍲'
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameArController = TextEditingController(text: c?.nameAr ?? '');
    _nameController = TextEditingController(text: c?.name ?? '');
    _sortOrderController = TextEditingController(text: c?.sortOrder.toString() ?? '0');
    _isActive = c?.isActive ?? true;
    _selectedEmoji = c?.imageUrl; // Using imageUrl as emoji indicator
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        'name_ar': _nameArController.text.trim(),
        'name': _nameController.text.trim().isEmpty
            ? _nameArController.text.trim()
            : _nameController.text.trim(),
        'sort_order': int.tryParse(_sortOrderController.text.trim()) ?? 0,
        'is_active': _isActive,
        'image_url': _selectedEmoji, // Save chosen emoji to imageUrl
      };

      await context.read<AdminCategoriesCubit>().upsert(
            data,
            id: _isEditing ? widget.category!.id : null,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تعديل القسم بنجاح' : 'تم إضافة القسم بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء الحفظ. يرجى المحاولة لاحقاً.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  _isEditing ? 'تعديل القسم' : 'إضافة قسم جديد',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Name AR
                TextFormField(
                  controller: _nameArController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم بالعربية *',
                    hintText: 'مثال: المشروبات',
                    prefixIcon: Icon(Icons.edit_rounded, size: 20),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى إدخال الاسم بالعربية' : null,
                ),
                const SizedBox(height: 14),

                // Name EN
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم بالإنجليزية (اختياري)',
                      hintText: 'e.g. Beverages',
                      prefixIcon: Icon(Icons.translate_rounded, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Sort Order
                TextFormField(
                  controller: _sortOrderController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'الترتيب التنازلي',
                    prefixIcon: Icon(Icons.sort_rounded, size: 20),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى إدخال رقم الترتيب' : null,
                ),
                const SizedBox(height: 20),

                // Emoji picker / selector
                Row(
                  children: [
                    const Icon(Icons.emoji_emotions_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'أيقونة القسم (رموز تعبيرية)',
                      style: AppTypography.footnote.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _emojis.length,
                    itemBuilder: (ctx, index) {
                      final emoji = _emojis[index];
                      final isSelected = _selectedEmoji == emoji;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedEmoji = isSelected ? null : emoji;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 44,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Active Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'قسم نشط (يظهر للعملاء)',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                LoadingButton(
                  onPressed: _save,
                  label: _isEditing ? 'حفظ التعديلات' : 'إضافة القسم',
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 8),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
