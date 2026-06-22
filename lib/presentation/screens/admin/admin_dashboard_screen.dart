import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_orders_cubit.dart';
import '../../../application/admin/admin_business_profile_cubit.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../application/notifications/notifications_cubit.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_status.dart';
import '../../extensions/order_status_x.dart';
import '../../widgets/app_button.dart';
import '../../widgets/notification_badge.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
      builder: (context, ordersState) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final ordersLoaded = ordersState.status == AdminOrdersStatus.loaded;
            final orders = ordersState.orders;
            final pendingCount = ordersLoaded
                ? orders.where((o) => o.status == OrderStatus.pending).length
                : 0;
            final totalOrdersCount = ordersLoaded ? orders.length : 0;
            final cancelledCount = ordersLoaded
                ? orders.where((o) => o.status == OrderStatus.cancelled).length
                : 0;
            final customerCount = ordersLoaded
                ? orders.map((o) => o.customerId).toSet().length
                : 0;
            final profileName =
                authState is Authenticated ? authState.profile.name : null;

            return Scaffold(
              backgroundColor:
                  isDark ? AppColors.darkBackground : AppColors.background,
              body: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<AdminOrdersCubit>().loadOrders();
                  context.read<AuthCubit>().checkAuthStatus();
                  context.read<AdminBusinessProfileCubit>().loadProfile();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _DashboardHeader(
                        profileName: profileName,
                        pendingCount: pendingCount,
                        onBackTap: () => context.go('/home'),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ── KPI Cards (operational only) ────────────────
                          _KpiGrid(
                            pendingCount: pendingCount,
                            totalOrders: totalOrdersCount,
                            customerCount: customerCount,
                            cancelledCount: cancelledCount,
                          ),

                          AppSpacing.gapH20,

                          // ── Quick Actions ──────────────────────────────
                          _SectionHeader(title: 'الإجراءات السريعة'),
                          AppSpacing.gapH12,
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.5,
                            children: [
                              _QuickActionCard(
                                title: 'إدارة المنيو',
                                subtitle: 'الأصناف والأسعار',
                                icon: Icons.restaurant_menu_rounded,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF5C4E4D),
                                    Color(0xFF7D6B69)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onTap: () => context.go('/admin/menu'),
                              ),
                              _QuickActionCard(
                                title: 'إدارة الطلبات',
                                subtitle: 'تتبع الطلبات الحية',
                                icon: Icons.receipt_long_rounded,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE02B2B),
                                    Color(0xFFFF5252)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onTap: () => context.go('/admin/orders'),
                              ),
                              _QuickActionCard(
                                title: 'الملف التجاري',
                                subtitle: 'مواعيد العمل والفرع',
                                icon: Icons.storefront_rounded,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFC68B59),
                                    Color(0xFFE0A97E)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onTap: () =>
                                    context.push('/admin/business-profile'),
                              ),
                              _QuickActionCard(
                                title: 'التقارير المالية',
                                subtitle: 'الأرباح بالتفصيل',
                                icon: Icons.analytics_rounded,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00658B),
                                    Color(0xFF0091C7)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onTap: () => context.push('/admin/reports'),
                              ),
                              _QuickActionCard(
                                title: 'إرسال إشعار',
                                subtitle: 'عروض وتحديثات',
                                icon: Icons.campaign_rounded,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE02B2B),
                                    Color(0xFFFF5252)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onTap: () => context.push('/admin/broadcast'),
                              ),
                            ],
                          ),

                          AppSpacing.gapH24,

                          // ── Recent Orders ──────────────────────────────
                          _SectionHeader(
                            title: 'آخر الطلبات',
                            action: TextButton(
                              onPressed: () => context.go('/admin/orders'),
                              child: const Text(
                                'عرض الكل',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          AppSpacing.gapH12,
                          if (ordersState.status == AdminOrdersStatus.error)
                            _ErrorState(
                                message: ordersState.failure?.message ??
                                    'خطأ في تحميل البيانات')
                          else if (!ordersLoaded)
                            const _OrdersSkeleton()
                          else if (orders.isEmpty)
                            _buildEmptyOrders(theme, isDark)
                          else
                            ...orders.take(5).map(
                                  (order) => _OrderListItem(order: order),
                                ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyOrders(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkDivider
              : AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            'لا توجد طلبات مسجلة حالياً',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.secondary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Header
// ──────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final String? profileName;
  final int pendingCount;
  final VoidCallback onBackTap;

  const _DashboardHeader({
    required this.profileName,
    required this.pendingCount,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  const Color(0xFF3B2423),
                  const Color(0xFF2C1918),
                ]
              : [
                  AppColors.primary,
                  const Color(0xFFC02222),
                  const Color(0xFF8B1E1E),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  _HeaderIconBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    onTap: onBackTap,
                  ),
                  const Spacer(),
                  // Notification bell with badge (unread from cubit)
                  BlocBuilder<NotificationsCubit, NotificationsState>(
                    buildWhen: (prev, curr) =>
                        prev.unreadCount != curr.unreadCount,
                    builder: (context, notifState) {
                      return NotificationBadge(
                        icon: Icons.notifications_none_rounded,
                        count: notifState.unreadCount,
                        color: Colors.white,
                        iconSize: 20,
                        tooltip: 'الإشعارات',
                        onTap: () => context.push('/admin/notifications'),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Greeting
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileName != null
                            ? 'أهلاً، $profileName 👋'
                            : 'أهلاً بك 👋',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        'لوحة التحكم والإدارة الفورية',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Operational Status Card (Frosted Glassmorphic look)
              BlocBuilder<AdminBusinessProfileCubit, AdminBusinessProfileState>(
                builder: (context, state) {
                  final profile = state.profile;
                  if (profile == null) {
                    return Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    );
                  }

                  final String statusText;
                  final Color indicatorColor;
                  final IconData statusIcon;

                  if (!profile.acceptOrders) {
                    statusText = 'المطعم مغلق حالياً ولا يستقبل طلبات';
                    indicatorColor = const Color(0xFFEF9A9A); // Soft red
                    statusIcon = Icons.remove_circle_outline_rounded;
                  } else if (profile.isBusy) {
                    statusText = 'المطعم مشغول ومزدحم (الطلبات قد تتأخر)';
                    indicatorColor = const Color(0xFFFFCC80); // Soft orange
                    statusIcon = Icons.warning_amber_rounded;
                  } else {
                    statusText = 'المطعم مفتوح ويستقبل طلبات حية';
                    indicatorColor = const Color(0xFFA5D6A7); // Soft green
                    statusIcon = Icons.check_circle_outline_rounded;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: indicatorColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'حالة تشغيل المطعم',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: indicatorColor,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quick Action button to modify
                        Material(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _showStatusBottomSheet(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Text(
                                'تغيير',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocBuilder<AdminBusinessProfileCubit,
            AdminBusinessProfileState>(
          builder: (context, state) {
            final profile = state.profile;
            if (profile == null) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'تعديل حالة تشغيل المطعم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'تحكم بظهور المطعم وقبول الطلبات للعملاء مباشرة',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.outline,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Accept Orders Switch
                    _BottomSheetToggleTile(
                      title: 'استقبال الطلبات',
                      subtitle: profile.acceptOrders
                          ? 'المطعم يظهر للعملاء ومتاح للطلب'
                          : 'الطلب متوقف والمطعم يظهر كمغلق',
                      value: profile.acceptOrders,
                      icon: Icons.shopping_bag_outlined,
                      onChanged: (val) {
                        context
                            .read<AdminBusinessProfileCubit>()
                            .toggleAcceptOrders(val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Busy Mode Switch
                    _BottomSheetToggleTile(
                      title: 'وضع الانشغال (مزدحم)',
                      subtitle: profile.isBusy
                          ? 'تنبيه العملاء بزيادة وقت التحضير'
                          : 'العمل يسير بالمعدل الطبيعي',
                      value: profile.isBusy,
                      icon: Icons.timer_outlined,
                      onChanged: (val) {
                        context
                            .read<AdminBusinessProfileCubit>()
                            .toggleBusyMode(
                              isBusy: val,
                              message: val
                                  ? 'المطعم مزدحم حالياً، قد يستغرق الطلب وقتاً أطول للتحضير'
                                  : null,
                            );
                      },
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      label: 'إغلاق',
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BottomSheetToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _BottomSheetToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.outlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: value ? AppColors.primary : AppColors.outline,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'Cairo',
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Section header
// ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.onSurface,
            fontFamily: 'Cairo',
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// KPI Grid  (4 operational cards, 2×2)
// ──────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final int pendingCount;
  final int totalOrders;
  final int customerCount;
  final int cancelledCount;

  const _KpiGrid({
    required this.pendingCount,
    required this.totalOrders,
    required this.customerCount,
    required this.cancelledCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        _KpiCard(
          title: 'بانتظار التأكيد',
          value: '$pendingCount',
          unit: 'طلب',
          icon: Icons.hourglass_empty_rounded,
          iconColor: const Color(0xFFEF6C00),
          iconBgColor: const Color(0xFFFFF3E0),
        ),
        _KpiCard(
          title: 'إجمالي الطلبات',
          value: '$totalOrders',
          unit: 'طلب',
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFF7B1FA2),
          iconBgColor: const Color(0xFFF3E5F5),
        ),
        _KpiCard(
          title: 'عدد العملاء',
          value: '$customerCount',
          unit: 'عميل',
          icon: Icons.people_alt_rounded,
          iconColor: const Color(0xFF00838F),
          iconBgColor: const Color(0xFFE0F7FA),
        ),
        _KpiCard(
          title: 'الطلبات الملغاة',
          value: '$cancelledCount',
          unit: 'طلب',
          icon: Icons.cancel_rounded,
          iconColor: const Color(0xFFD84315),
          iconBgColor: const Color(0xFFFBE9E7),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// KPI Card
// ──────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String title;
  final String? value; // null = loading
  final String unit;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkDivider
              : AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.secondary.withValues(alpha: 0.75),
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      isDark ? iconColor.withValues(alpha: 0.15) : iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const Spacer(),
          if (value == null)
            Container(
              height: 20,
              width: 50,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkDivider
                    : AppColors.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.onSurface,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.secondary.withValues(alpha: 0.6),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Quick Action Card
// ──────────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white, size: 18),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white70,
                      size: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Order List Item
// ──────────────────────────────────────────────────────────────

class _OrderListItem extends StatelessWidget {
  final Order order;

  const _OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? AppColors.darkDivider
                : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
          boxShadow: const [AppShadows.card],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () =>
                context.push('/admin/orders/${order.id}', extra: order),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Status colored badge icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: order.status.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(order.status),
                      color: order.status.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Order Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.onSurface,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '#${order.id.substring(0, 6).toUpperCase()}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.secondary
                                        .withValues(alpha: 0.8),
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '·  ${order.totalAmount.toStringAsFixed(0)} ج',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right column: Time elapsed + Arabic Status Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.secondary.withValues(alpha: 0.6),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: order.status.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: order.status.color.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          order.status.arabicLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: order.status.color,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => Icons.hourglass_top_rounded,
      OrderStatus.confirmed => Icons.check_circle_outline_rounded,
      OrderStatus.preparing => Icons.restaurant_menu_rounded,
      OrderStatus.ready => Icons.shopping_bag_outlined,
      OrderStatus.delivered => Icons.local_shipping_rounded,
      OrderStatus.cancelled => Icons.cancel_outlined,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'اليوم ${_formatTime(date)}';
    if (diff.inDays == 1) return 'أمس ${_formatTime(date)}';
    return '${date.day}/${date.month}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// ──────────────────────────────────────────────────────────────
// Skeleton / Loading states
// ──────────────────────────────────────────────────────────────

class _OrdersSkeleton extends StatelessWidget {
  const _OrdersSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'خطأ: $message',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.error,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
