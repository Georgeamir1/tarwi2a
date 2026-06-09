import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/profile_list_tile.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final profile = state is Authenticated ? state.profile : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppTopBar(title: 'حسابي', variant: TopBarVariant.withBack),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    profile?.name.isNotEmpty == true
                        ? profile!.name[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile?.name ?? 'زائر',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (profile?.phone != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile!.phone!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                if (profile?.role.isAdmin == true)
                  ProfileListTile(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'لوحة التحكم',
                    onTap: () => context.go('/admin'),
                  ),
                ProfileListTile(
                  icon: Icons.location_on_outlined,
                  title: 'عناويني',
                  subtitle: profile?.phone ?? 'أضف عنوان التوصيل',
                  onTap: () => context.push('/profile/addresses'),
                ),
                ProfileListTile(
                  icon: Icons.favorite_outline,
                  title: 'المفضلة',
                  onTap: () => context.push('/profile/favorites'),
                ),
                ProfileListTile(
                  icon: Icons.notifications_outlined,
                  title: 'الإشعارات',
                  onTap: () => context.push('/profile/notifications'),
                ),
                ProfileListTile(
                  icon: Icons.settings_outlined,
                  title: 'الإعدادات',
                  onTap: () => context.push('/profile/settings'),
                ),
                ProfileListTile(
                  icon: Icons.info_outline,
                  title: 'عن التطبيق',
                  onTap: () => context.push('/info/about'),
                ),
                ProfileListTile(
                  icon: Icons.support_agent_outlined,
                  title: 'تواصل معانا',
                  onTap: () => context.push('/info/contact'),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthCubit>().signOut();
                      },
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('تسجيل الخروج'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 140),
              ],
            ),
          ),
        );
      },
    );
  }
}
