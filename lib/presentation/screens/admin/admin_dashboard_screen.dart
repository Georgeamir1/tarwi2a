import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_orders_cubit.dart';
import '../../../application/admin/admin_reports_cubit.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_status.dart';
import '../../extensions/order_status_x.dart';
import '../../widgets/dashboard_revenue_chart.dart';
import '../../widgets/dashboard_top_products_chart.dart';
import '../../widgets/dashboard_orders_chart.dart';
import '../../widgets/time_filter_chips.dart';
import '../../../domain/repositories/report_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  TimeFilter _timeFilter = TimeFilter.week;

  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    return switch (_timeFilter) {
      TimeFilter.today =>
          DateTimeRange(start: DateTime(now.year, now.month, now.day), end: now),
      TimeFilter.week =>
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      TimeFilter.month =>
          DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
      TimeFilter.quarter =>
          DateTimeRange(start: now.subtract(const Duration(days: 90)), end: now),
      TimeFilter.custom =>
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    };
  }

  @override
  void initState() {
    super.initState();
    final range = _getDateRange();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminReportsCubit>().loadReports(
        startDate: range.start,
        endDate: range.end,
      );
    });
  }

  void _onFilterChanged(TimeFilter filter) {
    setState(() => _timeFilter = filter);
    final range = _getDateRange();
    context.read<AdminReportsCubit>().updateDateRange(
      range.start,
      range.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
      builder: (context, ordersState) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final ordersLoaded =
                ordersState.status == AdminOrdersStatus.loaded;
            final orders = ordersState.orders;
            final pendingCount = ordersLoaded
                ? orders.where((o) => o.status == OrderStatus.pending).length
                : 0;
            final profileName =
            authState is Authenticated ? authState.profile.name : null;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<AdminOrdersCubit>().loadOrders();
                  context.read<AuthCubit>().checkAuthStatus();
                  final range = _getDateRange();
                  context.read<AdminReportsCubit>().loadReports(
                    startDate: range.start,
                    endDate: range.end,
                  );
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _DashboardHeader(
                        profileName: profileName,
                        pendingCount: pendingCount,
                        onSettingsTap: () => _showSettingsMenu(context),
                        onBackTap: () => context.go('/home'),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ── KPI Cards ──────────────────────────────────
                          BlocBuilder<AdminReportsCubit, AdminReportsState>(
                            builder: (context, reportsState) {
                              return _KpiGrid(
                                reportsState: reportsState,
                                pendingCount: pendingCount,
                              );
                            },
                          ),

                          AppSpacing.gapH20,

                          // ── Time Filter ────────────────────────────────
                          TimeFilterChips(
                            selected: _timeFilter,
                            onChanged: _onFilterChanged,
                          ),

                          AppSpacing.gapH16,

                          // ── Charts ─────────────────────────────────────
                          BlocBuilder<AdminReportsCubit, AdminReportsState>(
                            builder: (context, state) {
                              if (state.data == null) {
                                return const _ChartSkeleton();
                              }
                              return Column(
                                children: [
                                  _ChartCard(
                                    title: 'المبيعات',
                                    unit: 'رس',
                                    totalValue: state.data!.totalRevenue,
                                    child: DashboardRevenueChart(
                                      data: state.data!.revenueByDay,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  AppSpacing.gapH12,
                                  _ChartCard(
                                    title: 'حجم الطلبات',
                                    totalValue:
                                    state.data!.totalOrders.toDouble(),
                                    isCount: true,
                                    child: DashboardOrdersChart(
                                      data: state.data!.revenueByDay,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          AppSpacing.gapH16,

                          // ── Top Products ───────────────────────────────
                          BlocBuilder<AdminReportsCubit, AdminReportsState>(
                            builder: (context, state) {
                              if (state.data == null ||
                                  state.data!.topProducts.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                children: [
                                  _TopProductsSection(
                                    data: state.data!.topProducts,
                                  ),
                                  AppSpacing.gapH16,
                                ],
                              );
                            },
                          ),

                          // ── Quick Actions ──────────────────────────────
                          _SectionHeader(title: 'الإجراءات السريعة'),
                          AppSpacing.gapH12,
                          Row(
                            children: [
                              Expanded(
                                child: _QuickActionCard(
                                  title: 'إدارة المنيو',
                                  subtitle: 'أضف وعدّل الأصناف',
                                  icon: Icons.restaurant_menu_rounded,
                                  color: AppColors.secondary,
                                  onTap: () => context.go('/admin/menu'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickActionCard(
                                  title: 'إدارة الطلبات',
                                  subtitle: 'عرض ومتابعة الطلبات',
                                  icon: Icons.receipt_long_rounded,
                                  color: AppColors.primary,
                                  onTap: () => context.go('/admin/orders'),
                                ),
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
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          AppSpacing.gapH12,
                          if (ordersState.status == AdminOrdersStatus.error)
                            _ErrorState(
                                message:
                                ordersState.failure?.message ?? 'خطأ')
                          else if (!ordersLoaded)
                            const _OrdersSkeleton()
                          else if (orders.isEmpty)
                              _buildEmptyOrders(theme)
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

  Widget _buildEmptyOrders(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 36, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'مفيش طلبات لسه',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AppSpacing.gapH16,
              ListTile(
                leading: const Icon(Icons.store, color: AppColors.primary),
                title: const Text('الملف التجاري'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/admin/business-profile');
                },
              ),
              ListTile(
                leading:
                const Icon(Icons.analytics, color: AppColors.primary),
                title: const Text('التقارير المالية'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/admin/reports');
                },
              ),
              ListTile(
                leading: const Icon(Icons.print, color: AppColors.primary),
                title: const Text('إعدادات الطابعة'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/admin/printer-settings');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthCubit>().signOut();
              if (context.mounted) context.go('/login');
            },
            child: const Text(
              'خروج',
              style: TextStyle(color: AppColors.error),
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
  final VoidCallback onSettingsTap;
  final VoidCallback onBackTap;

  const _DashboardHeader({
    required this.profileName,
    required this.pendingCount,
    required this.onSettingsTap,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _HeaderIconBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      onTap: onBackTap),
                  const SizedBox(width: 8),
                  _HeaderIconBtn(
                      icon: Icons.settings_outlined,
                      size: 20,
                      onTap: onSettingsTap),
                  const Spacer(),
                  // Notification bell with badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _HeaderIconBtn(
                          icon: Icons.notifications_outlined,
                          size: 22,
                          onTap: () {}),
                      if (pendingCount > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$pendingCount',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Greeting
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Text('👋', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileName != null ? 'أهلاً $profileName' : 'أهلاً بك',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'لوحة التحكم',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Wave bottom clip
            const SizedBox(height: 12),
            ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                height: 32,
                color: AppColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _HeaderIconBtn(
      {required this.icon, required this.size, required this.onTap});

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

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25, 0,
      size.width * 0.5, size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.8,
      size.width, size.height * 0.2,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// KPI Grid  (4 cards, 2×2)
// ──────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final AdminReportsState reportsState;
  final int pendingCount;

  const _KpiGrid({required this.reportsState, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    final data = reportsState.data;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _KpiCard(
          title: 'إجمالي المبيعات',
          value: data != null
              ? '${(data.totalRevenue / 1000).toStringAsFixed(1)}K'
              : null,
          unit: 'رس',
          change: '+12%',
          changePositive: true,
          icon: Icons.attach_money_rounded,
          iconBgColor: const Color(0xFFE8F5E9),
          iconColor: AppColors.secondary,
          sparklineData: data?.revenueByDay.map((d) => d.revenue).toList(),
        ),
        _KpiCard(
          title: 'طلبات انتظار',
          value: '$pendingCount',
          unit: 'طلب',
          icon: Icons.pending_actions_rounded,
          iconBgColor: const Color(0xFFFFF3E0),
          iconColor: AppColors.warning,
        ),
        _KpiCard(
          title: 'متوسط الطلب',
          value: data != null ? '${data.averageOrder.toInt()}' : null,
          unit: 'رس',
          icon: Icons.trending_up_rounded,
          iconBgColor: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1565C0),
          sparklineData: data?.revenueByDay.map((d) => d.revenue).toList(),
        ),
        _KpiCard(
          title: 'عدد الطلبات',
          value: data != null ? '${data.totalOrders}' : null,
          unit: 'طلب',
          icon: Icons.receipt_long_rounded,
          iconBgColor: const Color(0xFFF3E5F5),
          iconColor: const Color(0xFF7B1FA2),
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
  final String? change;
  final bool changePositive;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final List<double>? sparklineData;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.unit,
    this.change,
    this.changePositive = true,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + change badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (change != null)
                _ChangeBadge(label: change!, positive: changePositive),
            ],
          ),

          const Spacer(),

          // Value
          if (value == null)
            Container(
              height: 24,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(6),
              ),
            )
          else
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: iconColor,
                      height: 1,
                    ),
                  ),
                  TextSpan(
                    text: '  $unit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          // Sparkline
          if (sparklineData != null && sparklineData!.length > 1) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 24,
              child: CustomPaint(
                size: const Size(double.infinity, 24),
                painter: _SparklinePainter(
                  data: sparklineData!,
                  color: iconColor,
                ),
              ),
            ),
          ] else
            const SizedBox(height: 4),

          // Title
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  final String label;
  final bool positive;

  const _ChangeBadge({required this.label, required this.positive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: positive
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 10,
            color: positive ? AppColors.secondary : AppColors.error,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: positive ? AppColors.secondary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Sparkline painter
// ──────────────────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  const _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    final stepX = size.width / (data.length - 1);
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = range == 0
          ? size.height / 2
          : size.height -
          ((data[i] - minVal) / range) * size.height * 0.8 -
          size.height * 0.1;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.data != data || old.color != color;
}

// ──────────────────────────────────────────────────────────────
// Chart Card  (full-width, rich header + existing chart widget)
// ──────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String? unit;
  final double totalValue;
  final bool isCount;
  final Widget child;

  const _ChartCard({
    required this.title,
    this.unit,
    required this.totalValue,
    this.isCount = false,
    required this.child,
  });

  String get _formattedTotal {
    if (isCount) return totalValue.toInt().toString();
    if (totalValue >= 1000) {
      return '${(totalValue / 1000).toStringAsFixed(1)}K';
    }
    return totalValue.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formattedTotal,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      if (unit != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          unit!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'هذه الفترة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart — taller than before (160px vs 120px)
          SizedBox(height: 160, child: child),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Top Products Section
// ──────────────────────────────────────────────────────────────

class _TopProductsSection extends StatelessWidget {
  final List<TopProduct> data;

  const _TopProductsSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.fold(0.0, (sum, p) => sum + p.revenue);

    const dotColors = [
      AppColors.primary,
      AppColors.secondary,
      Color(0xFF1565C0),
      Color(0xFF7B1FA2),
      Color(0xFFE65100),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المنتجات الأكثر مبيعاً',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'التفاصيل',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_left, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Donut + legend side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut — no floating percentage labels
              SizedBox(
                width: 110,
                height: 110,
                child: DashboardTopProductsChart(data: data),
              ),
              const SizedBox(width: 16),
              // Rich legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.take(4).toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    final percent = total > 0 ? p.revenue / total : 0.0;
                    final color = dotColors[i % dotColors.length];
                    final revenueStr = p.revenue >= 1000
                        ? '${(p.revenue / 1000).toStringAsFixed(1)}K'
                        : p.revenue.toStringAsFixed(0);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$revenueStr رس',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(percent * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent.clamp(0.0, 1.0),
                              minHeight: 4,
                              backgroundColor:
                              color.withValues(alpha: 0.12),
                              valueColor:
                              AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => context.push('/admin/orders/${order.id}', extra: order),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                // Status indicator — left accent bar
                Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: order.status.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

                // Order info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '#${order.id.substring(0, 6).toUpperCase()} · ${order.totalAmount.toStringAsFixed(0)} ج',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right side: time + status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: order.status.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: order.status.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        order.status.arabicLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: order.status.color,
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
    );
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

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _OrdersSkeleton extends StatelessWidget {
  const _OrdersSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: CircularProgressIndicator(
          strokeWidth: 2,
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
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'خطأ: $message',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}