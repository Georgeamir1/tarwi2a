import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/address/address_cubit.dart';
import '../../../domain/entities/address.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class MyAddressesScreen extends StatelessWidget {
  const MyAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final userId = authState is Authenticated ? authState.profile.id : '';

    return BlocProvider(
      create: (_) => sl<AddressCubit>()..loadAddresses(userId),
      child: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const AppTopBar(
                title: 'عناويني', variant: TopBarVariant.withBack),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                final result =
                    await context.push<bool>('/profile/addresses/add');
                if (result == true && userId.isNotEmpty) {
                  if (context.mounted) {
                    context.read<AddressCubit>().loadAddresses(userId);
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('عنوان جديد'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            body: _buildBody(context, state, userId),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AddressState state, String userId) {
    switch (state.status) {
      case AddressStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      case AddressStatus.loaded:
        if (state.addresses.isEmpty) {
          return const Center(
            child: EmptyState(
              icon: Icons.location_on_outlined,
              title: 'مفيش عناوين محفوظة',
              subtitle: 'ضيف عنوان التوصيل بتاعك',
              actionLabel: 'إضافة عنوان',
              onAction: null,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: state.addresses.length,
          itemBuilder: (context, index) {
            final address = state.addresses[index];
            return _AddressCard(
              address: address,
              isSelected: false,
              onTap: () => context.pop(address),
              onSetDefault: () {
                context.read<AddressCubit>().setDefault(address.id, userId);
              },
              onDelete: () => _confirmDelete(context, address, userId),
            );
          },
        );
      case AddressStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'حصل خطأ: ${state.failure?.message ?? ''}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<AddressCubit>().loadAddresses(userId),
                child: const Text('حاول تاني'),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _confirmDelete(BuildContext context, Address address, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف العنوان'),
        content: Text('متأكد إنك عايز تحذف "${address.label}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AddressCubit>().deleteAddress(address.id, userId);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.location_on_outlined,
                      color: isSelected ? AppColors.onPrimary : AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                address.label,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (address.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  'افتراضي',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.address,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (address.building != null ||
                  address.floor != null ||
                  address.apartment != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (address.building != null &&
                        address.building!.isNotEmpty)
                      _DetailChip(
                          icon: Icons.business, label: 'عمارة ${address.building}'),
                    if (address.floor != null && address.floor!.isNotEmpty)
                      _DetailChip(
                          icon: Icons.layers, label: 'دور ${address.floor}'),
                    if (address.apartment != null &&
                        address.apartment!.isNotEmpty)
                      _DetailChip(
                          icon: Icons.door_front_door,
                          label: 'شقة ${address.apartment}'),
                  ],
                ),
              ],
              if (address.notes != null && address.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  address.notes!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!address.isDefault)
                    TextButton.icon(
                      onPressed: onSetDefault,
                      icon: const Icon(Icons.star_outline, size: 16),
                      label: const Text('تعيين كافتراضي'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: theme.textTheme.labelMedium,
                      ),
                    ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('حذف'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      textStyle: theme.textTheme.labelMedium,
                    ),
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

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
