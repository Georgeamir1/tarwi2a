# PLAN.md — ترويئه Admin Panel Enhancement Plan

> **اقرا الملف ده أول ما تفتح البروجكت.**
> كل Phase فيه قائمة مهام. تتبع التقدم الفعلي في `PROGRESS.md`.

---

## 🧠 Session Continuity

**لما تفتح سيشن جديدة، أول حاجة تعملها:**
1. اقرا `PROGRESS.md` — هتعرف واقف فين بالظبط
2. حمّل السكيلز المكتوبة تحت
3. كمل من أول `[ ]` في `PROGRESS.md`
4. بعد كل تعديل، حدث `PROGRESS.md` — حول `[ ]` إلى `[✓]`

---

## 🎯 Skills to Load (Required)

### 🔴 P0 — تحميل إجباري قبل أي شغل
| السكيل | ليه |
|--------|-----|
| `flutter-layer-based-clean-architecture` | تنظيم domain/infra/app/presentation + freezed + Either + get_it DI |
| `flutter-error-handling` | Repositories ترجع Either<Failure,T>، Cubits تـ fold |
| `flutter-design-system` | ممنوع hardcoded colors/spacing — كل حاجة من theme tokens |
| `dart-language` | sealed classes، switch expressions، extensions |
| `common-mobile-ux-core` | 48px touch targets، SafeArea، Material 3 |
| `company` | شامل: PM + Senior Dev + UI/UX + QA + Security |

### 🟡 P1 — تحميل مستمر
| السكيل | ليه |
|--------|-----|
| `flutter-expert` | Flutter 3+، BLoC 8.x، GoRouter |
| `flutter-navigation` | go_router + auth guard + StatefulShellRoute |
| `flutter-widgets` | StatelessWidget، const، Theme.of(context) |
| `flutter-idiomatic-flutter` | context.mounted، SizedBox.shrink()، extract |
| `flutter-performance` | buildWhen/select، ListView.builder، const |
| `flutter-building-layouts` | Constraint system، Row/Column/Stack |
| `flutter-adaptive-ui` | RTL + responsive breakpoints + admin sidebar |
| `flutter-security` | Supabase tokens، no secrets in shared_prefs |
| `flutter-testing` | Robot pattern، blocTest |
| `dart-best-practices` | const > final > var، single quotes، trailing commas |
| `dart-tooling` | build_runner، flutter analyze |
| `common-best-practices` | SOLID، guard clauses، function < 30 lines |
| `common-error-handling` | Error layering، never swallow |
| `common-documentation` | Intent-first comments (only when needed) |
| `common-code-review` | Self-review before marking task complete |

### 🟢 P2 — استخدام حسب الحاجة
| السكيل | ليه |
|--------|-----|
| `flutter-animations` | Hero transitions، animated state changes |
| `flutter-notifications` | Push notifications (future) |
| `flutter-cicd` | CI/CD setup (future) |

---

## 🏗️ Architecture Rules (من AGENTS.md)

```
✓ BLoC (flutter_bloc) — ممنوع Riverpod
✓ get_it للـ DI — استخدم sl<T>() دايماً
✓ جميع الـ Entities @freezed
✓ Repositories ترجع Either<Failure, T>
✓ DTOs في infrastructure فقط — UI يستخدم entities
✓ Cubit state: sealed enum (initial→loading→loaded→error)
✓ Screens = StatelessWidget + BlocBuilder
✓ ممنوع print() — استخدم appLogger
✓ ممنوع Material imports في domain
✓ ممنوع string comparisons للـ status/payment — استخدم enums
✓ تشغيل flutter analyze بعد كل Phase
```

---

## 📱 Implementation Plan

### Phase 15: Coupon Management (Backend + UI)
**الهدف:** تفعيل نظام الكوبونات بالكامل — domain → infrastructure → cubit → screen

