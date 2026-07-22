# AGENTS.md — Tarwi2a (ترويئه) Food Ordering App

> ## ⚡ START HERE — كل سيشن جديدة
> 1. **اقرا `PROGRESS.md`** — هتلاقي أول `[ ]` = اللي لسه متعملش
> 2. **اقرا `PLAN.md`** — فيه الخطة الكاملة + السكيلز المطلوبة + تصميم كل شاشة
> 3. **حمّل السكيلز** المكتوبة في `PLAN.md` قبل ما تبدأ
> 4. **اشتغل من أول `[ ]` في `PROGRESS.md`** — حول `[ ]` إلى `[✓]` لما تخلص
> 5. **حدث `Current State` في `PROGRESS.md`** — لو وقفت في النص، اكتب نواقصك
> 6. **شغّل `flutter analyze`** في نهاية كل Phase

## Project Overview

Arabic food ordering app with customer-facing menu/cart/orders and admin panel (dashboard, order management, menu CRUD). Built with **Flutter 3.3+**, **Supabase** backend, **Layer-Based Clean Architecture**.

## Tech Stack

| Concern | Package |
|---|---|
| State Management | `flutter_bloc` (8 Cubits) |
| DI | `get_it` |
| Entities | `freezed` (immutable, value equality) |
| Serialization | `json_serializable` |
| Functional Error Handling | `dartz` (`Either<Failure, T>`) |
| Routing | `go_router` |
| Backend | `supabase_flutter` (auth, DB, realtime) |
| Local Storage | `shared_preferences` (cart only) |
| Logging | `logger` |
| Code Gen | `build_runner` + `freezed` + `json_serializable` |
| Charts | `fl_chart` |
| Printing | `esc_pos_printer` (admin thermal printer) |

## Architecture: Layer-Based Clean Architecture

```
lib/
├── main.dart                         # Entry: Supabase init → DI init → MultiBlocProvider
├── app/theme/app_theme.dart          # Light + Dark themes, AppColors, AppSpacing, AppRadius
├── core/
│   ├── constants/app_constants.dart  # Strings only (URLs, payment/status/role constants)
│   ├── di/injection_container.dart   # get_it bindings (sl)
│   └── logger/app_logger.dart        # appLogger instance
├── domain/                           # PURE DART — NO Flutter/infrastructure deps
│   ├── enums/                        # UserRole, OrderStatus, PaymentMethod
│   ├── entities/                     # @freezed: UserProfile, Category, Product, CartItem, Order, OrderItem
│   │                                   NEW: Coupon, DeliveryZone, BusinessProfile, AuditLog
│   ├── failures/                     # @freezed sealed: Failure (server|network|validation|unexpected)
│   └── repositories/                 # Abstract interfaces → return Either<Failure, T>
├── infrastructure/
│   ├── datasources/remote/           # Auth/Profile/Category/Product/Order RemoteDataSource
│   │                                   NEW: CouponRemoteDataSource, DeliveryZoneRemoteDataSource
│   │                                   NEW: BusinessProfileRemoteDataSource, AuditLogRemoteDataSource
│   ├── datasources/local/            # CartLocalDataSource (SharedPreferences)
│   ├── dtos/                         # DTOs with fromJson/toJson + toDomain() mapper
│   └── repositories/                 # Impls: map DTO→Entity, catch → left(Failure)
├── application/
│   ├── auth/auth_cubit.dart          # AuthCubit + AuthState
│   ├── menu/                         # CategoriesCubit + ProductsCubit
│   ├── cart/cart_cubit.dart          # CartCubit (local persistence via CartLocalDataSource)
│   ├── orders/                       # CustomerOrdersCubit (load + placeOrder)
│   └── admin/                        # AdminOrdersCubit, AdminCategoriesCubit, AdminProductsCubit
│                                       NEW: AdminCouponsCubit, AdminCustomersCubit
│                                       NEW: AdminReportsCubit, AdminDeliveryZonesCubit
│                                       NEW: AdminBusinessProfileCubit, AdminAuditLogCubit
└── presentation/
    ├── extensions/                   # OrderStatusX (.arabicLabel, .color), PaymentMethodX (.arabicLabel)
│                                       NEW: CouponTypeX, ZoneTypeX
    ├── widgets/                      # ProductCard, CategoryChip, EmptyState, ErrorBanner, etc.
│                                       NEW: DashboardChart, CustomerCard, CouponTile, ZoneMap
    └── screens/                      # 15 screens under splash/auth/home/product/cart/checkout/orders/admin/
│                                       NEW: Admin customer, coupon backend, reports real data
│                                       NEW: KDS, delivery zones, audit log, settings
```

