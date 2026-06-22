import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/notifications/notification_preferences_cubit.dart';
import '../../../application/theme/theme_cubit.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/services/push_notification_service.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/profile_list_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _orderUpdates = true;
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
    final prefsCubit = context.read<NotificationPreferencesCubit>();
    prefsCubit.loadPreferences(_userId!);
    prefsCubit.state.preference;
  }

  Future<void> _onPushEnabledChanged(bool value) async {
    if (_userId == null) return;
    setState(() => _notifications = value);
    final service = sl<PushNotificationService>();
    if (value) {
      final granted = await service.requestPermissionWithPriming(context);
      if (granted) {
        await service.registerTokenForCurrentUser(userIdOverride: _userId);
      } else {
        setState(() => _notifications = false);
        return;
      }
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
    setState(() => _orderUpdates = value);
    context
        .read<NotificationPreferencesCubit>()
        .updatePreference(userId: _userId!, orderUpdates: value);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;
    return BlocBuilder<NotificationPreferencesCubit,
        NotificationPreferencesState>(
      builder: (context, prefsState) {
        if (prefsState.status == NotificationPreferencesStatus.loaded &&
            prefsState.preference.userId.isNotEmpty &&
            _userId != null) {
          if (_notifications != prefsState.preference.pushEnabled ||
              _orderUpdates != prefsState.preference.orderUpdates) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _notifications = prefsState.preference.pushEnabled;
                _orderUpdates = prefsState.preference.orderUpdates;
              });
            });
          }
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppTopBar(
            title: 'الإعدادات',
            variant: TopBarVariant.withBack,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              const _SectionLabel(title: 'المظهر'),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'الوضع الليلي',
                trailing: Switch(
                  value: isDark,
                  onChanged: (v) {
                    context
                        .read<ThemeCubit>()
                        .setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
              const _SectionLabel(title: 'الإشعارات'),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'تفعيل الإشعارات',
                subtitle: 'استلام إشعارات فورية على الجهاز',
                trailing: Switch(
                  value: _notifications,
                  onChanged: _onPushEnabledChanged,
                ),
              ),
              _SettingsTile(
                icon: Icons.receipt_long_outlined,
                title: 'تحديثات الطلبات',
                subtitle: 'إشعارات عند تغيير حالة طلبك',
                trailing: Switch(
                  value: _orderUpdates,
                  onChanged: _onOrderUpdatesChanged,
                ),
              ),
              const _SectionLabel(title: 'معلومات'),
              ProfileListTile(
                icon: Icons.info_outline,
                title: 'عن التطبيق',
                onTap: () {},
              ),
              ProfileListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'سياسة الخصوصية',
                onTap: () {},
              ),
              ProfileListTile(
                icon: Icons.description_outlined,
                title: 'الشروط والأحكام',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'الإصدار 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        leading: Icon(icon, size: 22, color: AppColors.primary),
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
        trailing: trailing,
      ),
    );
  }
}