| # | Task | File | Skills |
|---|------|------|--------|
| 15.1 | إنشاء `CouponType` enum | `lib/domain/enums/coupon_type.dart` | dart-language |
| 15.2 | إنشاء `Coupon` entity @freezed | `lib/domain/entities/coupon.dart` | flutter-layer-based-clean-architecture |
| 15.3 | إنشاء `CouponRepository` abstract interface | `lib/domain/repositories/coupon_repository.dart` | flutter-error-handling |
| 15.4 | إنشاء `CouponDto` + fromJson/toDomain | `lib/infrastructure/dtos/coupon_dto.dart` | — |
| 15.5 | إنشاء `CouponRemoteDataSource` | `lib/infrastructure/datasources/remote/coupon_remote_datasource.dart` | flutter-security |
| 15.6 | تنفيذ `CouponRepositoryImpl` | `lib/infrastructure/repositories/coupon_repository_impl.dart` | flutter-error-handling |
| 15.7 | إنشاء `AdminCouponsCubit` + State | `lib/application/admin/admin_coupons_cubit.dart` | flutter-error-handling |
| 15.8 | تعديل `AdminCouponsScreen` — load real data | `lib/presentation/screens/admin/admin_coupons_screen.dart` | flutter-widgets |
| 15.9 | تعديل `AdminCouponFormScreen` — save to backend | `lib/presentation/screens/admin/admin_coupon_form_screen.dart` | flutter-widgets |
| 15.10 | code generation | — | dart-tooling |
| 15.11 | flutter analyze + fix | — | dart-tooling |

### Phase 16: Customer Management
**الهدف:** إدارة العملاء — list, search, detail, order history

| # | Task | File | Skills |
|---|------|------|--------|
| 16.1 | إنشاء `Customer` entity @freezed (extends UserProfile + stats) | `lib/domain/entities/customer.dart` | flutter-layer-based-clean-architecture |
| 16.2 | إنشاء `CustomerRepository` abstract interface | `lib/domain/repositories/customer_repository.dart` | flutter-error-handling |
| 16.3 | إنشاء `CustomerDto` + fromJson/toDomain | `lib/infrastructure/dtos/customer_dto.dart` | — |
| 16.4 | إنشاء `CustomerRemoteDataSource` | `lib/infrastructure/datasources/remote/customer_remote_datasource.dart` | — |
| 16.5 | تنفيذ `CustomerRepositoryImpl` | `lib/infrastructure/repositories/customer_repository_impl.dart` | flutter-error-handling |
| 16.6 | إنشاء `AdminCustomersCubit` + State | `lib/application/admin/admin_customers_cubit.dart` | flutter-error-handling |
| 16.7 | تعديل `AdminCustomersScreen` — list + search | `lib/presentation/screens/admin/admin_customers_screen.dart` | flutter-widgets |
| 16.8 | إنشاء `AdminCustomerDetailScreen` — profile + orders + stats | `lib/presentation/screens/admin/admin_customer_detail_screen.dart` | flutter-widgets |
| 16.9 | code generation | — | dart-tooling |
| 16.10 | flutter analyze + fix | — | dart-tooling |

### Phase 17: Delivery Zones
**الهدف:** إدارة مناطق التوصيل — CRUD + map

| # | Task | File | Skills |
|---|------|------|--------|
| 17.1 | إنشاء `DeliveryZone` entity @freezed | `lib/domain/entities/delivery_zone.dart` | flutter-layer-based-clean-architecture |
| 17.2 | إنشاء `DeliveryZoneRepository` abstract interface | `lib/domain/repositories/delivery_zone_repository.dart` | flutter-error-handling |
| 17.3 | إنشاء `DeliveryZoneDto` + fromJson/toDomain | `lib/infrastructure/dtos/delivery_zone_dto.dart` | — |
| 17.4 | إنشاء `DeliveryZoneRemoteDataSource` | `lib/infrastructure/datasources/remote/delivery_zone_remote_datasource.dart` | — |
| 17.5 | تنفيذ `DeliveryZoneRepositoryImpl` | `lib/infrastructure/repositories/delivery_zone_repository_impl.dart` | flutter-error-handling |
| 17.6 | إنشاء `AdminDeliveryZonesCubit` + State | `lib/application/admin/admin_delivery_zones_cubit.dart` | flutter-error-handling |
| 17.7 | تعديل `AdminDeliveryZonesScreen` — list + add/edit form | `lib/presentation/screens/admin/admin_delivery_zones_screen.dart` | flutter-widgets |
| 17.8 | إنشاء `DeliveryZoneFormScreen` | `lib/presentation/screens/admin/delivery_zone_form_screen.dart` | flutter-widgets |
| 17.9 | code generation | — | dart-tooling |
| 17.10 | flutter analyze + fix | — | dart-tooling |

