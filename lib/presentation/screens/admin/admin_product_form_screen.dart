import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_categories_cubit.dart';
import '../../../application/admin/admin_products_cubit.dart';
import '../../../application/admin/admin_product_options_cubit.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_option.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/product_image.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;
  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameArController;
  late final TextEditingController _nameController;
  late final TextEditingController _descArController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  String? _selectedCategoryId;
  bool _isAvailable = true;
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameArController = TextEditingController(text: p?.nameAr ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _descArController = TextEditingController(text: p?.descriptionAr ?? '');
    _priceController = TextEditingController(
      text: p?.price.toStringAsFixed(0) ?? '',
    );
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _selectedCategoryId = p?.categoryId;
    _isAvailable = p?.isAvailable ?? true;

    _imageUrlController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameController.dispose();
    _descArController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
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
        'description_ar': _descArController.text.trim().isEmpty
            ? null
            : _descArController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'image_url': _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        'category_id': _selectedCategoryId,
        'is_available': _isAvailable,
        'sort_order': 0,
      };

      await context
          .read<AdminProductsCubit>()
          .upsert(data, id: _isEditing ? widget.product!.id : null);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'تم التعديل بنجاح' : 'تم الإضافة بنجاح',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حصل خطأ، حاول تاني'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = _imageUrlController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الصنف' : 'صنف جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.divider),
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: ProductImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary)),
                        errorWidget: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image_outlined,
                                size: 48, color: AppColors.grey400),
                            AppSpacing.gapH8,
                            Text(
                              'الصورة مش شغالة',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_outlined,
                            size: 48, color: AppColors.grey300),
                        AppSpacing.gapH8,
                        Text(
                          'صورة الصنف',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
            ),
            AppSpacing.gapH16,
            _SectionCard(
              icon: Icons.link,
              title: 'رابط الصورة',
              child: TextFormField(
                controller: _imageUrlController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: const Icon(Icons.image_outlined, size: 20),
                  suffixIcon: imageUrl.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _imageUrlController.clear();
                          },
                        )
                      : null,
                ),
              ),
            ),
            AppSpacing.gapH12,
            _SectionCard(
              icon: Icons.restaurant,
              title: 'اسم الصنف',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameArController,
                    decoration: const InputDecoration(
                      hintText: 'اسم الصنف بالعربي *',
                      prefixIcon: Icon(Icons.language, size: 20),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                  ),
                  AppSpacing.gapH12,
                  TextFormField(
                    controller: _nameController,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      hintText: 'اسم الصنف بالإنجليزي (اختياري)',
                      prefixIcon: Icon(Icons.translate, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH12,
            _SectionCard(
              icon: Icons.category_outlined,
              title: 'الفئة والسعر',
              child: Column(
                children: [
                  BlocBuilder<AdminCategoriesCubit, AdminCategoriesState>(
                    builder: (context, state) {
                      if (state.status == AdminCategoriesStatus.loaded) {
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedCategoryId,
                          decoration: const InputDecoration(
                            hintText: 'اختر فئة',
                            prefixIcon: Icon(Icons.folder_outlined, size: 20),
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('بدون فئة')),
                            ...state.categories.map(
                              (c) => DropdownMenuItem(
                                  value: c.id, child: Text(c.nameAr)),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() => _selectedCategoryId = v);
                          },
                        );
                      }
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(16),
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      ));
                    },
                  ),
                  AppSpacing.gapH12,
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      hintText: '0',
                      prefixIcon: Icon(Icons.attach_money, size: 20),
                      suffixText: 'جنيه',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'أدخل السعر';
                      if (double.tryParse(v) == null) return 'رقم غير صحيح';
                      if (double.parse(v) <= 0) return 'السعر أكبر من صفر';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.gapH12,
            _SectionCard(
              icon: Icons.description_outlined,
              title: 'الوصف',
              child: TextFormField(
                controller: _descArController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'وصف الصنف...',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            AppSpacing.gapH12,
            if (_isEditing) ...[
              _SectionCard(
                icon: Icons.tune,
                title: 'خيارات إضافية',
                child: BlocBuilder<AdminProductOptionsCubit,
                    AdminProductOptionsState>(
                  builder: (context, state) {
                    final options = state.options;
                    return Column(
                      children: [
                        if (state.status == AdminProductOptionsStatus.loading)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          ),
                        ...options.map((opt) => _OptionTile(
                              option: opt,
                              onDelete: () async {
                                final cubit =
                                    context.read<AdminProductOptionsCubit>();
                                await cubit.delete(opt.id);
                                if (!context.mounted) return;
                                cubit.loadByProductId(widget.product!.id);
                              },
                            )),
                        AppSpacing.gapH8,
                        _AddOptionField(
                          onAdd: (name, nameAr, priceDelta) async {
                            final cubit =
                                context.read<AdminProductOptionsCubit>();
                            await cubit.upsert({
                              'product_id': widget.product!.id,
                              'name': name,
                              'name_ar': nameAr,
                              'price_delta': priceDelta,
                              'sort_order': options.length,
                            });
                            if (!context.mounted) return;
                            cubit.loadByProductId(widget.product!.id);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            AppSpacing.gapH12,
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isAvailable
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      _isAvailable
                          ? Icons.check_circle_outline
                          : Icons.unpublished_outlined,
                      color: _isAvailable ? AppColors.success : AppColors.error,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAvailable ? 'متاح للطلب' : 'غير متاح',
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          _isAvailable
                              ? 'الصنف ظاهر للزبائن'
                              : 'الصنف مخفي عن الزبائن',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isAvailable,
                    activeTrackColor: AppColors.primary,
                    onChanged: (v) {
                      setState(() => _isAvailable = v);
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.gapH24,
            LoadingButton(
              onPressed: _save,
              label: _isEditing ? 'حفظ التعديلات' : 'إضافة الصنف',
              isLoading: _isLoading,
            ),
            AppSpacing.gapH32,
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final ProductOption option;
  final VoidCallback onDelete;

  const _OptionTile({required this.option, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option.nameAr != null
                  ? '${option.nameAr} (${option.name})'
                  : option.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (option.priceDelta > 0)
            Text(
              '+${option.priceDelta.toInt()} ج',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          AppSpacing.gapW8,
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 18, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _AddOptionField extends StatefulWidget {
  final void Function(String name, String nameAr, double priceDelta) onAdd;

  const _AddOptionField({required this.onAdd});

  @override
  State<_AddOptionField> createState() => _AddOptionFieldState();
}

class _AddOptionFieldState extends State<_AddOptionField> {
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final priceDelta = double.tryParse(_priceController.text) ?? 0;
    widget.onAdd(name, _nameArController.text.trim(), priceDelta);
    _nameController.clear();
    _nameArController.clear();
    _priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'اسم الخيار',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
        AppSpacing.gapW8,
        Expanded(
          child: TextField(
            controller: _nameArController,
            decoration: const InputDecoration(
              hintText: 'عربي',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
        AppSpacing.gapW8,
        SizedBox(
          width: 60,
          child: TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'سعر',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
        AppSpacing.gapW8,
        IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.primary),
          onPressed: _submit,
          iconSize: 28,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              AppSpacing.gapW8,
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          child,
        ],
      ),
    );
  }
}
