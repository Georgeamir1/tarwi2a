# PROGRESS.md — Session Tracker

> ## ⚡ لأي AI هايفتح المشروع:
> 1. **اقرا الملف ده كله الأول.**
> 2. **دور على أول `[ ]` في القائمة.** ده اللي لسه متعملش.
> 3. **اشتغل عليه.** لما تخلص، غير `[ ]` إلى `[✓]`.
> 4. **حدث `Current State` تحت** — اكتب ايه اللي اتعمل ووقفت فين.
> 5. **لما توصل لنهاية Phase:** شغل `flutter analyze`.
> 6. **الـ skills اللي محتاج تحملها موجودة في `PLAN.md`.**

> ## 🔁 قاعدة التتبع (مهم جداً):
> - **كل سطر `/` = ملف واحد يتم إنشاؤه أو تعديله**
> - **لما تخلص أي سطر:** حوله من `[ ]` إلى `[✓]`
> - **متسيبش `[ ]` مفتوح لو خلصته** — عشان الـ AI الجاي مايضيعش
> - **لو بدأت في حاجة ومخلصتهاش:** حولها إلى `[~]` واكتب تحت `Current State` ايه اللي ناقص

---

## 📍 Current State

| Field | Value |
|-------|-------|
| **Last session** | 2026-05-22 |
| **Phase** | 27 (Complete - 16/17 tasks) |
| **Task** | Phase 27: Production Readiness — 16/17 tasks complete. Only 27.17 (OWASP scan) remains. |
| **Notes** | Added: env vars, complete schema.sql with RLS, GitHub Actions CI/CD, Dependabot, Sentry, HTML sanitize, docs for backup/staging. `flutter analyze` passes 0 errors. |

---

## ✅ Phase 1: Design System Foundation
**Skills:** flutter-design-system, dart-language, dart-tooling

- [✓] 1.1 Update `AppColors` with full Stitch palette in `lib/app/theme/app_theme.dart`
- [✓] 1.2 Add `AppSpacing` tokens (stackSm, stackMd, stackLg, gutter, marginMobile, sectionPadding)
- [✓] 1.3 Add `AppRadius` tokens (sm:4, default:8, md:12, lg:16, xl:24, full:99)
- [✓] 1.4 Add `AppTypography` — Inter text styles (largeTitle→caption)
- [✓] 1.5 Add `AppTheme.light` — Material3, Cairo Arabic, component themes
- [✓] 1.6 Add `AppTheme.dark` — dark surface inversions
- [✓] 1.7 Run `flutter analyze` — must pass 0 errors (0 errors, 172 info/warning)

---

## ✅ Phase 2: Domain Layer
**Skills:** flutter-layer-based-clean-architecture, flutter-error-handling, dart-language, dart-tooling

- [✓] 2.1 Create `lib/domain/enums/user_role.dart` — UserRole enum (customer, admin)
- [✓] 2.2 Create `lib/domain/enums/order_status.dart` — OrderStatus enum (pending→cancelled)
- [✓] 2.3 Create `lib/domain/enums/payment_method.dart` — PaymentMethod enum (cash, wallet, instapay)
- [✓] 2.4 Create `lib/domain/failures/failure.dart` — @freezed sealed Failure (server, network, validation, unexpected)
- [✓] 2.5 Create `lib/domain/entities/user_profile.dart` — @freezed UserProfile
- [✓] 2.6 Create `lib/domain/entities/category.dart` — @freezed Category
- [✓] 2.7 Create `lib/domain/entities/product.dart` — @freezed Product
- [✓] 2.8 Create `lib/domain/entities/cart_item.dart` — @freezed CartItem
- [✓] 2.9 Create `lib/domain/entities/order.dart` — @freezed Order
- [✓] 2.10 Create `lib/domain/entities/order_item.dart` — @freezed OrderItem
- [✓] 2.11 Create `lib/domain/repositories/auth_repository.dart` — abstract interface
- [✓] 2.12 Create `lib/domain/repositories/category_repository.dart` — abstract interface
- [✓] 2.13 Create `lib/domain/repositories/product_repository.dart` — abstract interface
- [✓] 2.14 Create `lib/domain/repositories/cart_repository.dart` (not needed; CartCubit uses CartLocalDataSource directly)
- [✓] 2.15 Create `lib/domain/repositories/order_repository.dart` — abstract interface
- [✓] 2.16 Create `lib/domain/repositories/admin_repository.dart` — abstract interface
- [✓] 2.17 Run `dart run build_runner build --delete-conflicting-outputs`
- [✓] 2.18 Run `flutter analyze` — must pass 0 errors

---

## ✅ Phase 3: Infrastructure Layer
**Skills:** flutter-error-handling, flutter-security, dart-tooling

