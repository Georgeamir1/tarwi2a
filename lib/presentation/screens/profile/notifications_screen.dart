import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/notifications/notifications_cubit.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../domain/entities/app_notification.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final auth = context.read<AuthCubit>().state;
    if (auth is! Authenticated) return;
    context.read<NotificationsCubit>().loadNotifications(auth.profile.id);
    sl<PushNotificationService>().clearBadge();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppTopBar(
            title: 'الإشعارات',
            variant: TopBarVariant.withBack,
            actions: [
              if (state.notifications.isNotEmpty && state.unreadCount > 0)
                TextButton(
                  onPressed: () {
                    final auth = context.read<AuthCubit>().state;
                    if (auth is Authenticated) {
                      context
                          .read<NotificationsCubit>()
                          .markAllAsRead(auth.profile.id);
                    }
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
            NotificationsStatus.loaded => state.notifications.isEmpty
                ? const EmptyState(
                    icon: Icons.notifications_none_outlined,
                    title: 'مفيش إشعارات',
                    subtitle: 'هتلاقي هنا كل التحديثات الجديدة',
                  )
                : RefreshIndicator(
                    onRefresh: () async => _load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.notifications.length,
                      itemBuilder: (context, i) {
                        final n = state.notifications[i];
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
      context.push('/orders?expand=${n.referenceId}');
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
