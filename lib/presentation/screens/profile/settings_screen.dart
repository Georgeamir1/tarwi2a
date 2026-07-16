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
import '../../../core/services/biometric_service.dart';
import '../../../domain/repositories/auth_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _orderUpdates = true;
  String? _userId;
  bool _biometricsSupported = false;
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final service = sl<BiometricService>();
    final supported = await service.isHardwareSupported;
    if (mounted) {
      setState(() {
        _biometricsSupported = supported;
        _biometricsEnabled = service.isEnabled;
      });
    }
  }

  Future<void> _onBiometricsChanged(bool value) async {
    final service = sl<BiometricService>();
    if (value) {
      final authenticated = await service.authenticate();
      if (!authenticated) {
        setState(() => _biometricsEnabled = false);
        return;
      }

      if (!mounted) return;

      final password = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          final formKey = GlobalKey<FormState>();
          return AlertDialog(
            title: const Text('تفعيل الدخول بالبصمة'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('الرجاء إدخال كلمة مرور حسابك لتشفيرها وحفظها بشكل آمن على هذا الجهاز:'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'كلمة المرور الحالية',
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'الحقل مطلوب' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, controller.text);
                  }
                },
                child: const Text('تأكيد'),
              ),
            ],
          );
        },
      );

      if (password == null || password.isEmpty || !mounted) {
        setState(() => _biometricsEnabled = false);
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated) {
        Navigator.pop(context);
        return;
      }
      final email = sl<AuthRepository>().currentUser?.email;
      if (email == null) {
        Navigator.pop(context);
        return;
      }

      final result = await sl<AuthRepository>().signIn(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading

      final messenger = ScaffoldMessenger.of(context);

      result.fold(
        (failure) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('كلمة المرور غير صحيحة، فشل تفعيل البصمة'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _biometricsEnabled = false);
        },
        (_) async {
          await service.saveCredentials(email, password);
          await service.setEnabled(true);
          setState(() => _biometricsEnabled = true);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('تم تفعيل تسجيل الدخول بالبصمة بنجاح!'),
              backgroundColor: AppColors.statusDelivered,
            ),
          );
        },
      );
    } else {
      await service.setEnabled(false);
      setState(() => _biometricsEnabled = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء تفعيل تسجيل الدخول بالبصمة'),
        ),
      );
    }
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
              if (_biometricsSupported) ...[
                const _SectionLabel(title: 'الأمان'),
                _SettingsTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'تسجيل الدخول بالبصمة',
                  subtitle: 'استخدام البصمة أو Face ID للمصادقة السريعة',
                  trailing: Switch(
                    value: _biometricsEnabled,
                    onChanged: _onBiometricsChanged,
                  ),
                ),
              ],
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
