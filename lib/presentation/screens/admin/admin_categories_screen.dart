import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_categories_cubit.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'إدارة الأقسام',
        variant: TopBarVariant.withBack,
        actions: [
          IconButton(
            onPressed: () => _showCategoryDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocBuilder<AdminCategoriesCubit, AdminCategoriesState>(
        builder: (context, state) {
          if (state.status == AdminCategoriesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.categories.isEmpty) {
            return const Center(
              child: EmptyState(
                icon: Icons.category_outlined,
                title: 'لا توجد أقسام',
                subtitle: 'أضف أول قسم للمطعم',
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.categories.length,
            itemBuilder: (_, index) {
              final cat = state.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: const Icon(Icons.category, color: AppColors.primary),
                  ),
                  title: Text(cat.nameAr),
                  subtitle: Text(cat.name),
                  trailing: Switch(
                    value: cat.isActive,
                    onChanged: (v) {
                      context
                          .read<AdminCategoriesCubit>()
                          .toggleActive(cat.id, v);
                    },
                    activeTrackColor: AppColors.primary,
                  ),
                  onTap: () => _showCategoryDialog(context, category: cat),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {dynamic category}) {
    final nameController =
        TextEditingController(text: category?.name ?? '');
    final nameArController =
        TextEditingController(text: category?.nameAr ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(category != null ? 'تعديل قسم' : 'قسم جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'الاسم بالإنجليزية'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameArController,
              decoration: const InputDecoration(labelText: 'الاسم بالعربية'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final data = {
                'name': nameController.text.trim(),
                'name_ar': nameArController.text.trim(),
                if (category == null) 'sort_order': 0,
              };
              context.read<AdminCategoriesCubit>().upsert(
                    data,
                    id: category?.id,
                  );
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