### Dependency Flow
```
Presentation → Application (Cubits) → Domain (Entities + Repo Interfaces) ← Infrastructure (Impls)
```
Dependencies point **inward**. Domain has zero imports from other layers.

## Key Conventions

### 1. Dependency Injection
```dart
// Always use sl<T>() to resolve, NEVER construct manually
final authCubit = sl<AuthCubit>();

// Register in injection_container.dart:
//   DataSources → LazySingleton
//   Repositories → LazySingleton  
//   Cubits → Factory (new instance per scope)
```

### 2. BLoC State Pattern
```dart
// Cubit state: class with copyWith, Equatable
class MyState extends Equatable {
  final List<Item> items;
  final MyStatus status;
  // ...
  @override List<Object?> get props => [items, status];
}

// Status enum: initial → loading → loaded → error
enum MyStatus { initial, loading, loaded, error }
```

### 3. Entities
All `@freezed` — immutable, `==` / `hashCode` / `copyWith` auto-generated.
```dart
// CartItem stores productId + name/price snapshot (not full Product object)
// Order uses enums (OrderStatus, PaymentMethod), NOT strings
// Localization helpers (arabicLabel, color) are presentation extensions
```

### 4. Error Handling
```dart
// Repositories return Either<Failure, T>
final result = await repo.method();
result.fold(
  (failure) => emit(state.copyWith(status: MyStatus.error, failure: failure)),
  (data)    => emit(state.copyWith(status: MyStatus.loaded, data: data)),
);
```

### 5. DTO → Entity Mapping
```dart
// In repository impl: DTOs from data source → map to domain entities
dtos.map((dto) => dto.toDomain()).toList()
```