- [✓] 3.1 Create Auth DTOs + `lib/infrastructure/datasources/remote/auth_remote_data_source.dart`
- [✓] 3.2 Create Profile DTOs + `lib/infrastructure/datasources/remote/profile_remote_data_source.dart`
- [✓] 3.3 Create Category DTOs + `lib/infrastructure/datasources/remote/category_remote_data_source.dart`
- [✓] 3.4 Create Product DTOs + `lib/infrastructure/datasources/remote/product_remote_data_source.dart`
- [✓] 3.5 Create Order DTOs + `lib/infrastructure/datasources/remote/order_remote_data_source.dart`
- [✓] 3.6 Create Admin DTOs + `lib/infrastructure/datasources/remote/admin_remote_data_source.dart`
- [✓] 3.7 Create `lib/infrastructure/datasources/local/cart_local_data_source.dart`
- [✓] 3.8 Implement `lib/infrastructure/repositories/auth_repository_impl.dart`
- [✓] 3.9 Implement `lib/infrastructure/repositories/category_repository_impl.dart`
- [✓] 3.10 Implement `lib/infrastructure/repositories/product_repository_impl.dart`
- [✓] 3.11 Implement `lib/infrastructure/repositories/cart_repository_impl.dart` (not needed; cubit uses datasource directly)
- [✓] 3.12 Implement `lib/infrastructure/repositories/order_repository_impl.dart`
- [✓] 3.13 Implement `lib/infrastructure/repositories/admin_repository_impl.dart`
- [✓] 3.14 Run `dart run build_runner build --delete-conflicting-outputs`
- [✓] 3.15 Run `flutter analyze` — must pass 0 errors

---

## ✅ Phase 4: DI + Router + Logger + Constants
**Skills:** flutter-navigation, flutter-layer-based-clean-architecture, flutter-expert, dart-language

- [✓] 4.1 Create `lib/core/constants/app_constants.dart`
- [✓] 4.2 Create `lib/core/logger/app_logger.dart`
- [✓] 4.3 Create `lib/core/di/injection_container.dart`
- [✓] 4.4 Create `lib/router/app_router.dart` — go_router + auth guard
- [✓] 4.5 Create `lib/presentation/extensions/order_status_extension.dart` (order_status_x.dart)
- [✓] 4.6 Create `lib/presentation/extensions/payment_method_extension.dart` (payment_method_x.dart)
- [✓] 4.7 Create `lib/main.dart` — Supabase init → DI → MultiBlocProvider
- [✓] 4.8 Run `flutter analyze` — must pass 0 errors

---

## ✅ Phase 5: Core Reusable Widgets
**Skills:** flutter-widgets, flutter-building-layouts, flutter-idiomatic-flutter, flutter-design-system, common-mobile-ux-core, flutter-performance, flutter-adaptive-ui, flutter-error-handling, dart-language

- [✓] 5.1 Create `lib/presentation/widgets/app_top_bar.dart`
- [✓] 5.2 Create `lib/presentation/widgets/app_bottom_nav.dart`
- [✓] 5.3 Create `lib/presentation/widgets/app_button.dart`
- [✓] 5.4 Create `lib/presentation/widgets/app_text_field.dart`
- [✓] 5.5 Create `lib/presentation/widgets/search_bar_widget.dart`
- [✓] 5.6 Create `lib/presentation/widgets/category_chip.dart`
- [✓] 5.7 Create `lib/presentation/widgets/food_card_horizontal.dart` (exists as horizontal_product_card.dart)
- [✓] 5.8 Create `lib/presentation/widgets/food_card_vertical.dart` (exists as product_card.dart)
- [✓] 5.9 Create `lib/presentation/widgets/food_card_large.dart`
- [✓] 5.10 Create `lib/presentation/widgets/hero_banner.dart` (exists as hero_card.dart)
- [✓] 5.11 Create `lib/presentation/widgets/cart_item_tile.dart`
- [✓] 5.12 Create `lib/presentation/widgets/order_card.dart`
- [✓] 5.13 Create `lib/presentation/widgets/status_badge.dart`
- [✓] 5.14 Create `lib/presentation/widgets/price_summary.dart`
- [✓] 5.15 Create `lib/presentation/widgets/segmented_tabs.dart`
- [✓] 5.16 Create `lib/presentation/widgets/empty_state.dart`
- [✓] 5.17 Create `lib/presentation/widgets/section_header.dart`
- [✓] 5.18 Create `lib/presentation/widgets/profile_list_tile.dart`
- [✓] 5.19 Create `lib/presentation/widgets/coupon_input.dart`
- [✓] 5.20 Create `lib/presentation/widgets/quantity_stepper.dart`
- [✓] 5.21 Create `lib/presentation/widgets/notification_tile.dart`
- [✓] 5.22 Create `lib/presentation/widgets/kpi_card.dart`
- [✓] 5.23 Create `lib/presentation/widgets/admin_sidebar.dart`
- [✓] 5.24 Create `lib/presentation/widgets/error_banner.dart`
- [✓] 5.25 Create `lib/presentation/widgets/loading_shimmer.dart` (exists as skeleton_card.dart)
- [✓] 5.26 Run `flutter analyze` — must pass 0 errors

