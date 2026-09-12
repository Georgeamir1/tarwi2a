import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/cart/cart_cubit.dart';
import '../../../application/notifications/notifications_cubit.dart';
import '../../../application/notifications/notification_preferences_cubit.dart';
import '../../../application/theme/theme_cubit.dart';
import '../../../core/constants/app_constants.dart';
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
    if (!mounted) return;
    final authState = context.read<AuthCubit>().state;
    final userId = authState is Authenticated ? authState.profile.id : null;
    final enabled = userId != null ? service.isEnabledForUser(userId) : false;
    setState(() {
      _biometricsSupported = supported;
      _biometricsEnabled = enabled;
    });
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
                  const Text(
                      'الرجاء إدخال كلمة مرور حسابك لتشفيرها وحفظها بشكل آمن على هذا الجهاز:'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'كلمة المرور الحالية',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'الحقل مطلوب' : null,
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
          await service.setEnabled(userId: authState.profile.id, enabled: true);
          await service.saveCredentials(
            userId: authState.profile.id,
            email: email,
            password: password,
          );
          if (mounted) {
            setState(() => _biometricsEnabled = true);
            messenger.showSnackBar(
              const SnackBar(
                content: Text('تم تفعيل تسجيل الدخول بالبصمة بنجاح!'),
                backgroundColor: AppColors.statusDelivered,
              ),
            );
          }
        },
      );
    } else {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        await service.setEnabled(userId: authState.profile.id, enabled: false);
      }
      if (mounted) {
        setState(() => _biometricsEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء تفعيل تسجيل الدخول بالبصمة'),
          ),
        );
      }
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

  void _showDeleteAccountDialog() {
    final auth = context.read<AuthCubit>().state;
    if (auth is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول لإدارة الحساب'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final userId = auth.profile.id;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (modalContext, setDialogState) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.error),
                SizedBox(width: 8),
                Text('تأكيد حذف الحساب نهائياً'),
              ],
            ),
            content: const Text(
              'هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟\n\n'
              'سيؤدي هذا الإجراء إلى حذف بياناتك الشخصية وعناوين التوصيل وسجل الإشعارات، وإلغاء ارتباط كافة السجلات بحسابك بشكل نهائي لا يمكن التراجع عنه.',
            ),
            actions: [
              TextButton(
                onPressed:
                    isDeleting ? null : () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: isDeleting
                    ? null
                    : () async {
                        setDialogState(() => isDeleting = true);
                        final authCubit = context.read<AuthCubit>();
                        final result = await authCubit.deleteAccount();

                        if (!mounted) return;

                        await result.fold(
                          (failure) async {
                            setDialogState(() => isDeleting = false);
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('فشل حذف الحساب: ${failure.message}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          },
                          (_) async {
                            Navigator.pop(dialogContext);
                            await sl<BiometricService>().setEnabled(
                              userId: userId,
                              enabled: false,
                            );
                            sl<NotificationsCubit>().switchUser(null);
                            await sl<PushNotificationService>()
                                .unregisterCurrentToken();
                            if (mounted) {
                              context.read<CartCubit>().clearCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'تم حذف الحساب والبيانات الشخصية بنجاح'),
                                ),
                              );
                              GoRouter.maybeOf(context)?.go('/login');
                            }
                          },
                        );
                      },
                child: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('تأكيد الحذف النهائي'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null) {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر فتح الرابط: $urlString')),
        );
      }
    }
  }

  void _showAboutAppDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.restaurant_menu,
        color: AppColors.primary,
        size: 48,
      ),
      children: [
        const Text(
          'تطبيق ترويئه لطلب وجبات الإفطار والمأكولات الطازجة بسرعة وسهولة.',
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _openUrl(AppConstants.supportUrl),
          child: const Text('مركز المساعدة والدعم الفني'),
        ),
      ],
    );
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
                title: 'إشعارات العروض',
                subtitle: 'تلقي إشعارات بأحدث العروض والخصومات',
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
              const _SectionLabel(title: 'معلومات ومساعدة'),
              ProfileListTile(
                icon: Icons.info_outline,
                title: 'عن التطبيق',
                onTap: _showAboutAppDialog,
              ),
              ProfileListTile(
                icon: Icons.help_outline,
                title: 'المساعدة والدعم الفني',
                subtitle: 'تواصل مع فريق الدعم الفني',
                onTap: () => _openUrl(AppConstants.supportUrl),
              ),
              ProfileListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'سياسة الخصوصية',
                subtitle: 'تعرف على كيفية حماية وإدارة بياناتك',
                onTap: () => _openUrl(AppConstants.privacyPolicyUrl),
              ),
              ProfileListTile(
                icon: Icons.description_outlined,
                title: 'الشروط والأحكام',
                subtitle: 'شروط استخدام الخدمة والطلبات',
                onTap: () => _openUrl(AppConstants.termsOfServiceUrl),
              ),
              const _SectionLabel(title: 'إدارة الحساب'),
              ProfileListTile(
                icon: Icons.delete_forever_outlined,
                title: 'طلب حذف الحساب',
                subtitle: 'حذف البيانات الشخصية وسجل الحساب نهائياً',
                iconColor: AppColors.error,
                onTap: _showDeleteAccountDialog,
              ),
              ProfileListTile(
                icon: Icons.open_in_new_outlined,
                title: 'صفحة حذف الحساب (ويب)',
                subtitle:
                    'طلب حذف الحساب عبر متصفح الويب (Google Play / Apple)',
                onTap: () => _openUrl(AppConstants.accountDeletionUrl),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 4),
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
      ),
    );
  }
}