### Phase 18: Business Profile
**الهدف:** ربط الملف التجاري بـ Supabase — بدل hardcoded data

| # | Task | File | Skills |
|---|------|------|--------|
| 18.1 | إنشاء `BusinessProfile` entity @freezed | `lib/domain/entities/business_profile.dart` | flutter-layer-based-clean-architecture |
| 18.2 | إنشاء `BusinessProfileRepository` abstract interface | `lib/domain/repositories/business_profile_repository.dart` | flutter-error-handling |
| 18.3 | إنشاء `BusinessProfileDto` + fromJson/toDomain | `lib/infrastructure/dtos/business_profile_dto.dart` | — |
| 18.4 | إنشاء `BusinessProfileRemoteDataSource` | `lib/infrastructure/datasources/remote/business_profile_remote_datasource.dart` | — |
| 18.5 | تنفيذ `BusinessProfileRepositoryImpl` | `lib/infrastructure/repositories/business_profile_repository_impl.dart` | flutter-error-handling |
| 18.6 | إنشاء `AdminBusinessProfileCubit` + State | `lib/application/admin/admin_business_profile_cubit.dart` | flutter-error-handling |
| 18.7 | تعديل `AdminBusinessProfileScreen` — load/save real data + busy mode toggle + accept orders toggle | `lib/presentation/screens/admin/admin_business_profile_screen.dart` | flutter-widgets |
| 18.8 | إنشاء `OpeningHoursEditor` widget | `lib/presentation/widgets/opening_hours_editor.dart` | flutter-widgets |
| 18.9 | code generation | — | dart-tooling |
| 18.10 | flutter analyze + fix | — | dart-tooling |

### Phase 19: Reports & Analytics (Real Data)
**الهدف:** تقارير حقيقية من Supabase — revenue, orders, top products

| # | Task | File | Skills |
|---|------|------|--------|
| 19.1 | إنشاء `ReportRepository` abstract interface | `lib/domain/repositories/report_repository.dart` | flutter-error-handling |
| 19.2 | إنشاء `ReportRemoteDataSource` — aggregation queries | `lib/infrastructure/datasources/remote/report_remote_datasource.dart` | — |
| 19.3 | تنفيذ `ReportRepositoryImpl` | `lib/infrastructure/repositories/report_repository_impl.dart` | flutter-error-handling |
| 19.4 | إنشاء `AdminReportsCubit` + State | `lib/application/admin/admin_reports_cubit.dart` | flutter-error-handling |
| 19.5 | تعديل `AdminReportsScreen` — real KPIs + charts + date filters | `lib/presentation/screens/admin/admin_reports_screen.dart` | flutter-widgets |
| 19.6 | إنشاء `DateRangeFilter` widget | `lib/presentation/widgets/date_range_filter.dart` | flutter-widgets |
| 19.7 | إنشاء `DashboardChart` widget (revenue line chart) | `lib/presentation/widgets/dashboard_chart.dart` | flutter-widgets |
| 19.8 | إضافة Export to CSV | `lib/core/utils/csv_exporter.dart` | — |
| 19.9 | flutter analyze + fix | — | dart-tooling |

### Phase 20: Product Modifiers/Options
**الهدف:** تخصيص المنتجات — sizes, extras, variants, removals

| # | Task | File | Skills |
|---|------|------|--------|
| 20.1 | إنشاء `ProductOption` entity @freezed | `lib/domain/entities/product_option.dart` | flutter-layer-based-clean-architecture |
| 20.2 | تحديث `Product` entity — add options list | `lib/domain/entities/product.dart` | flutter-layer-based-clean-architecture |
| 20.3 | إنشاء `ProductOptionRepository` abstract interface | `lib/domain/repositories/product_option_repository.dart` | flutter-error-handling |
| 20.4 | إنشاء `ProductOptionDto` + fromJson/toDomain | `lib/infrastructure/dtos/product_option_dto.dart` | — |
| 20.5 | إنشاء `ProductOptionRemoteDataSource` | `lib/infrastructure/datasources/remote/product_option_remote_datasource.dart` | — |
| 20.6 | تنفيذ `ProductOptionRepositoryImpl` | `lib/infrastructure/repositories/product_option_repository_impl.dart` | flutter-error-handling |
| 20.7 | إنشاء `AdminProductOptionsCubit` + State | `lib/application/admin/admin_product_options_cubit.dart` | flutter-error-handling |
| 20.8 | تعديل `AdminProductFormScreen` — add options section | `lib/presentation/screens/admin/admin_product_form_screen.dart` | flutter-widgets |
| 20.9 | تعديل `ProductDetailScreen` — show options | `lib/presentation/screens/product/product_detail_screen.dart` | flutter-widgets |
| 20.10 | code generation | — | dart-tooling |
| 20.11 | flutter analyze + fix | — | dart-tooling |