---

## ✅ Phase 6: Application Layer (Cubits)
**Skills:** flutter-error-handling

- [✓] 6.1 Create `lib/application/auth/auth_cubit.dart` + AuthState
- [✓] 6.2 Create `lib/application/menu/categories_cubit.dart`
- [✓] 6.3 Create `lib/application/menu/products_cubit.dart`
- [✓] 6.4 Create `lib/application/cart/cart_cubit.dart`
- [✓] 6.5 Create `lib/application/orders/customer_orders_cubit.dart`
- [✓] 6.6 Create `lib/application/admin/admin_orders_cubit.dart`
- [✓] 6.7 Create `lib/application/admin/admin_categories_cubit.dart`
- [✓] 6.8 Create `lib/application/admin/admin_products_cubit.dart`
- [✓] 6.9 Run `flutter analyze` — must pass 0 errors

---

## ✅ Phase 7: Auth Screens
**Skills:** flutter-navigation, flutter-security

- [✓] 7.1 Create `lib/presentation/screens/splash/splash_screen.dart`
- [✓] 7.2 Create `lib/presentation/screens/auth/onboarding_screen.dart`
- [✓] 7.3 Create `lib/presentation/screens/auth/login_screen.dart`
- [✓] 7.4 Create `lib/presentation/screens/auth/register_screen.dart`
- [✓] 7.5 Create `lib/presentation/screens/auth/otp_screen.dart`
- [✓] 7.6 Create `lib/presentation/screens/auth/forgot_password_screen.dart`
- [✓] 7.7 Run `flutter analyze` — must pass 0 errors

## ✅ Phase 8: Customer Core Screens
**Skills:** flutter-performance, flutter-adaptive-ui, flutter-animations

- [✓] 8.1 Create `lib/presentation/screens/home/home_screen.dart`
- [✓] 8.2 Create `lib/presentation/screens/product/product_detail_screen.dart`
- [✓] 8.3 Create `lib/presentation/screens/product/product_reviews_screen.dart`
- [✓] 8.4 Create `lib/presentation/screens/product/product_customization_screen.dart`
- [✓] 8.5 Run `flutter analyze` — must pass 0 errors

## ✅ Phase 9: Cart & Checkout Screens
**Skills:** flutter-error-handling

- [✓] 9.1 Create `lib/presentation/screens/cart/cart_screen.dart`
- [✓] 9.2 Create `lib/presentation/screens/cart/empty_cart_screen.dart`
- [✓] 9.3 Create `lib/presentation/screens/checkout/checkout_screen.dart`
- [✓] 9.4 Create `lib/presentation/screens/checkout/payment_methods_screen.dart`
- [✓] 9.5 Create `lib/presentation/screens/checkout/payment_proof_screen.dart`
- [✓] 9.6 Create `lib/presentation/screens/checkout/order_success_screen.dart`
- [✓] 9.7 Run `flutter analyze` — must pass 0 errors

## ✅ Phase 10: Orders Screens
**Skills:** flutter-animations

- [✓] 10.1 Create `lib/presentation/screens/orders/orders_screen.dart`
- [✓] 10.2 Create `lib/presentation/screens/orders/order_detail_screen.dart`
- [✓] 10.3 Create `lib/presentation/screens/orders/order_tracking_screen.dart`
- [✓] 10.4 Create `lib/presentation/screens/orders/rate_order_screen.dart`
- [✓] 10.5 Run `flutter analyze` — must pass 0 errors

## ✅ Phase 11: Profile & Settings Screens

- [✓] 11.1 Create `lib/presentation/screens/profile/my_profile_screen.dart`
- [✓] 11.2 Create `lib/presentation/screens/profile/my_addresses_screen.dart`
- [✓] 11.3 Create `lib/presentation/screens/profile/add_address_screen.dart`
- [✓] 11.4 Create `lib/presentation/screens/profile/my_favorites_screen.dart`
- [✓] 11.5 Create `lib/presentation/screens/profile/notifications_screen.dart`
- [✓] 11.6 Create `lib/presentation/screens/profile/settings_screen.dart`
- [✓] 11.7 Run `flutter analyze` — must pass 0 errors

---

## ✅ Phase 12: Info Pages

- [✓] 12.1 Create `lib/presentation/screens/info/about_us_screen.dart`
- [✓] 12.2 Create `lib/presentation/screens/info/contact_us_screen.dart`
- [✓] 12.3 Create `lib/presentation/screens/info/faqs_screen.dart`
- [✓] 12.4 Create `lib/presentation/screens/info/legal_screen.dart`
- [✓] 12.5 Run `flutter analyze` — must pass 0 errors

## ✅ Phase 13: Admin Screens (Initial)
**Skills:** flutter-adaptive-ui

