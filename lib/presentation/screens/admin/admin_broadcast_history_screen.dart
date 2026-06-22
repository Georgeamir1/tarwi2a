import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_broadcast_cubit.dart';
import '../../../domain/entities/broadcast_log.dart';
import '../../extensions/notification_type_x.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class AdminBroadcastHistoryScreen extends StatefulWidget {
  const AdminBroadcastHistoryScreen({super.key});

  @override
  State<AdminBroadcastHistoryScreen> createState() =>
      _AdminBroadcastHistoryScreenState();
}

class _AdminBroadcastHistoryScreenState
    extends State<AdminBroadcastHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBroadcastCubit>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBroadcastCubit, AdminBroadcastState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppTopBar(
            title: 'سجل الإشعارات',
            variant: TopBarVariant.withBack,
          ),
          body: switch (state.status) {
            AdminBroadcastStatus.initial ||
            AdminBroadcastStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            AdminBroadcastStatus.error => _ErrorView(
                message: state.failure?.message ?? 'حصل خطأ',
                onRetry: () =>
                    context.read<AdminBroadcastCubit>().loadHistory(),
              ),
            _ => state.history.isEmpty
                ? const EmptyState(
                    icon: Icons.history_outlined,
                    title: 'مفيش إشعارات سابقة',
                    subtitle: 'الإشعارات اللي هتبعت هتظهر هنا',
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        context.read<AdminBroadcastCubit>().loadHistory(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: state.history.length,
                      itemBuilder: (context, i) {
                        return _BroadcastLogCard(log: state.history[i]);
                      },
                    ),
                  ),
          },
        );
      },
    );
  }
}

class _BroadcastLogCard extends StatelessWidget {
  final BroadcastLog log;
  const _BroadcastLogCard({required this.log});

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final deliveryRate =
        log.recipientCount == 0 ? 0.0 : log.sentCount / log.recipientCount;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(log.type.icon, color: log.type.color, size: 20),
              AppSpacing.gapW8,
              Expanded(
                child: Text(
                  log.titleAr,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                log.targetType.arabicLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          AppSpacing.gapH8,
          Text(
            log.bodyAr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.gapH12,
          Row(
            children: [
              _StatChip(
                icon: Icons.send_outlined,
                label: '${log.sentCount}/${log.recipientCount} مُرسلة',
              ),
              AppSpacing.gapW8,
              _StatChip(
                icon: Icons.error_outline,
                label: '${log.skippedCount} تخطي',
                color: log.skippedCount > 0
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ],
          ),
          AppSpacing.gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(log.createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              if (log.recipientCount > 0)
                Text(
                  '${(deliveryRate * 100).toStringAsFixed(0)}% تسليم',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _StatChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color ?? AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: const Text('حاول تاني')),
        ],
      ),
    );
  }
}
