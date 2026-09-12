import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              title: 'عناويني',
              variant: TopBarVariant.withBack,
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                HapticFeedback.lightImpact();
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
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      case AddressStatus.loaded:
        if (state.addresses.isEmpty) {
          return Center(
            child: EmptyState(
              icon: Icons.location_on_outlined,
              title: 'مفيش عناوين محفوظة',
              subtitle: 'ضيف عنوان التوصيل بتاعك وسهل على نفسك الشراء',
              actionLabel: 'إضافة عنوان جديد',
              onAction: () async {
                HapticFeedback.lightImpact();
                final result =
                    await context.push<bool>('/profile/addresses/add');
                if (result == true && userId.isNotEmpty) {
                  if (context.mounted) {
                    context.read<AddressCubit>().loadAddresses(userId);
                  }
                }
              },
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          itemCount: state.addresses.length,
          itemBuilder: (context, index) {
            final address = state.addresses[index];
            return _AnimatedAddressCard(
              index: index,
              address: address,
              userId: userId,
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop(address);
              },
              onEdit: () async {
                HapticFeedback.lightImpact();
                final result = await context.push<bool>(
                  '/profile/addresses/add',
                  extra: address,
                );
                if (result == true && userId.isNotEmpty) {
                  if (context.mounted) {
                    context.read<AddressCubit>().loadAddresses(userId);
                  }
                }
              },
              onSetDefault: () {
                HapticFeedback.mediumImpact();
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
              Icon(Icons.error_outline,
                  size: 48, color: AppColors.error.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              Text(
                'حصل خطأ: ${state.failure?.message ?? ''}',
                style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<AddressCubit>().loadAddresses(userId);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('حاول تاني'),
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
              HapticFeedback.mediumImpact();
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

class _AnimatedAddressCard extends StatelessWidget {
  final int index;
  final Address address;
  final String userId;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _AnimatedAddressCard({
    required this.index,
    required this.address,
    required this.userId,
    required this.onTap,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 80)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: _AddressCard(
        address: address,
        userId: userId,
        onTap: onTap,
        onEdit: onEdit,
        onSetDefault: onSetDefault,
        onDelete: onDelete,
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final String userId;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.userId,
    required this.onTap,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Map address label to icon
    IconData typeIcon = Icons.location_on_rounded;
    final labelLower = address.label.trim().toLowerCase();
    if (labelLower == 'البيت' || labelLower == 'home') {
      typeIcon = Icons.home_rounded;
    } else if (labelLower == 'العمل' ||
        labelLower == 'الشغل' ||
        labelLower == 'work') {
      typeIcon = Icons.work_rounded;
    }

    return Dismissible(
      key: Key(address.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف العنوان'),
            content: Text('متأكد إنك عايز تحذف "${address.label}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              'اسحب لحذف العنوان',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(
            color: address.isDefault
                ? AppColors.primary
                : AppColors.outlineVariant,
            width: address.isDefault ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: address.isDefault
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(
                        typeIcon,
                        color: address.isDefault
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  address.label,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (address.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.successContainer,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.full),
                                  ),
                                  child: Text(
                                    'افتراضي',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.successOnContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            address.address,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
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
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (address.building != null &&
                          address.building!.isNotEmpty)
                        _DetailChip(
                            icon: Icons.business,
                            label: 'مبنى ${address.building}'),
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
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note_outlined,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address.notes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (address.deliveryZoneName != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining_outlined,
                          size: 16, color: AppColors.tertiary),
                      const SizedBox(width: 6),
                      Text(
                        'توصيل لـ ${address.deliveryZoneName}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(color: AppColors.outlineVariant),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!address.isDefault)
                      TextButton.icon(
                        onPressed: onSetDefault,
                        icon: const Icon(Icons.star_outline, size: 16),
                        label: const Text('تعيين كافتراضي'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('تعديل'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: AppColors.error,
                          tooltip: 'حذف',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
