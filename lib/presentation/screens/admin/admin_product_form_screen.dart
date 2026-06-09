import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_categories_cubit.dart';
import '../../../application/admin/admin_products_cubit.dart';
import '../../../application/admin/admin_product_options_cubit.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_option.dart';
import '../../widgets/image_picker_sheet.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/option_form_sheet.dart';
import '../../widgets/product_image.dart';
import '../../widgets/tag_selector.dart';

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
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _sortOrderController;
  String? _imageUrl;
  String? _selectedCategoryId;
  bool _isAvailable = true;
  bool _showInBanner = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _hasUnsavedChanges = false;
  List<String> _selectedTags = [];

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameArController = TextEditingController(text: p?.nameAr ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _descArController = TextEditingController(text: p?.descriptionAr ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(0) : '',
    );
    _prepTimeController = TextEditingController(
      text: p?.preparationTime?.toString() ?? '',
    );
    _caloriesController = TextEditingController(
      text: p?.calories?.toString() ?? '',
    );
    _sortOrderController = TextEditingController(
      text: p?.sortOrder.toString() ?? '0',
    );
    _imageUrl = p?.imageUrl;
    _selectedCategoryId = p?.categoryId;
    _isAvailable = p?.isAvailable ?? true;
    _showInBanner = p?.showInBanner ?? false;
    _selectedTags = List<String>.from(p?.tags ?? []);

    // Track unsaved changes
    for (final c in [
      _nameArController,
      _nameController,
      _descArController,
      _descController,
      _priceController,
      _prepTimeController,
      _caloriesController,
    ]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameController.dispose();
    _descArController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _prepTimeController.dispose();
    _caloriesController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تجاهل التعديلات؟'),
        content: const Text('عندك تعديلات مش محفوظة. هتخسرها لو رجعت.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('متابعة التعديل'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('تجاهل'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _pickImage() async {
    final result = await ImagePickerSheet.show(context);
    if (result == null || result.isEmpty) return;

    if (result.hasUrl) {
      setState(() {
        _imageUrl = result.url;
        _hasUnsavedChanges = true;
      });
      return;
    }

    if (result.hasFile) {
      setState(() => _isUploading = true);
      final uploadResult =
          await ImageUploadService().uploadImage(result.file!);
      if (!mounted) return;
      uploadResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (url) {
          setState(() {
            _imageUrl = url;
            _hasUnsavedChanges = true;
          });
        },
      );
      setState(() => _isUploading = false);
    }
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
        'description': _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'image_url': _imageUrl,
        'category_id': _selectedCategoryId,
        'is_available': _isAvailable,
        'show_in_banner': _showInBanner,
        'sort_order': int.tryParse(_sortOrderController.text.trim()) ?? 0,
        'preparation_time': _prepTimeController.text.trim().isEmpty
            ? null
            : int.tryParse(_prepTimeController.text.trim()),
        'calories': _caloriesController.text.trim().isEmpty
            ? null
            : int.tryParse(_caloriesController.text.trim()),
        'tags': _selectedTags,
      };

      await context
          .read<AdminProductsCubit>()
          .upsert(data, id: _isEditing ? widget.product!.id : null);

      if (!mounted) return;

      _hasUnsavedChanges = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(_isEditing ? 'تم التعديل بنجاح ✓' : 'تم الإضافة بنجاح ✓'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_forever_rounded,
            color: AppColors.error, size: 48),
        title: const Text('حذف الصنف'),
        content: Text(
          'هل أنت متأكد من حذف "${widget.product!.nameAr}"؟\nلا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<AdminProductsCubit>().deleteProduct(widget.product!.id);
    if (!mounted) return;
    _hasUnsavedChanges = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف الصنف'),
        backgroundColor: AppColors.statusCancelled,
      ),
    );
    context.pop();
  }

  Future<void> _duplicateProduct() async {
    if (widget.product == null) return;
    final p = widget.product!;
    final data = {
      'name_ar': '${p.nameAr} (نسخة)',
      'name': '${p.name} (copy)',
      'description_ar': p.descriptionAr,
      'description': p.description,
      'price': p.price,
      'image_url': p.imageUrl,
      'category_id': p.categoryId,
      'is_available': false,
      'show_in_banner': p.showInBanner,
      'sort_order': p.sortOrder + 1,
      'preparation_time': p.preparationTime,
      'calories': p.calories,
      'tags': p.tags,
    };

    await context.read<AdminProductsCubit>().upsert(data);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الصنف بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'تعديل الصنف' : 'صنف جديد'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () async {
              if (_hasUnsavedChanges) {
                final shouldPop = await _onWillPop();
                if (!shouldPop || !context.mounted) return;
              }
              if (context.mounted) context.pop();
            },
          ),
          actions: [
            if (_isEditing) ...[
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'نسخ الصنف',
                onPressed: _duplicateProduct,
              ),
            ],
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // ── Image Section ──
              _buildImageSection(),
              const SizedBox(height: 16),

              // ── Name Section ──
              _SectionCard(
                icon: Icons.restaurant_rounded,
                title: 'اسم الصنف',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameArController,
                      decoration: const InputDecoration(
                        hintText: 'اسم الصنف بالعربي *',
                        prefixIcon: Icon(Icons.edit_rounded, size: 20),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        hintText: 'Product name in English (optional)',
                        prefixIcon: Icon(Icons.translate_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Category & Price ──
              _SectionCard(
                icon: Icons.category_rounded,
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
                              prefixIcon:
                                  Icon(Icons.folder_rounded, size: 20),
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
                              setState(() {
                                _selectedCategoryId = v;
                                _hasUnsavedChanges = true;
                              });
                            },
                          );
                        }
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              hintText: '0',
                              prefixIcon:
                                  Icon(Icons.payments_rounded, size: 20),
                              suffixText: 'ر.س',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d.]')),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'أدخل السعر';
                              if (double.tryParse(v) == null) {
                                return 'رقم غير صحيح';
                              }
                              if (double.parse(v) <= 0) {
                                return 'السعر أكبر من صفر';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _sortOrderController,
                            keyboardType: TextInputType.number,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              hintText: '0',
                              prefixIcon:
                                  Icon(Icons.sort_rounded, size: 20),
                              labelText: 'الترتيب',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Description Section ──
              _SectionCard(
                icon: Icons.description_rounded,
                title: 'الوصف',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _descArController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'وصف الصنف بالعربي...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        hintText: 'Description in English (optional)...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Kitchen Details ──
              _SectionCard(
                icon: Icons.kitchen_rounded,
                title: 'تفاصيل المطبخ',
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prepTimeController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          hintText: '30',
                          prefixIcon: Icon(Icons.timer_rounded, size: 20),
                          suffixText: 'دقيقة',
                          labelText: 'وقت التحضير',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          hintText: '350',
                          prefixIcon: Icon(
                            Icons.local_fire_department_rounded,
                            size: 20,
                          ),
                          suffixText: 'سعرة',
                          labelText: 'السعرات',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Tags Section ──
              _SectionCard(
                icon: Icons.label_rounded,
                title: 'الشارات',
                child: TagSelector(
                  selectedTags: _selectedTags,
                  onChanged: (tags) {
                    setState(() {
                      _selectedTags = tags;
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              // ── Options Section ──
              if (_isEditing) ...[
                _buildOptionsSection(),
                const SizedBox(height: 12),
              ],

              // ── Availability Toggle ──
              _buildAvailabilityToggle(),
              const SizedBox(height: 12),

              // ── Show In Banner Toggle ──
              _buildShowInBannerToggle(),
              const SizedBox(height: 24),

              // ── Save Button ──
              LoadingButton(
                onPressed: _save,
                label: _isEditing ? 'حفظ التعديلات' : 'إضافة الصنف',
                isLoading: _isLoading,
              ),

              // ── Delete Button (edit mode only) ──
              if (_isEditing) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _deleteProduct,
                  icon: const Icon(Icons.delete_forever_rounded,
                      color: AppColors.error),
                  label: const Text('حذف الصنف'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Image Section ──
  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _isUploading ? null : _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: _imageUrl != null
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.outlineVariant,
            width: _imageUrl != null ? 2 : 1,
          ),
          boxShadow: _imageUrl != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: _isUploading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'جاري رفع الصورة...',
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : _imageUrl != null && _imageUrl!.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ProductImage(
                        imageUrl: _imageUrl,
                        fit: BoxFit.cover,
                        placeholder: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                        errorWidget: _buildImagePlaceholder(),
                      ),
                      // Overlay actions
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ImageActionButton(
                                icon: Icons.edit_rounded,
                                label: 'تغيير',
                                onTap: _pickImage,
                              ),
                              const SizedBox(width: 16),
                              _ImageActionButton(
                                icon: Icons.delete_outline_rounded,
                                label: 'حذف',
                                onTap: () {
                                  setState(() {
                                    _imageUrl = null;
                                    _hasUnsavedChanges = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(
            Icons.add_photo_alternate_rounded,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'اضغط لإضافة صورة',
          style: AppTypography.callout.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'كاميرا • معرض الصور • رابط',
          style: AppTypography.footnote.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Options Section ──
  Widget _buildOptionsSection() {
    return _SectionCard(
      icon: Icons.tune_rounded,
      title: 'الخيارات الإضافية',
      trailing: IconButton(
        onPressed: () => _addOption(),
        icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
        tooltip: 'إضافة خيار',
      ),
      child: BlocBuilder<AdminProductOptionsCubit, AdminProductOptionsState>(
        builder: (context, state) {
          if (state.status == AdminProductOptionsStatus.loading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final options = state.options;

          if (options.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.add_box_outlined,
                    size: 36,
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لا توجد خيارات بعد',
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مثل: حجم كبير، إضافة جبن',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: options.map((opt) => _OptionCard(
              option: opt,
              onEdit: () => _editOption(opt),
              onDelete: () => _deleteOption(opt),
            )).toList(),
          );
        },
      ),
    );
  }

  Future<void> _addOption() async {
    final data = await OptionFormSheet.show(context);
    if (data == null || !mounted) return;

    final cubit = context.read<AdminProductOptionsCubit>();
    final options = cubit.state.options;

    await cubit.upsert({
      ...data,
      'product_id': widget.product!.id,
      'sort_order': options.length,
    });
    if (!mounted) return;
    cubit.loadByProductId(widget.product!.id);
  }

  Future<void> _editOption(ProductOption option) async {
    final data = await OptionFormSheet.show(context, option: option);
    if (data == null || !mounted) return;

    final cubit = context.read<AdminProductOptionsCubit>();
    await cubit.upsert(data, id: option.id);
    if (!mounted) return;
    cubit.loadByProductId(widget.product!.id);
  }

  Future<void> _deleteOption(ProductOption option) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الخيار'),
        content: Text('حذف "${option.nameAr ?? option.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final cubit = context.read<AdminProductOptionsCubit>();
    await cubit.delete(option.id);
    if (!mounted) return;
    cubit.loadByProductId(widget.product!.id);
  }

  // ── Availability Toggle ──
  Widget _buildAvailabilityToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _isAvailable
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.outlineVariant,
        ),
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
                  ? Icons.check_circle_rounded
                  : Icons.unpublished_rounded,
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
                  style: AppTypography.callout.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isAvailable
                      ? 'الصنف ظاهر للزبائن'
                      : 'الصنف مخفي عن الزبائن',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isAvailable,
            onChanged: (v) {
              setState(() {
                _isAvailable = v;
                _hasUnsavedChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  // ── Show In Banner Toggle ──
  Widget _buildShowInBannerToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _showInBanner
              ? AppColors.tertiary.withValues(alpha: 0.3)
              : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _showInBanner
                  ? AppColors.tertiary.withValues(alpha: 0.1)
                  : AppColors.textMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.view_carousel_rounded,
              color: _showInBanner ? AppColors.tertiary : AppColors.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عرض في البانر المتحرك',
                  style: AppTypography.callout.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _showInBanner
                      ? 'يظهر هذا الصنف في البانر المتحرك أعلى الصفحة الرئيسية'
                      : 'لا يظهر هذا الصنف في البانر المتحرك',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _showInBanner,
            activeTrackColor: AppColors.tertiary,
            onChanged: (v) {
              setState(() {
                _showInBanner = v;
                _hasUnsavedChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }
}

// ── Option Card ──
class _OptionCard extends StatelessWidget {
  final ProductOption option;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OptionCard({
    required this.option,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.tune_rounded,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.nameAr ?? option.name,
                  style: AppTypography.callout.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (option.nameAr != null)
                  Text(
                    option.name,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (option.priceDelta > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '+${option.priceDelta.toInt()} ر.س',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 4),
          if (option.isRequired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'إجباري',
                style: AppTypography.caption.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 18),
            color: AppColors.textSecondary,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: AppColors.error,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

// ── Image Action Button ──
class _ImageActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.callout.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
