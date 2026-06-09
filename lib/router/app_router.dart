import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../application/auth/auth_cubit.dart';
import '../application/admin/admin_orders_cubit.dart';
import '../application/admin/admin_categories_cubit.dart';
import '../application/admin/admin_products_cubit.dart';
import '../application/admin/admin_product_options_cubit.dart';
import '../application/admin/admin_coupons_cubit.dart';
import '../application/admin/admin_customers_cubit.dart';
import '../application/admin/admin_delivery_zones_cubit.dart';
import '../application/admin/admin_business_profile_cubit.dart';
import '../core/di/injection_container.dart';
import '../domain/entities/product.dart';
import '../domain/entities/order.dart';
import '../domain/entities/coupon.dart';
import '../domain/entities/customer.dart';
import '../domain/entities/delivery_zone.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/auth/onboarding_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/otp_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/menu/menu_screen.dart';
import '../presentation/screens/customer_shell.dart';
import '../presentation/screens/product/product_detail_screen.dart';
import '../presentation/screens/product/product_reviews_screen.dart';
import '../presentation/screens/product/product_customization_screen.dart';
import '../presentation/screens/cart/cart_screen.dart';
import '../presentation/screens/cart/empty_cart_screen.dart';
import '../presentation/screens/checkout/checkout_screen.dart';
import '../presentation/screens/checkout/payment_methods_screen.dart';
import '../presentation/screens/checkout/payment_proof_screen.dart';
import '../presentation/screens/checkout/order_success_screen.dart';
import '../presentation/screens/orders/orders_screen.dart';
import '../presentation/screens/orders/order_detail_screen.dart';
import '../presentation/screens/orders/order_tracking_screen.dart';
import '../presentation/screens/orders/rate_order_screen.dart';
import '../presentation/screens/profile/my_profile_screen.dart';
import '../presentation/screens/profile/my_addresses_screen.dart';
import '../presentation/screens/profile/add_address_screen.dart';
import '../presentation/screens/profile/my_favorites_screen.dart';
import '../presentation/screens/profile/notifications_screen.dart';
import '../presentation/screens/profile/settings_screen.dart';
import '../presentation/screens/info/about_us_screen.dart';
import '../presentation/screens/info/contact_us_screen.dart';
import '../presentation/screens/info/faqs_screen.dart';
import '../presentation/screens/info/legal_screen.dart';
import '../presentation/screens/admin/admin_shell.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/admin_orders_screen.dart';
import '../presentation/screens/admin/admin_order_detail_screen.dart';
import '../presentation/screens/admin/admin_menu_screen.dart';
import '../presentation/screens/admin/admin_product_form_screen.dart';
import '../presentation/screens/admin/admin_categories_screen.dart';
import '../presentation/screens/admin/admin_customers_screen.dart';
import '../presentation/screens/admin/admin_customer_detail_screen.dart';
import '../presentation/screens/admin/admin_coupons_screen.dart';
import '../presentation/screens/admin/admin_coupon_form_screen.dart';
import '../presentation/screens/admin/admin_reports_screen.dart';
import '../presentation/screens/admin/admin_delivery_zones_screen.dart';
import '../presentation/screens/admin/delivery_zone_form_screen.dart';
import '../presentation/screens/admin/admin_business_profile_screen.dart';
import '../presentation/screens/admin/printer_settings_screen.dart';
import '../presentation/screens/admin/admin_notifications_screen.dart';

CustomTransitionPage<void> _fadeTransition(
    BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
  );
}