### Phase 21: Thermal Printer
**الهدف:** طباعة الطلبات عبر Bluetooth thermal printer

| # | Task | File | Skills |
|---|------|------|--------|
| 21.1 | إضافة `esc_pos_printer` package | `pubspec.yaml` | — |
| 21.2 | إنشاء `ThermalPrinterService` | `lib/core/services/thermal_printer_service.dart` | — |
| 21.3 | إنشاء `PrintRepository` abstract interface | `lib/domain/repositories/print_repository.dart` | flutter-error-handling |
| 21.4 | تنفيذ `PrintRepositoryImpl` | `lib/infrastructure/repositories/print_repository_impl.dart` | flutter-error-handling |
| 21.5 | إضافة زر "طباعة" في `AdminOrderDetailScreen` | `lib/presentation/screens/admin/admin_order_detail_screen.dart` | flutter-widgets |
| 21.6 | إنشاء `PrinterSettingsScreen` | `lib/presentation/screens/admin/printer_settings_screen.dart` | flutter-widgets |
| 21.7 | flutter analyze + fix | — | dart-tooling |

### Phase 22: Real-time Order Alerts
**الهدف:** صوت + اهتزاز على طلب جديد

| # | Task | File | Skills |
|---|------|------|--------|
| 22.1 | إضافة `flutter_local_notifications` package | `pubspec.yaml` | — |
| 22.2 | إنشاء `NotificationService` | `lib/core/services/notification_service.dart` | — |
| 22.3 | إضافة sound + vibration على طلب جديد | `lib/application/admin/admin_orders_cubit.dart` | — |
| 22.4 | إنشاء `AdminNotificationScreen` — notification history | `lib/presentation/screens/admin/admin_notifications_screen.dart` | flutter-widgets |
| 22.5 | flutter analyze + fix | — | dart-tooling |

### Phase 23: Dashboard Enhancement
**الهدف:** تحسين Dashboard — 8 KPI cards + real charts + time filters

| # | Task | File | Skills |
|---|------|------|--------|
| 23.1 | تعديل `AdminDashboardScreen` — 8 KPI cards | `lib/presentation/screens/admin/admin_dashboard_screen.dart` | flutter-widgets |
| 23.2 | إضافة Revenue Chart (Line) | `lib/presentation/widgets/dashboard_revenue_chart.dart` | flutter-widgets |
| 23.3 | إضافة Top Products Chart (Pie) | `lib/presentation/widgets/dashboard_top_products_chart.dart` | flutter-widgets |
| 23.4 | إضافة Orders Volume Chart (Bar) | `lib/presentation/widgets/dashboard_orders_chart.dart` | flutter-widgets |
| 23.5 | إضافة Time Filter Chips (today/7d/30d/90d/custom) | `lib/presentation/widgets/time_filter_chips.dart` | flutter-widgets |
| 23.6 | flutter analyze + fix | — | dart-tooling |

### Phase 24: Admin Shell Enhancement
**الهدف:** تحسين الـ Admin Shell — إضافة tabs جديدة

| # | Task | File | Skills |
|---|------|------|--------|
| 24.1 | إضافة tab: Reports | `lib/presentation/screens/admin/admin_shell.dart` | flutter-navigation |
| 24.2 | إضافة tab: Customers | `lib/presentation/screens/admin/admin_shell.dart` | flutter-navigation |
| 24.3 | إضافة tab: Settings | `lib/presentation/screens/admin/admin_shell.dart` | flutter-navigation |
| 24.4 | flutter analyze + fix | — | dart-tooling |