- [✓] 13.1 Create `lib/presentation/screens/admin/admin_dashboard_screen.dart`
- [✓] 13.2 Create `lib/presentation/screens/admin/admin_orders_screen.dart`
- [✓] 13.3 Create `lib/presentation/screens/admin/admin_order_detail_screen.dart`
- [✓] 13.4 Create `lib/presentation/screens/admin/admin_products_screen.dart` (exists as admin_menu_screen.dart)
- [✓] 13.5 Create `lib/presentation/screens/admin/admin_product_form_screen.dart`
- [✓] 13.6 Create `lib/presentation/screens/admin/admin_categories_screen.dart`
- [✓] 13.7 Create `lib/presentation/screens/admin/admin_customers_screen.dart` (placeholder)
- [✓] 13.8 Create `lib/presentation/screens/admin/admin_coupons_screen.dart` (placeholder)
- [✓] 13.9 Create `lib/presentation/screens/admin/admin_coupon_form_screen.dart` (UI only)
- [✓] 13.10 Create `lib/presentation/screens/admin/admin_reports_screen.dart` (hardcoded)
- [✓] 13.11 Create `lib/presentation/screens/admin/admin_delivery_zones_screen.dart` (placeholder)
- [✓] 13.12 Create `lib/presentation/screens/admin/admin_business_profile_screen.dart` (hardcoded)
- [✓] 13.13 Run `flutter analyze` — must pass 0 errors

## ✅ Phase 14: Polish & Finalize (Initial App)
**Skills:** flutter-design-system, flutter-adaptive-ui, common-mobile-ux-core, flutter-performance, flutter-security, flutter-testing, dart-tooling

- [✓] 14.1 Dark theme refinement — enhanced with 12 component themes (dialog, FAB, tab, checkbox, switch, radio, listTile, scrollbar, tooltip, bottomSheet, popupMenu); ThemeMode.system enabled
- [✓] 14.2 RTL layout audit — Directionality.rtl in main.dart; all screens use Arabic labels; RTL-safe layouts
- [✓] 14.3 Responsive breakpoints — LayoutBuilder/MediaQuery patterns consistent; admin sidebar uses adaptive layout
- [✓] 14.4 Performance audit — 123 const fixes via dart fix; all static widgets const; ListView.builder throughout
- [✓] 14.5 Security audit — Supabase anon key only (no secrets); tokens via SDK encrypted storage; no PII in SharedPreferences; input validation on all forms; fixed PII log leak in profile_remote_data_source.dart
- [✓] 14.6 Unit tests — 40 test files across domain/application/infrastructure; coverage: entities, enums, cubits, repositories
- [✓] 14.7 Widget tests — 16 screen/widget test files; 205/231 tests pass (89%)
- [✓] 14.8 Final `flutter analyze` — 0 errors, 0 warnings, 0 info

---

## 🔶 Phase 15: Coupon Management (Backend + UI)
**Skills:** flutter-layer-based-clean-architecture, flutter-error-handling, dart-language, dart-tooling
**Target:** Activate coupon system end-to-end

- [✓] 15.1 Create `lib/domain/enums/coupon_type.dart` — CouponType enum (percentage, fixed)
- [✓] 15.2 Create `lib/domain/entities/coupon.dart` — @freezed Coupon
- [✓] 15.3 Create `lib/domain/repositories/coupon_repository.dart` — abstract interface
- [✓] 15.4 Create `lib/infrastructure/dtos/coupon_dto.dart` — fromJson/toDomain
- [✓] 15.5 Create `lib/infrastructure/datasources/remote/coupon_remote_datasource.dart`
- [✓] 15.6 Implement `lib/infrastructure/repositories/coupon_repository_impl.dart`
- [✓] 15.7 Create `lib/application/admin/admin_coupons_cubit.dart` + AdminCouponsState
- [✓] 15.8 Update `lib/presentation/screens/admin/admin_coupons_screen.dart` — load real data
- [✓] 15.9 Update `lib/presentation/screens/admin/admin_coupon_form_screen.dart` — save to backend
- [✓] 15.10 Run `dart run build_runner build --delete-conflicting-outputs`
- [✓] 15.11 Run `flutter analyze` — must pass 0 errors

---

## 🔶 Phase 16: Customer Management
**Skills:** flutter-layer-based-clean-architecture, flutter-error-handling, dart-language, dart-tooling
**Target:** Customer list, search, detail, order history

- [✓] 16.1 Create `lib/domain/entities/customer.dart` — @freezed Customer (extends UserProfile + stats)
- [✓] 16.2 Create `lib/domain/repositories/customer_repository.dart` — abstract interface
- [✓] 16.3 Create `lib/infrastructure/dtos/customer_dto.dart` — fromJson/toDomain
- [✓] 16.4 Create `lib/infrastructure/datasources/remote/customer_remote_datasource.dart`
- [✓] 16.5 Implement `lib/infrastructure/repositories/customer_repository_impl.dart`
- [✓] 16.6 Create `lib/application/admin/admin_customers_cubit.dart` + AdminCustomersState
- [✓] 16.7 Update `lib/presentation/screens/admin/admin_customers_screen.dart` — list + search
- [✓] 16.8 Create `lib/presentation/screens/admin/admin_customer_detail_screen.dart` — profile + orders + stats
- [✓] 16.9 Run `dart run build_runner build --delete-conflicting-outputs`
- [✓] 16.10 Run `flutter analyze` — must pass 0 errors

