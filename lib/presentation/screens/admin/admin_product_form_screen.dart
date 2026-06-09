import 'dart:ui';
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
import '../../widgets/app_top_bar.dart';
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

    // Load options for existing product
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<AdminProductOptionsCubit>()
            .loadByProductId(widget.product!.id);
      });
    }

    // Track unsaved changes
    for (final c in [
      _nameArController,
      _nameController,
      _descArController,
      _descController,
      _priceController,
      _prepTimeController,
      _caloriesController,
      _sortOrderController,
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
        title: const Text(
          'تجاهل التعديلات؟',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'لديك تعديلات غير محفوظة. هل تريد تجاهلها والخروج؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'متابعة التعديل',
              style:
                  TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text(
              'تجاهل',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
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
      final uploadResult = await ImageUploadService().uploadImage(result.file!);
      if (!mounted) return;
      uploadResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message,
                  style: const TextStyle(fontFamily: 'Cairo')),
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
              Text(
                _isEditing
                    ? 'تم حفظ التعديلات بنجاح ✓'
                    : 'تم إضافة الصنف بنجاح ✓',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
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
          content:
              Text('حصل خطأ، حاول ثاني', style: TextStyle(fontFamily: 'Cairo')),
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
        title: const Text(
          'حذف الصنف',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${widget.product!.nameAr}"؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'إلغاء',
              style:
                  TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<AdminProductsCubit>().deleteProduct(widget.product!.id);
    if (!mounted) return;
    _hasUnsavedChanges = false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text('تم حذف الصنف بنجاح',
                style: TextStyle(fontFamily: 'Cairo')),
          ],
        ),
        backgroundColor: AppColors.statusCancelled,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text('تم نسخ الصنف بنجاح بنسخة غير مفعلة',
                style: TextStyle(fontFamily: 'Cairo')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    context.pop();
  }

  InputDecoration _getInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffix,
    String? suffixText,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffix,
      suffixText: suffixText,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'Cairo',
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'Cairo',
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      suffixStyle: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
    );
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
        appBar: AppTopBar(
          title: _isEditing ? 'تعديل الصنف' : 'صنف جديد',
          variant: TopBarVariant.withBack,
          onBack: () async {
            if (_hasUnsavedChanges) {
              final shouldPop = await _onWillPop();
              if (!shouldPop || !context.mounted) return;
            }
            if (context.mounted) context.pop();
          },
          actions: [
            if (_isEditing) ...[
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'نسخ الصنف',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _duplicateProduct();
                },
              ),
            ],
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // ── Image Section ──
              _buildImageSection(),
              const SizedBox(height: 20),

              // ── Name Section ──
              _SectionCard(
                icon: Icons.restaurant_rounded,
                title: 'اسم الصنف',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameArController,
                      decoration: _getInputDecoration(
                        labelText: 'اسم الصنف بالعربي *',
                        hintText: 'مثال: شاورما دجاج دبل',
                        prefixIcon: const Icon(Icons.edit_rounded, size: 20),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'اسم الصنف بالعربي مطلوب'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      textDirection: TextDirection.ltr,
                      decoration: _getInputDecoration(
                        labelText: 'Product Name (English)',
                        hintText: 'e.g. Double Chicken Shawarma',
                        prefixIcon:
                            const Icon(Icons.translate_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                            decoration: _getInputDecoration(
                              labelText: 'الفئة',
                              prefixIcon:
                                  const Icon(Icons.folder_rounded, size: 20),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('بدون فئة',
                                    style: TextStyle(fontFamily: 'Cairo')),
                              ),
                              ...state.categories.map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.nameAr,
                                      style:
                                          const TextStyle(fontFamily: 'Cairo')),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              HapticFeedback.lightImpact();
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
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            textDirection: TextDirection.ltr,
                            decoration: _getInputDecoration(
                              labelText: 'السعر بالريال *',
                              hintText: '0',
                              prefixIcon:
                                  const Icon(Icons.payments_rounded, size: 20),
                              suffixText: 'ر.س',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d.]')),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'مطلوب';
                              if (double.tryParse(v) == null) {
                                return 'رقم غير صحيح';
                              }
                              if (double.parse(v) <= 0) {
                                return 'يجب أن يكون أكبر من 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _sortOrderController,
                            keyboardType: TextInputType.number,
                            textDirection: TextDirection.ltr,
                            decoration: _getInputDecoration(
                              labelText: 'الترتيب',
                              hintText: '0',
                              prefixIcon:
                                  const Icon(Icons.sort_rounded, size: 20),
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
              const SizedBox(height: 16),

              // ── Description Section ──
              _SectionCard(
                icon: Icons.description_rounded,
                title: 'الوصف والتفاصيل',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _descArController,
                      maxLines: 3,
                      decoration: _getInputDecoration(
                        labelText: 'وصف الصنف بالعربي',
                        hintText:
                            'مثال: قطع دجاج متبلة بالثوم مع بطاطس مقرمشة مجهزة طازجة يومياً...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      textDirection: TextDirection.ltr,
                      decoration: _getInputDecoration(
                        labelText: 'Description (English)',
                        hintText:
                            'e.g. Marinated chicken strips with fresh garlic sauce and crispy fries...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Kitchen Details ──
              _SectionCard(
                icon: Icons.kitchen_rounded,
                title: 'تفاصيل المطبخ والتحضير',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prepTimeController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        decoration: _getInputDecoration(
                          labelText: 'وقت التحضير',
                          hintText: '30',
                          prefixIcon: const Icon(Icons.timer_rounded, size: 20),
                          suffixText: 'دقيقة',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        decoration: _getInputDecoration(
                          labelText: 'السعرات',
                          hintText: '350',
                          prefixIcon: const Icon(
                            Icons.local_fire_department_rounded,
                            size: 20,
                          ),
                          suffixText: 'سعرة',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Tags Section ──
              _SectionCard(
                icon: Icons.label_rounded,
                title: 'شارات الصنف التوضيحية',
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
              const SizedBox(height: 16),

              // ── Options Section ──
              if (_isEditing) ...[
                _buildOptionsSection(),
                const SizedBox(height: 16),
              ],

              // ── Availability Toggle ──
              _buildAvailabilityToggle(),
              const SizedBox(height: 16),

              // ── Show In Banner Toggle ──
              _buildShowInBannerToggle(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActionBar(),
      ),
    );
  }

  // ── Image Section ──
  Widget _buildImageSection() {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _isUploading ? null : _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: _isUploading
            ? Container(
                color: theme.colorScheme.surfaceContainerLow,
                child: Column(
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Cairo',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
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
                      // Glassmorphic Overlay actions
                      Positioned(
                        top: 12,
                        right: 12,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _GlassIconButton(
                                    icon: Icons.edit_rounded,
                                    tooltip: 'تغيير الصورة',
                                    onTap: _pickImage,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 20,
                                    color: Colors.white.withValues(alpha: 0.2),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                  ),
                                  _GlassIconButton(
                                    icon: Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                    tooltip: 'حذف الصورة',
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
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
                        ),
                      ),
                    ],
                  )
                : CustomPaint(
                    painter: _DashedBorderPainter(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      radius: AppRadius.xl,
                    ),
                    child: Container(
                      color: theme.colorScheme.surfaceContainerLow,
                      child: _buildImagePlaceholder(),
                    ),
                  ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(
            Icons.add_photo_alternate_rounded,
            size: 28,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'اضغط لإضافة صورة الصنف',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'كاميرا • معرض الصور • رابط مباشر',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  // ── Options Section ──
  Widget _buildOptionsSection() {
    final theme = Theme.of(context);
    return _SectionCard(
      icon: Icons.tune_rounded,
      title: 'الخيارات الإضافية والمعدّلات',
      trailing: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _addOption();
        },
        icon: const Icon(Icons.add_circle_rounded,
            color: AppColors.primary, size: 28),
        tooltip: 'إضافة خيار جديد',
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
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
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 40,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد خيارات إضافية لهذا الصنف بعد',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'يمكنك إضافة خيارات مثل: الحجم، الإضافات، الصوصات',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'Cairo',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: options
                .map((opt) => _OptionCard(
                      option: opt,
                      onEdit: () => _editOption(opt),
                      onDelete: () => _deleteOption(opt),
                    ))
                .toList(),
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
        title: const Text('حذف الخيار',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: Text(
          'هل أنت متأكد من حذف الخيار "${option.nameAr ?? option.name}"؟',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء',
                style: TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text('حذف',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _isAvailable
              ? AppColors.success.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.15),
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isAvailable
                      ? 'الصنف ظاهر للزبائن في قائمة الطعام ويمكنهم طلبه'
                      : 'الصنف مخفي عن قائمة الطعام ولا يمكن طلبه حالياً',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            key: const Key('product_available_switch'),
            value: _isAvailable,
            onChanged: (v) {
              HapticFeedback.lightImpact();
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _showInBanner
              ? AppColors.tertiary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _showInBanner
                  ? AppColors.tertiary.withValues(alpha: 0.1)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.view_carousel_rounded,
              color: _showInBanner
                  ? AppColors.tertiary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _showInBanner
                      ? 'يظهر هذا الصنف في البانر المميز أعلى الصفحة الرئيسية للزبائن'
                      : 'لا يظهر هذا الصنف في البانر المتحرك العلوي',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            key: const Key('product_banner_switch'),
            value: _showInBanner,
            activeTrackColor: AppColors.tertiary,
            onChanged: (v) {
              HapticFeedback.lightImpact();
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

  // ── Bottom Action Bar ──
  Widget? _buildBottomActionBar() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_isEditing) ...[
            Container(
              height: 52,
              width: 52,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_forever_rounded,
                    color: AppColors.error),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _deleteProduct();
                },
                tooltip: 'حذف الصنف',
              ),
            ),
          ],
          Expanded(
            child: LoadingButton(
              onPressed: _save,
              label: _isEditing ? 'حفظ التعديلات' : 'إضافة الصنف',
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glass Icon Button ──
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String tooltip;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 20,
            ),
          ),
        ),
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
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.tune_rounded,
                size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.nameAr ?? option.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
                if (option.nameAr != null && option.name.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    option.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (option.isRequired) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusPending.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'إجباري',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.statusPending,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (option.priceDelta > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '+${option.priceDelta.toInt()} ر.س',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onEdit();
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                tooltip: 'تعديل',
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onDelete();
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: AppColors.error,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                tooltip: 'حذف',
              ),
            ],
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
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const Divider(height: 24, thickness: 1),
          child,
        ],
      ),
    );
  }
}

// ── Dashed Border Painter ──
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  double get strokeWidth => 1.5;
  double get gap => 4.0;
  double get dashLength => 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth,
          size.height - strokeWidth),
      Radius.circular(radius),
    ));

    final dashedPath = Path();
    var distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.radius != radius;
  }
}