### Phase 25: Polish & Finalize Admin Enhancement
**الهدف:** Dark mode، RTL، tests

| # | Task | File | Skills |
|---|------|------|--------|
| 25.1 | Dark theme audit — كل admin screens | — | flutter-design-system |
| 25.2 | RTL layout audit — كل admin screens | — | flutter-adaptive-ui |
| 25.3 | Performance audit — const, ListView.builder | — | flutter-performance |
| 25.4 | Security audit — admin screens, no PII leaks | — | flutter-security |
| 25.5 | Unit tests — new cubits, repositories | — | flutter-testing |
| 25.6 | Widget tests — new admin screens | — | flutter-testing |
| 25.7 | Final flutter analyze — 0 errors, 0 warnings | — | dart-tooling |

---

## 📁 Supabase Schema Updates

### New Tables:

```sql
-- coupons
CREATE TABLE coupons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL,
  type text NOT NULL CHECK (type IN ('percentage', 'fixed')),
  value numeric NOT NULL,
  min_order numeric DEFAULT 0,
  max_discount numeric,
  max_uses integer,
  used_count integer DEFAULT 0,
  start_date timestamptz,
  end_date timestamptz,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- delivery_zones
CREATE TABLE delivery_zones (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  fee numeric NOT NULL DEFAULT 0,
  min_order numeric DEFAULT 0,
  estimated_time text,
  is_active boolean DEFAULT true,
  coordinates jsonb,
  created_at timestamptz DEFAULT now()
);

-- business_profiles
CREATE TABLE business_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  phone text,
  address text,
  logo_url text,
  opening_hours jsonb,
  min_order numeric DEFAULT 0,
  default_prep_time integer DEFAULT 30,
  is_busy boolean DEFAULT false,
  busy_message text,
  accept_orders boolean DEFAULT true,
  updated_at timestamptz DEFAULT now()
);

-- audit_logs
CREATE TABLE audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id uuid REFERENCES profiles(id),
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id text,
  old_values jsonb,
  new_values jsonb,
  ip_address text,
  created_at timestamptz DEFAULT now()
);

-- product_options
CREATE TABLE product_options (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  name text NOT NULL,
  name_ar text,
  price_delta numeric DEFAULT 0,
  is_required boolean DEFAULT false,
  max_selections integer DEFAULT 1,
  sort_order integer DEFAULT 0
);

-- order_prints
CREATE TABLE order_prints (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id),
  printed_at timestamptz DEFAULT now(),
  print_count integer DEFAULT 1
);
```

---

## 🗄️ New Domain Entities

| Entity | Fields |
|--------|--------|
| **Coupon** | id, code, type (percentage/fixed), value, minOrder, maxDiscount, maxUses, usedCount, startDate, endDate, isActive |
| **Customer** | id, name, email, phone, avatarUrl, totalOrders, totalSpent, lastOrderAt, createdAt |
| **DeliveryZone** | id, name, fee, minOrder, estimatedTime, isActive, coordinates (List<LatLng>) |
| **BusinessProfile** | id, name, phone, address, logoUrl, openingHours (Map<String, OpenHours>), minOrder, defaultPrepTime, isBusy, busyMessage, acceptOrders |
| **ProductOption** | id, productId, name, nameAr, priceDelta, isRequired, maxSelections, sortOrder |
| **AuditLog** | id, adminId, action, entityType, entityId, oldValues, newValues, ipAddress, createdAt |

---

## 📡 Phase 26: Realtime Admin Panel (Living Data)

### Goal
All admin screens auto-update when data changes in Supabase. No manual refresh needed.

### Architecture Pattern
```
Supabase Realtime → watch*() DataSource → watch*() Repository → Cubit StreamSubscription → UI
```

### Tables Requiring Realtime Enablement
```sql
alter publication supabase_realtime add table categories;
alter publication supabase_realtime add table products;
alter publication supabase_realtime add table coupons;
alter publication supabase_realtime add table profiles;
alter publication supabase_realtime add table delivery_zones;
alter publication supabase_realtime add table business_profiles;
```

### Files to Modify (20 tasks)