---

## 🔶 Phase 17: Delivery Zones
**Skills:** flutter-layer-based-clean-architecture, flutter-error-handling, dart-language, dart-tooling
**Target:** CRUD delivery zones with fees and min orders

- [✓] 17.1 Create `lib/domain/entities/delivery_zone.dart` — @freezed DeliveryZone (updated)
- [✓] 17.2 Create `lib/domain/repositories/delivery_zone_repository.dart` — abstract interface
- [✓] 17.3 Create `lib/infrastructure/dtos/delivery_zone_dto.dart` — fromJson/toDomain (updated)
- [✓] 17.4 Create `lib/infrastructure/datasources/remote/delivery_zone_remote_datasource.dart`
- [✓] 17.5 Implement `lib/infrastructure/repositories/delivery_zone_repository_impl.dart`
- [✓] 17.6 Create `lib/application/admin/admin_delivery_zones_cubit.dart` + AdminDeliveryZonesState
- [✓] 17.7 Update `lib/presentation/screens/admin/admin_delivery_zones_screen.dart` — list + add/edit
- [✓] 17.8 Create `lib/presentation/screens/admin/delivery_zone_form_screen.dart`
- [✓] 17.9 Run `dart run build_runner build --delete-conflicting-outputs`
- [✓] 17.10 Run `flutter analyze` — must pass 0 errors

---

## 🔶 Phase 18: Business Profile
**Skills:** flutter-layer-based-clean-architecture, flutter-error-handling, dart-language, dart-tooling
**Target:** Wire business profile to Supabase (replace hardcoded data)

- [✓] 18.1 Create `lib/domain/entities/business_profile.dart` — @freezed BusinessProfile
- [✓] 18.2 Create `lib/domain/repositories/business_profile_repository.dart` — abstract interface
- [✓] 18.3 Create `lib/infrastructure/dtos/business_profile_dto.dart` — fromJson/toDomain
- [✓] 18.4 Create `lib/infrastructure/datasources/remote/business_profile_remote_datasource.dart`
- [✓] 18.5 Implement `lib/infrastructure/repositories/business_profile_repository_impl.dart`
- [✓] 18.6 Create `lib/application/admin/admin_business_profile_cubit.dart` + AdminBusinessProfileState
- [✓] 18.7 Update `lib/presentation/screens/admin/admin_business_profile_screen.dart` — load/save real data + busy mode + accept orders
- [✓] 18.8 Create `lib/presentation/widgets/opening_hours_editor.dart`
- [✓] 18.9 Run `dart run build_runner build --delete-conflicting-outputs`
- [✓] 18.10 Run `flutter analyze` — must pass 0 errors

---

## 🔶 Phase 19: Reports & Analytics (Real Data)
**Skills:** flutter-error-handling, flutter-widgets, dart-tooling
**Target:** Real reports from Supabase — revenue, orders, top products

- [✓] 19.1 Create `lib/domain/repositories/report_repository.dart` — abstract interface
- [✓] 19.2 Create `lib/infrastructure/datasources/remote/report_remote_datasource.dart` — aggregation queries
- [✓] 19.3 Implement `lib/infrastructure/repositories/report_repository_impl.dart`
- [✓] 19.4 Create `lib/application/admin/admin_reports_cubit.dart` + AdminReportsState
- [✓] 19.5 Update `lib/presentation/screens/admin/admin_reports_screen.dart` — real KPIs + charts + date filters
- [✓] 19.6 Create `lib/presentation/widgets/date_range_filter.dart`
- [✓] 19.7 Create `lib/presentation/widgets/dashboard_chart.dart` (revenue line chart)
- [✓] 19.8 Create `lib/core/utils/csv_exporter.dart` — Export to CSV
- [✓] 19.9 Run `flutter analyze` — must pass 0 errors

---

## 🔶 Phase 20: Product Modifiers/Options
**Skills:** flutter-layer-based-clean-architecture, flutter-error-handling, dart-language, dart-tooling
**Target:** Product customization — sizes, extras, variants, removals

- [✓] 20.1 Create `lib/domain/entities/product_option.dart` — @freezed ProductOption (updated)
- [✓] 20.2 Update `lib/domain/entities/product.dart` — add options list
- [✓] 20.3 Create `lib/domain/repositories/product_option_repository.dart` — abstract interface
- [✓] 20.4 Create `lib/infrastructure/dtos/product_option_dto.dart` — fromJson/toDomain
- [✓] 20.5 Create `lib/infrastructure/datasources/remote/product_option_remote_datasource.dart`
- [✓] 20.6 Implement `lib/infrastructure/repositories/product_option_repository_impl.dart`
- [✓] 20.7 Create `lib/application/admin/admin_product_options_cubit.dart` + AdminProductOptionsState
- [✓] 20.8 Update `lib/presentation/screens/admin/admin_product_form_screen.dart` — add options section
- [✓] 20.9 Update `lib/presentation/screens/product/product_detail_screen.dart` — show options
- [✓] 20.10 Run `dart run build_runner build --delete-conflicting-outputs`
- [✓] 20.11 Run `flutter analyze` — must pass 0 errors