### 6. Screen Pattern
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCubit, MyState>(
      builder: (context, state) {
        return switch (state.status) {
          MyStatus.loading => const CircularProgressIndicator(),
          MyStatus.loaded  => ListView(/* state.items */),
          MyStatus.error   => Text(state.failure?.message ?? ''),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
```
- **No business logic** in screens. Widgets only display state and emit events.
- **No direct datasource calls** from screens. Always through Cubits.
- Screens are `StatelessWidget` + `BlocBuilder`/`BlocConsumer`.
- Widgets with local form state use `StatefulWidget` + `BlocBuilder`.

### 7. Routing
```dart
// go_router with auth redirect guard, fade+slide transitions
// Route extras pass domain entities (Product, Order)
// Admin uses StatefulShellRoute.indexedStack for bottom nav tabs
```

### 8. Logging
```dart
import '../../core/logger/app_logger.dart';
appLogger.d('message');  // debug
appLogger.e('error', error: e, stackTrace: s);  // errors
```

### 9. Admin Panel Conventions
```dart
// All admin screens use AppTopBar with variant: TopBarVariant.withBack
// Admin forms use SectionCard for grouped fields
// Admin lists use ListView.builder with pull-to-refresh
// Admin actions show SnackBar confirmation
// Admin CRUD follows: load → edit → save → reload pattern
```

### 10. Realtime / Live Data Pattern (Phase 26+)
All admin list screens use Supabase Realtime for automatic updates.

**DataSource Layer:**
```dart
Stream<List<CategoryDTO>> watchCategories() {
  return _client.from('categories').stream(primaryKey: ['id']).map(
    (data) => data.map((json) => CategoryDTO.fromJson(json)).toList(),
  );
}
```

**Repository Layer:**
```dart
Stream<List<Category>> watchCategories() {
  return _remoteDataSource.watchCategories().map(
    (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
  );
}
```

**Cubit Layer:**
```dart
class AdminCategoriesCubit extends Cubit<AdminCategoriesState> {
  StreamSubscription? _subscription;
  
  Future<void> loadCategories() async {
    // ... existing load logic ...
    _listenToStream();
  }
  
  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _repository.watchCategories().listen(
      (categories) {
        if (!isClosed) emit(state.copyWith(categories: categories, status: loaded));
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
}
```

**Reports Exception:** Reports use `Timer.periodic(Duration(seconds: 30), ...)` instead of realtime because they show aggregated data (SUM, COUNT, AVG).

**Critical Rules:**
- Always cancel `_subscription` in `close()` — memory leak otherwise
- Always check `!isClosed` before emitting — prevent crash
- Use `StreamSubscription?` (nullable) — safe to call cancel multiple times
- Reports = Timer, Lists = Realtime Stream

## How to Add a New Feature

1. **Domain**: Define `@freezed` entity in `lib/domain/entities/`
2. **Domain**: Add repository interface in `lib/domain/repositories/`
3. **Infrastructure**: Create DTO in `lib/infrastructure/dtos/` with `fromJson`/`toDomain()`
4. **Infrastructure**: Create data source in `lib/infrastructure/datasources/`
5. **Infrastructure**: Implement repository in `lib/infrastructure/repositories/`
6. **Application**: Create Cubit in `lib/application/`
7. **DI**: Register all new types in `lib/core/di/injection_container.dart`
8. **Presentation**: Build screen using `BlocBuilder`
9. **Router**: Add route in `lib/router/app_router.dart`
10. **Supabase**: Add table/columns if needed

## Anti-Patterns (Do NOT Do)
- **No `print()`** — use `appLogger.d()`/`appLogger.e()`
- **No `Flutter/material.dart` in domain** layer
- **No `data/models/models.dart`** — that file no longer exists
- **No DTO in UI** — widgets import only from `domain/entities/`
- **No direct datasource/repository calls from screens** — always through Cubits
- **No Riverpod** — project uses BLoC only
- **No string status/payment comparisons** — use enums (`OrderStatus.pending`, etc.)
- **No hardcoded data in admin screens** — always load from Cubit
- **No business logic in admin forms** — validation only

## Code Generation
```bash
# Run after adding/editing any @freezed or @JsonSerializable class
dart run build_runner build --delete-conflicting-outputs
```

## Supabase Schema
Tables: `profiles`, `categories`, `products`, `orders`, `order_items` (with RLS).
Auth trigger auto-creates profiles on signup.
Realtime enabled on `orders` table.

### NEW Tables for Admin Enhancement:
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
  coordinates jsonb, -- polygon coordinates
  created_at timestamptz DEFAULT now()
);

-- business_profiles
CREATE TABLE business_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  phone text,
  address text,
  logo_url text,
  opening_hours jsonb, -- { "saturday": { "open": "10:00", "close": "22:00" } }
  min_order numeric DEFAULT 0,
  default_prep_time integer DEFAULT 30, -- minutes
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

-- product_options (for modifiers)
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

-- order_prints (for thermal printer tracking)
CREATE TABLE order_prints (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id),
  printed_at timestamptz DEFAULT now(),
  print_count integer DEFAULT 1
);
```

## Admin Setup
```sql
UPDATE profiles SET role = 'admin' WHERE id = '<USER_UUID>';
```

## Verification
```bash
flutter analyze  # Must pass with 0 errors, 0 warnings
```
