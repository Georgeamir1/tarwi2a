import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/notifications/notifications_cubit.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../domain/entities/app_notification.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/notification_tile.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final auth = context.read<AuthCubit>().state;
    if (auth is Authenticated) {
      context.read<NotificationsCubit>().loadNotifications(auth.profile.id);
    }
    context.read<PushNotificationService>().clearBadge();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final adminNotifications = state.notifications
            .where((n) => n.type.isAdminNotification || n.type.isOrderUpdate)
            .toList();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppTopBar(
            title: 'إشعارات الإدارة',
            variant: TopBarVariant.withBack,
            actions: [
              if (adminNotifications.isNotEmpty && state.unreadCount > 0)
                TextButton(
                  onPressed: () {
                    final unreadIds = adminNotifications
                        .where((n) => !n.isRead)
                        .map((n) => n.id)
                        .toList();
                    context.read<NotificationsCubit>().markIdsAsRead(unreadIds);
                  },
                  child: const Text('تمييز الكل'),
                ),
            ],
          ),
          body: switch (state.status) {
            NotificationsStatus.initial ||
            NotificationsStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            NotificationsStatus.error => _ErrorView(
                message: state.failure?.message ?? 'حصل خطأ',
                onRetry: _load,
              ),
            NotificationsStatus.loaded => adminNotifications.isEmpty
                ? const EmptyState(
                    icon: Icons.notifications_none_outlined,
                    title: 'مفيش إشعارات',
                    subtitle: 'الإشعارات الخاصة بالطلبات الجديدة والإلغاءات',
                  )
                : RefreshIndicator(
                    onRefresh: () async => _load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: adminNotifications.length,
                      itemBuilder: (context, i) {
                        final n = adminNotifications[i];
                        return NotificationTile(
                          notification: n,
                          onTap: () => _onNotificationTap(n),
                        );
                      },
                    ),
                  ),
          },
        );
      },
    );
  }

  void _onNotificationTap(AppNotification n) {
    if (!n.isRead) {
      context.read<NotificationsCubit>().markAsRead(n.id);
    }
    if (n.referenceType == 'order' && n.referenceId != null) {
      context.go('/admin/orders/${n.referenceId}');
    }
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