Widget _adminWrap(Widget child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: sl<AdminOrdersCubit>()),
      BlocProvider.value(value: sl<AdminCategoriesCubit>()),
      BlocProvider.value(value: sl<AdminProductsCubit>()),
      BlocProvider.value(value: sl<AdminCouponsCubit>()..loadCoupons()),
      BlocProvider.value(value: sl<AdminCustomersCubit>()..loadCustomers()),
      BlocProvider.value(value: sl<AdminDeliveryZonesCubit>()..loadZones()),
      BlocProvider.value(value: sl<AdminBusinessProfileCubit>()..loadProfile()),
    ],
    child: child,
  );
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;
    final isLoggedIn = authState is Authenticated;

    final location = state.matchedLocation;
    final isAuthRoute = location == '/login' ||
        location == '/register' ||
        location == '/onboarding' ||
        location == '/forgot-password' ||
        location.startsWith('/otp');
    final isSplash = location == '/splash';

    if (isSplash) return null;
    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (c, s) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (c, s) => _fadeTransition(c, s, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (c, s) => _fadeTransition(c, s, const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (c, s) => _fadeTransition(c, s, const RegisterScreen()),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, const ForgotPasswordScreen()),
    ),
    GoRoute(
      path: '/otp',
      pageBuilder: (c, s) {
        final email = s.extra as String;
        return _fadeTransition(c, s, OtpScreen(email: email));
      },
    ),

    // ========== CUSTOMER SHELL (bottom nav) ==========
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CustomerShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (c, s) => _fadeTransition(c, s, const HomeScreen()),
            ),
          ],
        ),
        // Tab 1: Menu
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/menu',
              pageBuilder: (c, s) => _fadeTransition(c, s, const MenuScreen()),
            ),
          ],
        ),
        // Tab 2: Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              pageBuilder: (c, s) =>
                  _fadeTransition(c, s, const OrdersScreen()),
            ),
          ],
        ),
        // Tab 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (c, s) =>
                  _fadeTransition(c, s, const MyProfileScreen()),
            ),
          ],
        ),
      ],
    ),

    // ========== CUSTOMER SUB-ROUTES ==========
    GoRoute(
      path: '/product/:id',
      pageBuilder: (c, s) {
        final product = s.extra as Product;
        return _fadeTransition(
          c,
          s,
          BlocProvider<AdminProductOptionsCubit>.value(
            value: sl<AdminProductOptionsCubit>(),
            child: ProductDetailScreen(product: product),
          ),
        );
      },
    ),
    GoRoute(
      path: '/product/:id/reviews',
      pageBuilder: (c, s) {
        final product = s.extra as Product;
        return _fadeTransition(
          c,
          s,
          ProductReviewsScreen(
            productId: product.id,
            productName: product.nameAr,
          ),
        );
      },
    ),
    GoRoute(
      path: '/product/customize',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, const ProductCustomizationScreen()),
    ),
    GoRoute(
      path: '/cart',
      pageBuilder: (c, s) => _fadeTransition(c, s, const CartScreen()),
    ),
    GoRoute(
      path: '/empty-cart',
      pageBuilder: (c, s) => _fadeTransition(c, s, const EmptyCartScreen()),
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (c, s) => _fadeTransition(c, s, const CheckoutScreen()),
    ),
    GoRoute(
      path: '/checkout/payment',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, const PaymentMethodsScreen()),
    ),
    GoRoute(
      path: '/checkout/payment-proof',
      pageBuilder: (c, s) => _fadeTransition(c, s, const PaymentProofScreen()),
    ),
    GoRoute(
      path: '/order-success',
      pageBuilder: (c, s) {
        final orderId = s.extra as String? ?? '';
        return _fadeTransition(c, s, OrderSuccessScreen(orderId: orderId));
      },
    ),
    GoRoute(
      path: '/orders/:id',
      pageBuilder: (c, s) {
        final orderId = s.pathParameters['id'] ?? '';
        final order = s.extra is Order ? s.extra as Order : null;
        return _fadeTransition(
          c,
          s,
          OrderDetailScreen(orderId: orderId, initialOrder: order),
        );
      },
    ),
    GoRoute(
      path: '/orders/:id/track',
      pageBuilder: (c, s) {
        final orderId = s.pathParameters['id'] ?? '';
        final order = s.extra is Order ? s.extra as Order : null;
        return _fadeTransition(
          c,
          s,
          OrderTrackingScreen(orderId: orderId, initialOrder: order),
        );
      },
    ),
    GoRoute(
      path: '/orders/:id/rate',
      pageBuilder: (c, s) {
        final orderId = s.pathParameters['id'] ?? '';
        return _fadeTransition(
          c,
          s,
          RateOrderScreen(orderId: orderId),
        );
      },
    ),
    GoRoute(
      path: '/profile/addresses',
      pageBuilder: (c, s) => _fadeTransition(c, s, const MyAddressesScreen()),
    ),
    GoRoute(
      path: '/profile/addresses/add',
      pageBuilder: (c, s) => _fadeTransition(c, s, const AddAddressScreen()),
    ),
    GoRoute(
      path: '/profile/favorites',
      pageBuilder: (c, s) => _fadeTransition(c, s, const MyFavoritesScreen()),
    ),
    GoRoute(
      path: '/profile/notifications',
      pageBuilder: (c, s) => _fadeTransition(c, s, const NotificationsScreen()),
    ),
    GoRoute(
      path: '/profile/settings',
      pageBuilder: (c, s) => _fadeTransition(c, s, const SettingsScreen()),
    ),
    GoRoute(
      path: '/info/about',
      pageBuilder: (c, s) => _fadeTransition(c, s, const AboutUsScreen()),
    ),
    GoRoute(
      path: '/info/contact',
      pageBuilder: (c, s) => _fadeTransition(c, s, const ContactUsScreen()),
    ),
    GoRoute(
      path: '/info/faqs',
      pageBuilder: (c, s) => _fadeTransition(c, s, const FaqsScreen()),
    ),
    GoRoute(
      path: '/info/legal',
      pageBuilder: (c, s) => _fadeTransition(c, s, const LegalScreen()),
    ),

    // ========== ADMIN SHELL ==========
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<AdminOrdersCubit>()..loadOrders()),
            BlocProvider.value(value: sl<AdminCouponsCubit>()..loadCoupons()),
            BlocProvider.value(
                value: sl<AdminCustomersCubit>()..loadCustomers()),
            BlocProvider.value(
                value: sl<AdminDeliveryZonesCubit>()..loadZones()),
            BlocProvider.value(
                value: sl<AdminBusinessProfileCubit>()..loadProfile()),
          ],
          child: AdminShell(navigationShell: navigationShell),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin',
              builder: (c, s) => const AdminDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/orders',
              builder: (c, s) => const AdminOrdersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/coupons',
              builder: (c, s) => const AdminCouponsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/customers',
              builder: (c, s) => const AdminCustomersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/delivery-zones',
              builder: (c, s) => const AdminDeliveryZonesScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/admin/orders/:id',
      pageBuilder: (c, s) {
        final order = s.extra as Order;
        return _fadeTransition(
            c, s, _adminWrap(AdminOrderDetailScreen(order: order)));
      },
    ),
    GoRoute(
      path: '/admin/product/new',
      pageBuilder: (c, s) => _fadeTransition(
        c,
        s,
        _adminWrap(
          BlocProvider<AdminProductOptionsCubit>.value(
            value: sl<AdminProductOptionsCubit>(),
            child: const AdminProductFormScreen(),
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/product/edit',
      pageBuilder: (c, s) {
        final product = s.extra as Product?;
        return _fadeTransition(
          c,
          s,
          _adminWrap(
            BlocProvider<AdminProductOptionsCubit>.value(
              value: sl<AdminProductOptionsCubit>(),
              child: AdminProductFormScreen(product: product),
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: '/admin/menu',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, _adminWrap(const AdminMenuScreen())),
    ),
    GoRoute(
      path: '/admin/categories',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, _adminWrap(const AdminCategoriesScreen())),
    ),
    GoRoute(
      path: '/admin/customers/:id',
      pageBuilder: (c, s) {
        final customer = s.extra as Customer;
        return _fadeTransition(
            c, s, _adminWrap(AdminCustomerDetailScreen(customer: customer)));
      },
    ),
    GoRoute(
      path: '/admin/coupons/create',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, _adminWrap(const AdminCouponFormScreen())),
    ),
    GoRoute(
      path: '/admin/coupons/edit',
      pageBuilder: (c, s) {
        final coupon = s.extra as Coupon;
        return _fadeTransition(
            c, s, _adminWrap(AdminCouponFormScreen(coupon: coupon)));
      },
    ),
    GoRoute(
      path: '/admin/reports',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, _adminWrap(const AdminReportsScreen())),
    ),
    GoRoute(
      path: '/admin/delivery-zones/create',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, _adminWrap(const DeliveryZoneFormScreen())),
    ),
    GoRoute(
      path: '/admin/delivery-zones/edit',
      pageBuilder: (c, s) {
        final zone = s.extra as DeliveryZone;
        return _fadeTransition(
            c, s, _adminWrap(DeliveryZoneFormScreen(zone: zone)));
      },
    ),
    GoRoute(
      path: '/admin/business-profile',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, _adminWrap(const AdminBusinessProfileScreen())),
    ),
    GoRoute(
      path: '/admin/printer-settings',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, _adminWrap(const PrinterSettingsScreen())),
    ),
    GoRoute(
      path: '/admin/notifications',
      pageBuilder: (c, s) =>
          _fadeTransition(c, s, _adminWrap(const AdminNotificationsScreen())),
    ),
  ],
);