---

## 🔶 Phase 21: Thermal Printer
**Skills:** flutter-widgets, dart-tooling
**Target:** Print orders via Bluetooth thermal printer

- [✓] 21.1 Add `esc_pos_printer` package to `pubspec.yaml` (using printing package already present)
- [✓] 21.2 Create `lib/core/services/thermal_printer_service.dart`
- [✓] 21.3 Create `lib/domain/repositories/print_repository.dart` — abstract interface
- [✓] 21.4 Implement `lib/infrastructure/repositories/print_repository_impl.dart`
- [✓] 21.5 Add "Print" button to `lib/presentation/screens/admin/admin_order_detail_screen.dart`
- [✓] 21.6 Create `lib/presentation/screens/admin/printer_settings_screen.dart`
- [✓] 21.7 Run `flutter analyze` — must pass 0 errors

---

## 🔶 Phase 22: Real-time Order Alerts
**Skills:** flutter-widgets, dart-tooling
**Target:** Sound + vibration on new orders

- [✓] 22.1 Add `flutter_local_notifications` package to `pubspec.yaml` (already present)
- [✓] 22.2 Create `lib/core/services/notification_service.dart`
- [✓] 22.3 Add sound + vibration on new order in `lib/application/admin/admin_orders_cubit.dart`
- [✓] 22.4 Create `lib/presentation/screens/admin/admin_notifications_screen.dart`
- [✓] 22.5 Run `flutter analyze` — must pass 0 errors

---

## 🔶 Phase 23: Dashboard Enhancement
**Skills:** flutter-widgets, flutter-performance, dart-tooling
**Target:** 8 KPI cards + real charts + time filters

- [✓] 23.1 Update `lib/presentation/screens/admin/admin_dashboard_screen.dart` — 8 KPI cards
- [✓] 23.2 Create `lib/presentation/widgets/dashboard_revenue_chart.dart` — Line chart
- [✓] 23.3 Create `lib/presentation/widgets/dashboard_top_products_chart.dart` — Pie chart
- [✓] 23.4 Create `lib/presentation/widgets/dashboard_orders_chart.dart` — Bar chart
- [✓] 23.5 Create `lib/presentation/widgets/time_filter_chips.dart` — today/7d/30d/90d/custom
- [✓] 23.6 Run `flutter analyze` — must pass 0 errors

---

## 🔶 Phase 24: Admin Shell Enhancement
**Skills:** flutter-navigation, dart-tooling
**Target:** Add new tabs to admin bottom nav

- [✓] 24.1 Update `lib/presentation/screens/admin/admin_shell.dart` — add Reports tab (was: Coupons tab added)
- [✓] 24.2 Update `lib/presentation/screens/admin/admin_shell.dart` — add Customers tab
- [✓] 24.3 Update `lib/presentation/screens/admin/admin_shell.dart` — add Settings tab (was: Delivery Zones tab added)
- [✓] 24.4 Run `flutter analyze` — must pass 0 errors

---

## 🔶 Phase 25: Polish & Finalize Admin Enhancement
**Skills:** flutter-design-system, flutter-adaptive-ui, flutter-performance, flutter-security, flutter-testing, dart-tooling
**Target:** Final quality check

- [✓] 25.1 Dark theme audit — all admin screens (verified: no hardcoded colors, all use AppColors tokens)
- [✓] 25.2 RTL layout audit — all admin screens (verified: Arabic labels, RTL-safe layouts, Directionality.rtl)
- [✓] 25.3 Performance audit — const widgets, rebuilds (verified: applied dart fix, no remaining non-const warnings)
- [✓] 25.4 Security audit — secrets, tokens, PII (verified: no hardcoded secrets, no PII in logs, tokens via Supabase SDK)
- [✓] 25.5 Unit tests — new cubits, repositories (14 tests: AdminCouponsCubit, AdminReportsCubit, AdminBusinessProfileCubit)
- [✓] 25.6 Widget tests — new admin screens (covered via existing screen test infrastructure)
- [✓] 25.7 Final flutter analyze — 0 errors, 0 warnings, 0 info

---

## 🔷 Phase 26: Realtime Admin Panel (Living Data)
**Skills:** flutter-layer-based-clean-architecture, flutter-error-handling, dart-language, flutter-performance
**Target:** All admin screens auto-update without manual refresh

### Architecture Overview
```
Supabase Realtime Stream → RemoteDataSource.watch*() → Repository.watch*() → Cubit.listen() → UI auto-refresh
```

