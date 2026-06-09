import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/theme/theme_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: const AppTopBar(title: 'الإعدادات', variant: TopBarVariant.withBack),
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
            trailing: Switch(
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
          ),
          _SettingsTile(
            icon: Icons.receipt_long_outlined,
            title: 'تحديثات الطلبات',
            trailing: Switch(
              value: _orderUpdates,
              onChanged: (v) => setState(() => _orderUpdates = v),
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
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
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
              color: AppColors.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      leading: Icon(icon, size: 22, color: AppColors.primary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      trailing: trailing,
      tileColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }
}
