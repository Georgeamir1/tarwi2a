import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/notifications/notification_preferences_cubit.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/enums/notification_type.dart';
import '../../extensions/notification_type_x.dart';
import '../../widgets/app_top_bar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final auth = context.read<AuthCubit>().state;
    if (auth is! Authenticated) return;
    _userId = auth.profile.id;
    context.read<NotificationPreferencesCubit>().loadPreferences(_userId!);
  }

  Future<void> _onPushEnabledChanged(bool value) async {
    if (_userId == null) return;
    final service = sl<PushNotificationService>();
    if (value) {
      final granted = await service.requestPermissionWithPriming(context);
      if (!granted) return;
      await service.registerTokenForCurrentUser(userIdOverride: _userId);
    } else {
      await service.unregisterCurrentToken();
    }
    if (!mounted) return;
    context
        .read<NotificationPreferencesCubit>()
        .updatePreference(userId: _userId!, pushEnabled: value);
  }

  void _onOrderUpdatesChanged(bool value) {
    if (_userId == null) return;
    context
        .read<NotificationPreferencesCubit>()
        .updatePreference(userId: _userId!, orderUpdates: value);
  }

  void _onPromotionsChanged(bool value) {
    if (_userId == null) return;
    context
        .read<NotificationPreferencesCubit>()
        .updatePreference(userId: _userId!, promotions: value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationPreferencesCubit,
        NotificationPreferencesState>(
      builder: (context, state) {
        final prefs = state.preference;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppTopBar(
            title: 'إعدادات الإشعارات',
            variant: TopBarVariant.withBack,
          ),
          body: state.status == NotificationPreferencesStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    const _SectionHeader(
                      title: 'عام',
                      subtitle: 'التحكم في كل الإشعارات',
                    ),
                    _ToggleTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'تفعيل الإشعارات',
                      subtitle: 'استلام إشعارات على الجهاز',
                      value: prefs.pushEnabled,
                      onChanged: _onPushEnabledChanged,
                    ),
                    const _SectionHeader(
                      title: 'أنواع الإشعارات',
                      subtitle: 'اختر اللي يهمك',
                    ),
                    _ToggleTile(
                      icon: NotificationType.orderConfirmed.icon,
                      title: 'تحديثات الطلبات',
                      subtitle: 'إشعارات عند تأكيد أو تجهيز أو توصيل طلبك',
                      value: prefs.orderUpdates,
                      iconColor: NotificationType.orderConfirmed.color,
                      onChanged: _onOrderUpdatesChanged,
                    ),
                    _ToggleTile(
                      icon: NotificationType.promotion.icon,
                      title: 'العروض والتخفيضات',
                      subtitle: 'إشعارات بالعروض الجديدة والكوبونات',
                      value: prefs.promotions,
                      iconColor: NotificationType.promotion.color,
                      onChanged: _onPromotionsChanged,
                    ),
                    const _SectionHeader(
                      title: 'معاينة',
                      subtitle: 'شكل الإشعارات بالتفصيل',
                    ),
                    _TypePreview(type: NotificationType.orderConfirmed),
                    _TypePreview(type: NotificationType.orderPreparing),
                    _TypePreview(type: NotificationType.orderOutForDelivery),
                    _TypePreview(type: NotificationType.orderDelivered),
                    _TypePreview(type: NotificationType.orderCancelled),
                    _TypePreview(type: NotificationType.promotion),
                    _TypePreview(type: NotificationType.system),
                  ],
                ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final Color? iconColor;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 4,
        ),
        secondary: Icon(
          icon,
          color: iconColor ?? AppColors.primary,
          size: 22,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
      ),
    );
  }
}

class _TypePreview extends StatelessWidget {
  final NotificationType type;
  const _TypePreview({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(type.icon, color: type.color, size: 20),
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.categoryLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _sampleBody(type),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _sampleBody(NotificationType t) {
    switch (t) {
      case NotificationType.orderConfirmed:
        return 'مثال: تم تأكيد طلبك #ABC12345';
      case NotificationType.orderPreparing:
        return 'مثال: جاري تجهيز طلبك #ABC12345';
      case NotificationType.orderOutForDelivery:
        return 'مثال: طلبك في الطريق #ABC12345';
      case NotificationType.orderDelivered:
        return 'مثال: تم توصيل طلبك #ABC12345';
      case NotificationType.orderCancelled:
        return 'مثال: تم إلغاء الطلب #ABC12345';
      case NotificationType.promotion:
        return 'مثال: عرض جديد — خصم 20% على المشويات';
      case NotificationType.system:
        return 'مثال: التطبيق هيتحدث للنسخة الجديدة';
      case NotificationType.newOrderAdmin:
      case NotificationType.orderCancelledAdmin:
        return 'إشعار للإدارة فقط';
    }
  }
}
