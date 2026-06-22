import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../widgets/app_top_bar.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isSigningOut = false;

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);

    final result = await context.read<AuthCubit>().signOut();

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isSigningOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final profile = state is Authenticated ? state.profile : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppTopBar(
            title: 'حسابي',
            variant: TopBarVariant.withBack,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                // Premium Greeting Header Card (No avatar circle, no mock loyalty/points)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.darkCard, AppColors.darkBackground]
                          : [AppColors.primaryContainer, const Color(0xFFFFECE9)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: isDark ? AppColors.darkDivider : AppColors.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Decorative Icon placeholder
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkSurface : AppColors.surface).withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.name ?? 'زائر',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.onPrimaryContainer,
                              ),
                            ),
                            if (profile?.phone != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_android_rounded,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.onSecondaryContainer.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    profile!.phone!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Group 1: نشاطي (My Activity)
                _ProfileGroupCard(
                  title: 'نشاطي',
                  children: [
                    if (profile?.role.isAdmin == true)
                      _ProfileMenuItem(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'لوحة التحكم',
                        subtitle: 'إدارة المنتجات، الطلبات والإحصائيات',
                        iconColor: AppColors.primary,
                        onTap: () => context.go('/admin'),
                        showDivider: true,
                      ),
                    _ProfileMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'عناويني',
                      subtitle: profile?.phone ?? 'أضف عنوان التوصيل',
                      iconColor: Colors.blue,
                      onTap: () => context.push('/profile/addresses'),
                      showDivider: true,
                    ),
                    _ProfileMenuItem(
                      icon: Icons.favorite_outline,
                      title: 'المفضلة',
                      subtitle: 'قائمتك للمأكولات المفضلة',
                      iconColor: Colors.pink,
                      onTap: () => context.push('/profile/favorites'),
                      showDivider: true,
                    ),
                    _ProfileMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'الإشعارات',
                      subtitle: 'سجل الإشعارات وتنبيهات الطلبات',
                      iconColor: Colors.orange,
                      onTap: () => context.push('/profile/notifications'),
                    ),
                  ],
                ),

                // Group 2: تفضيلاتي (My Preferences)
                _ProfileGroupCard(
                  title: 'التفضيلات والأمان',
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'إعدادات الحساب',
                      subtitle: 'الوضع الليلي وتفضيلات الإشعارات',
                      iconColor: Colors.blueGrey,
                      onTap: () => context.push('/profile/settings'),
                    ),
                  ],
                ),

                // Group 3: تواصل ومعلومات (Support & Info)
                _ProfileGroupCard(
                  title: 'الدعم والمعلومات',
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.info_outline,
                      title: 'عن ترويقة',
                      subtitle: 'معلومات عن قصتنا ورؤيتنا',
                      iconColor: Colors.teal,
                      onTap: () => context.push('/info/about'),
                      showDivider: true,
                    ),
                    _ProfileMenuItem(
                      icon: Icons.support_agent_outlined,
                      title: 'تواصل معنا',
                      subtitle: 'الدعم الفني والمساعدة الفورية',
                      iconColor: Colors.purple,
                      onTap: () => context.push('/info/contact'),
                    ),
                  ],
                ),

                // Sign-out Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xl,
                  ),
                  child: InkWell(
                    onTap: _isSigningOut ? null : _handleSignOut,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSigningOut) ...[
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'جاري تسجيل الخروج...',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              Icons.logout_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تسجيل الخروج',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileGroupCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.md,
            AppSpacing.xxl,
            AppSpacing.sm,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextSecondary : AppColors.secondary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.outlineVariant,
              width: 1,
            ),
            boxShadow: const [AppShadows.card],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showDivider;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconBg = iconColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(icon, color: iconBg, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.onBackground,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.outline.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 72,
              endIndent: 16,
              color: isDark ? AppColors.darkDivider : AppColors.outlineVariant,
            ),
        ],
      ),
    );
  }
}