**Data Sources (6 files):**
1. `lib/infrastructure/datasources/remote/category_remote_datasource.dart` — add `watchCategories()`
2. `lib/infrastructure/datasources/remote/product_remote_datasource.dart` — add `watchProducts()`
3. `lib/infrastructure/datasources/remote/coupon_remote_datasource.dart` — add `watchCoupons()`
4. `lib/infrastructure/datasources/remote/customer_remote_datasource.dart` — add `watchCustomers()`
5. `lib/infrastructure/datasources/remote/delivery_zone_remote_datasource.dart` — add `watchDeliveryZones()`
6. `lib/infrastructure/datasources/remote/business_profile_remote_datasource.dart` — add `watchBusinessProfile()`

**Domain Repositories (6 interfaces + 6 implementations):**
7. `lib/domain/repositories/category_repository.dart` — add `watchCategories()`
8. `lib/infrastructure/repositories/category_repository_impl.dart` — implement stream mapping
9. `lib/domain/repositories/product_repository.dart` — add `watchProducts()`
10. `lib/infrastructure/repositories/product_repository_impl.dart` — implement stream mapping
11. `lib/domain/repositories/coupon_repository.dart` — add `watchCoupons()`
12. `lib/infrastructure/repositories/coupon_repository_impl.dart` — implement stream mapping
13. `lib/domain/repositories/customer_repository.dart` — add `watchCustomers()`
14. `lib/infrastructure/repositories/customer_repository_impl.dart` — implement stream mapping
15. `lib/domain/repositories/delivery_zone_repository.dart` — add `watchDeliveryZones()`
16. `lib/infrastructure/repositories/delivery_zone_repository_impl.dart` — implement stream mapping
17. `lib/domain/repositories/business_profile_repository.dart` — add `watchProfile()`
18. `lib/infrastructure/repositories/business_profile_repository_impl.dart` — implement stream mapping

**Application Cubits (7 files):**
19. `lib/application/admin/admin_categories_cubit.dart` — subscribe + cleanup
20. `lib/application/admin/admin_products_cubit.dart` — subscribe + cleanup
21. `lib/application/admin/admin_coupons_cubit.dart` — subscribe + cleanup
22. `lib/application/admin/admin_customers_cubit.dart` — subscribe + cleanup
23. `lib/application/admin/admin_delivery_zones_cubit.dart` — subscribe + cleanup
24. `lib/application/admin/admin_business_profile_cubit.dart` — subscribe + cleanup
25. `lib/application/admin/admin_reports_cubit.dart` — Timer.periodic(30s) auto-refresh

**Reports Exception:**
Reports use aggregated queries (SUM, COUNT, AVG). Cannot use row-level realtime.
Solution: `Timer.periodic(Duration(seconds: 30), (_) => loadReports(...))`
Cancel timer in `close()`.

### Critical Implementation Pattern
```dart
// In every Cubit:
StreamSubscription? _subscription;

void _listenToStream() {
  _subscription?.cancel();
  _subscription = _repository.watchX().listen(
    (data) {
      if (!isClosed) emit(state.copyWith(items: data, status: loaded));
    },
    onError: (e) {
      if (!isClosed) emit(state.copyWith(failure: Failure.unexpected(message: e.toString())));
    },
  );
}

@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}
```

### Anti-Patterns to Avoid
- ❌ Don't forget to cancel subscriptions → memory leak
- ❌ Don't emit after Cubit is closed → crash
- ❌ Don't use realtime for Reports → wrong architecture
- ❌ Don't create duplicate subscriptions → navigate away/back bug

---

## 🎯 How to Execute

1. ابدأ من **Phase 26** (أول `[ ]` في `PROGRESS.md`)
2. كل phase: domain → infrastructure → application → presentation
3. بعد كل phase: `flutter analyze`
4. بعد كل 3 phases: `dart run build_runner build --delete-conflicting-outputs`
5. في نهاية كل شاشة: test على emulator
6. لا تبدأ phase جديدة قبل ما تخلص اللي قبله

---

## ⚠️ Critical Rules

- **ممنوع hardcoded data** في أي admin screen جديد
- **كل شاشة لازم يكون ليها Cubit** خاص بيها
- **كل form لازم validation** حقيقي
- **كل action لازم يظهر feedback** (SnackBar/Dialog)
- **كل loading state لازم يظهر** (CircularProgressIndicator/Skeleton)
- **ممنوع business logic في screens** — في Cubits بس
- **ممنوع print()** — استخدم appLogger