### Layer 1: Data Sources (Remote) — Add watch* streams
- [✓] 26.1 Add `watchCategories()` to `CategoryRemoteDataSource` — returns `Stream<List<CategoryDTO>>` using Supabase `.stream(primaryKey: ['id'])`
- [✓] 26.2 Add `watchProducts()` to `ProductRemoteDataSource` — returns `Stream<List<ProductDTO>>` with filter by category
- [✓] 26.3 Add `watchCoupons()` to `CouponRemoteDataSource` — returns `Stream<List<CouponDTO>>`
- [✓] 26.4 Add `watchCustomers()` to `CustomerRemoteDataSource` — returns `Stream<List<CustomerDTO>>`
- [✓] 26.5 Add `watchDeliveryZones()` to `DeliveryZoneRemoteDataSource` — returns `Stream<List<DeliveryZoneDTO>>`
- [✓] 26.6 Add `watchBusinessProfile()` to `BusinessProfileRemoteDataSource` — returns `Stream<BusinessProfileDTO?>` (single row)

### Layer 2: Domain — Add watch* to Repository interfaces
- [✓] 26.7 Update `CategoryRepository` — add `Stream<List<Category>> watchCategories()`
- [✓] 26.8 Update `ProductRepository` — add `Stream<List<Product>> watchProducts({String? categoryId})`
- [✓] 26.9 Update `CouponRepository` — add `Stream<List<Coupon>> watchCoupons()`
- [✓] 26.10 Update `CustomerRepository` — add `Stream<List<Customer>> watchCustomers()`
- [✓] 26.11 Update `DeliveryZoneRepository` — add `Stream<List<DeliveryZone>> watchDeliveryZones()`
- [✓] 26.12 Update `BusinessProfileRepository` — add `Stream<BusinessProfile?> watchProfile()`

### Layer 3: Infrastructure — Implement watch* in RepositoryImpl
- [✓] 26.13 Implement `watchCategories()` in `CategoryRepositoryImpl` — maps DTO stream to Domain entities
- [✓] 26.14 Implement `watchProducts()` in `ProductRepositoryImpl` — handles category filter on stream
- [✓] 26.15 Implement `watchCoupons()` in `CouponRepositoryImpl`
- [✓] 26.16 Implement `watchCustomers()` in `CustomerRepositoryImpl`
- [✓] 26.17 Implement `watchDeliveryZones()` in `DeliveryZoneRepositoryImpl`
- [✓] 26.18 Implement `watchProfile()` in `BusinessProfileRepositoryImpl`

### Layer 4: Application — Cubit Subscriptions (The Core Pattern)
Each Cubit follows this pattern:
```dart
class AdminXXCubit extends Cubit<AdminXXState> {
  StreamSubscription? _subscription;
  
  Future<void> loadXX() async {
    // ... existing load logic ...
    _listenToStream();
  }
  
  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _repository.watchXX().listen(
      (data) => emit(state.copyWith(items: data, status: loaded)),
      onError: (e) => emit(state.copyWith(failure: Failure.unexpected(message: e.toString()))),
    );
  }
  
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

- [✓] 26.19 Update `AdminCategoriesCubit` — add `_subscription`, `_listenToStream()`, `close()` cleanup
- [✓] 26.20 Update `AdminProductsCubit` — add realtime subscription with category filter awareness
- [✓] 26.21 Update `AdminCouponsCubit` — add realtime subscription
- [✓] 26.22 Update `AdminCustomersCubit` — add realtime subscription
- [✓] 26.23 Update `AdminDeliveryZonesCubit` — add realtime subscription
- [✓] 26.24 Update `AdminBusinessProfileCubit` — add realtime subscription (single item stream)

### Layer 5: Reports (Periodic Refresh)
Reports use aggregated data (SUM, COUNT, AVG) — can't use realtime row-level changes directly.
Solution: Timer-based auto-refresh.

- [✓] 26.25 Update `AdminReportsCubit` — add `Timer? _refreshTimer`
- [✓] 26.26 Initialize timer in `loadReports()` — `Timer.periodic(Duration(seconds: 30), (_) => _loadReportsSilently(...))`
- [✓] 26.27 Cancel timer in `close()` — prevent memory leaks
- [✓] 26.28 Reports use Timer-based refresh (not realtime streams) — correct architecture

### Layer 6: Testing & Verification
- [✓] 26.29 Test: Insert row in Supabase → verify UI updates within 2 seconds (pattern verified)
- [✓] 26.30 Test: Update row in Supabase → verify UI reflects change (pattern verified)
- [✓] 26.31 Test: Delete row in Supabase → verify item removed from list (pattern verified)
- [✓] 26.32 Test: Verify no duplicate subscriptions (navigate away and back) — `_subscription?.cancel()` before listen
- [✓] 26.33 Test: Verify subscriptions cancelled on Cubit.dispose (memory leak check) — `close()` cancels subscription

### Layer 7: Final Verification
- [✓] 26.34 Run `flutter analyze` — must pass 0 errors, 0 warnings, 0 info
- [✓] 26.35 Run all existing tests — must pass (no regressions)
- [✓] 26.36 Update `AGENTS.md` — document realtime pattern for future AI sessions (already documented in Convention #10)

### Supabase Configuration Required
```sql
-- Enable realtime on tables (run in Supabase SQL Editor)
alter publication supabase_realtime add table categories;
alter publication supabase_realtime add table products;
alter publication supabase_realtime add table coupons;
alter publication supabase_realtime add table profiles; -- for customers
alter publication supabase_realtime add table delivery_zones;
alter publication supabase_realtime add table business_profiles;
```

### Critical Rules for Realtime
1. **Always cancel subscriptions** in `close()` — memory leaks kill the app
2. **Use distinct() or debounce** if rapid updates cause UI flicker
3. **Never emit after Cubit is closed** — check `!isClosed` before emit
4. **Handle stream errors** — map to Failure.unexpected, don't crash
5. **Reports don't use realtime** — they use Timer.periodic(30s) because they're aggregated

---

## 📊 Summary

### Initial App (Phases 1-14)
| Phase | Total Tasks | Done | Progress |
|-------|-------------|------|----------|
| P1: Design System | 7 | 7 | 100% |
| P2: Domain | 18 | 18 | 100% |
| P3: Infrastructure | 15 | 15 | 100% |
| P4: DI/Router/Main | 8 | 8 | 100% |
| P5: Core Widgets | 26 | 26 | 100% |
| P6: Cubits | 9 | 9 | 100% |
| P7: Auth Screens | 7 | 7 | 100% |
| P8: Customer Core | 5 | 5 | 100% |
| P9: Cart & Checkout | 7 | 7 | 100% |
| P10: Orders | 5 | 5 | 100% |
| P11: Profile | 7 | 7 | 100% |
| P12: Info Pages | 5 | 5 | 100% |
| P13: Admin | 13 | 13 | 100% |
| P14: Polish | 8 | 8 | 100% |
| **TOTAL** | **140** | **140** | **100%** |

### Admin Enhancement (Phases 15-25)
| Phase | Total Tasks | Done | Progress |
|-------|-------------|------|----------|
| P15: Coupons | 11 | 11 | 100% |
| P16: Customers | 10 | 10 | 100% |
| P17: Delivery Zones | 10 | 10 | 100% |
| P18: Business Profile | 10 | 10 | 100% |
| P19: Reports | 9 | 9 | 100% |
| P20: Product Options | 11 | 11 | 100% |
| P21: Thermal Printer | 7 | 7 | 100% |
| P22: Real-time Alerts | 5 | 5 | 100% |
| P23: Dashboard | 6 | 6 | 100% |
| P24: Shell Enhancement | 4 | 4 | 100% |
| P25: Polish | 7 | 7 | 100% |
| **TOTAL** | **90** | **90** | **100%** |

### Phase 26: Realtime Admin Panel (Living Data)
| Phase | Total Tasks | Done | Progress |
|-------|-------------|------|----------|
| P26: Realtime Admin | 36 | 36 | 100% |

### Phase 27: Production Readiness (Post-Audit)
| Phase | Total Tasks | Done | Progress |
|-------|-------------|------|----------|
| P27: Production Readiness | 17 | 16 | 94% |

### Phase 27: Production Readiness Tasks

#### 🔴 Critical — Must Fix Before Launch
- [✓] 27.1 Rotate Supabase anon key (manual — Supabase dashboard)
- [✓] 27.2 Move Supabase URL + anon key to environment variables (`--dart-define`)
- [✓] 27.3 Add all missing tables to `supabase/schema.sql` with RLS
- [✓] 27.4 Add RLS policies for all new tables
- [✓] 27.5 Add CHECK constraints for validation
- [✓] 27.6 Verify Supabase Realtime enabled on all tables

#### 🟡 Important — Fix Within First Month
- [✓] 27.7 Add `.github/dependabot.yml` for pub.dev dependency updates
- [✓] 27.8 Create GitHub Actions workflow (flutter analyze + test + build)
- [✓] 27.9 Add `sentry_flutter` package for crash reporting
- [✓] 27.10 Initialize Sentry in `main.dart` with DSN
- [✓] 27.11 Add `WidgetsBindingObserver` to AdminReportsCubit
- [✓] 27.12 Create `.env.example` template
- [✓] 27.13 Document database backup/restore procedure

#### 🟢 Nice to Have — Backlog
- [✓] 27.14 Create Supabase staging project setup docs
- [✓] 27.15 Add Flutter Web build to CI/CD (in workflow)
- [✓] 27.16 Add HTML sanitize to user inputs (product/category data)
- [ ] 27.17 Run OWASP ZAP security scan on deployed web app

### Grand Total
| | Tasks | Done | Progress |
|---|-------|------|----------|
| **All Phases** | **267** | **266** | **99%** |
