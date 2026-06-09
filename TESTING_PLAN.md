# Testing Plan: All Blocs (Cubits) & States

> **Goal:** Ensure every Cubit is registered in DI, every state transition is tested, and every state class has equality/serialization tests.

---

## 1. Cubit Inventory & Test Coverage Audit

| # | Cubit | DI Registered | Has Unit Test | Has State Test | Test File |
|---|-------|--------------|---------------|----------------|-----------|
| 1 | `AuthCubit` | ✅ | ✅ | ✅ (auth_state_test.dart) | `test/application/auth/auth_cubit_test.dart` |
| 2 | `CategoriesCubit` | ✅ | ✅ | ❌ | `test/application/menu/categories_cubit_test.dart` |
| 3 | `ProductsCubit` | ✅ | ✅ | ❌ | `test/application/menu/products_cubit_test.dart` |
| 4 | `CartCubit` | ✅ | ✅ | ✅ (in cubit test) | `test/application/cart/cart_cubit_test.dart` |
| 5 | `CustomerOrdersCubit` | ✅ | ✅ | ❌ | `test/application/orders/customer_orders_cubit_test.dart` |
| 6 | `AdminOrdersCubit` | ✅ | ✅ | ❌ | `test/application/admin/admin_orders_cubit_test.dart` |
| 7 | `AdminCategoriesCubit` | ✅ | ✅ | ❌ | `test/application/admin/admin_categories_cubit_test.dart` |
| 8 | `AdminProductsCubit` | ✅ | ✅ | ❌ | `test/application/admin/admin_products_cubit_test.dart` |
| 9 | `ThemeCubit` | ✅ | ❌ | ❌ | **MISSING** |
| 10 | `AddressCubit` | ✅ | ❌ | ❌ | **MISSING** |
| 11 | `AdminCouponsCubit` | ✅ | ✅ | ❌ | `test/application/admin/admin_coupons_cubit_test.dart` |
| 12 | `AdminCustomersCubit` | ✅ | ❌ | ❌ | **MISSING** |
| 13 | `AdminDeliveryZonesCubit` | ✅ | ❌ | ❌ | **MISSING** |
| 14 | `AdminBusinessProfileCubit` | ✅ | ✅ | ❌ | `test/application/admin/admin_business_profile_cubit_test.dart` |
| 15 | `AdminReportsCubit` | ✅ | ✅ | ❌ | `test/application/admin/admin_reports_cubit_test.dart` |
| 16 | `AdminProductOptionsCubit` | ✅ | ❌ | ❌ | **MISSING** |

**Summary:**
- **Total Cubits:** 16
- **With Unit Tests:** 11 (69%)
- **Missing Unit Tests:** 5 (31%)
- **Missing State Tests:** 14 (most states only tested via cubit tests, not standalone)

---

## 2. What To Test For Each Cubit

### A. State Class Tests (for every state class)
Every `Equatable` state needs standalone tests for:
1. **Initial state factory** — `XState.initial()` returns correct defaults
2. **copyWith** — each field can be updated independently; `null` leaves value unchanged
3. **Equality (props)** — two instances with same values are equal; different values are not equal
4. **Computed properties** — getters like `CartState.total`, `CartState.totalItems`

### B. Cubit Tests (for every cubit)
Test groups follow this pattern:

```dart
group('XxxCubit', () {
  // 1. Initial state
  group('initial state', () { ... });

  // 2. Load / Fetch operations
  group('loadXxx', () {
    test('emits [loading, loaded] on success', () { ... });
    test('emits [loading, error] on failure', () { ... });
    test('emits [loaded] with empty list when no data', () { ... });
  });

  // 3. Create / Update / Delete mutations
  group('createXxx', () { ... });
  group('updateXxx', () { ... });
  group('deleteXxx', () { ... });

  // 4. Search / Filter (if applicable)
  group('search', () { ... });

  // 5. Stream / Realtime subscriptions (if applicable)
  group('realtime subscription', () {
    test('cancels previous subscription before starting new one', () { ... });
    test('emits updated data on stream event', () { ... });
    test('emits error on stream error', () { ... });
    test('does not emit after close()', () { ... });
  });

  // 6. Timer-based refresh (Reports only)
  group('timer refresh', () { ... });

  // 7. close() cleanup
  group('close', () {
    test('cancels subscription', () { ... });
  });
});
```

---

## 3. Missing Test Files to Create

### 3.1 `test/application/theme/theme_cubit_test.dart`
- Test initial state is `ThemeMode.system`
- Test `_load()` reads from SharedPreferences and emits correct mode
- Test `setThemeMode()` emits new mode and persists to SharedPreferences
- Mock `SharedPreferences` using `shared_preferences` test helpers

### 3.2 `test/application/address/address_cubit_test.dart`
- Test `loadAddresses()` — success → `loaded` with addresses; failure → `error`
- Test `createAddress()` — success reloads addresses; failure → `error`
- Test `updateAddress()` — success reloads; failure → `error`
- Test `deleteAddress()` — success reloads; failure → `error`
- Test `setDefault()` — success reloads; failure → `error`
- Test state transitions: `initial` → `loading` → `loaded` → `saving` → `loaded`

### 3.3 `test/application/admin/admin_customers_cubit_test.dart`
- Test `loadCustomers()` — success → `loaded`; failure → `error`
- Test `search()` filters correctly by name and phone
- Test realtime stream: new customer list updates UI
- Test `close()` cancels `_subscription`
- Test `_listenToStream()` applies current search filter to streamed data

### 3.4 `test/application/admin/admin_delivery_zones_cubit_test.dart`
- Test `loadZones()` — success → `loaded`; failure → `error`
- Test `upsert()` — success calls `loadZones()`; failure → `error`
- Test `toggleActive()` — success calls `loadZones()`; failure → `error`
- Test `delete()` — success calls `loadZones()`; failure → `error`
- Test realtime stream updates
- Test `close()` cancels subscription

### 3.5 `test/application/admin/admin_product_options_cubit_test.dart`
- Test `loadByProductId()` — success → `loaded` with options; failure → `error`
- Test `upsert()` delegates to repository
- Test `delete()` delegates to repository
- **Note:** This cubit does NOT have realtime subscriptions, so no stream tests needed.

---

## 4. Existing Tests to Enhance

### 4.1 Add Standalone State Tests
Create `test/application/{folder}/xxx_state_test.dart` for each of these states:
- `AuthState` (already exists — `auth_state_test.dart` ✅)
- `CartState` — test `copyWith`, `total`, `totalItems` (already in cubit test but extract)
- `CategoriesState`, `ProductsState`, `CustomerOrdersState`, `AdminOrdersState`
- `AdminCategoriesState`, `AdminProductsState`, `AdminCouponsState`
- `AdminCustomersState`, `AdminDeliveryZonesState`, `AdminBusinessProfileState`
- `AdminReportsState`, `AdminProductOptionsState`, `AddressState`

### 4.2 Enhance Existing Cubit Tests with Missing Scenarios
- **AuthCubit:** Test `authStateChanges` handles `tokenRefreshed` and `userUpdated` events (currently only tests `signedIn`/`signedOut`)
- **CartCubit:** Test `addItem` with `selectedOptions` (options equality logic)
- **AdminCategoriesCubit:** Test realtime stream emissions
- **AdminProductsCubit:** Test realtime stream with category filter
- **AdminCouponsCubit:** Test realtime stream emissions
- **AdminBusinessProfileCubit:** Test realtime single-item stream
- **AdminReportsCubit:** Test timer periodic load and `close()` timer cancellation

---

## 5. DI Verification Tests

Create `test/core/di/injection_container_test.dart` to verify:
1. Every repository interface resolves to a concrete implementation (`sl<AuthRepository>()` is not null)
2. Every cubit resolves correctly (`sl<AuthCubit>()` is not null)
3. Data sources resolve correctly
4. No duplicate registrations

---

## 6. Test Execution Plan

### Step 1: Create Missing Test Files (5 files)
```bash
# Create the 5 missing cubit test files
touch test/application/theme/theme_cubit_test.dart
touch test/application/address/address_cubit_test.dart
touch test/application/admin/admin_customers_cubit_test.dart
touch test/application/admin/admin_delivery_zones_cubit_test.dart
touch test/application/admin/admin_product_options_cubit_test.dart
```

### Step 2: Write Tests for Each
Follow the existing patterns in `test/application/auth/auth_cubit_test.dart` and `test/application/cart/cart_cubit_test.dart`:
- Use `mocktail` for mocking
- Use `test/helpers/test_helpers.dart` for fixtures and mock classes
- Group by method/behavior
- Verify state transitions with `expect(cubit.state, ...)` or `cubit.stream.listen()`

### Step 3: Add DI Verification Test
```bash
touch test/core/di/injection_container_test.dart
```

### Step 4: Run All Tests & Verify Coverage
```bash
flutter test --coverage
```

### Step 5: Target Metrics
| Metric | Current | Target |
|--------|---------|--------|
| Cubit Test Coverage | 69% (11/16) | 100% (16/16) |
| State Test Coverage | ~10% | 100% (all states standalone) |
| All Tests Passing | 205/231 (89%) | 100% |

---

## 7. Required Mocks to Add in `test/helpers/test_helpers.dart`

The following mocks need to be added (or verified they exist):

```dart
class MockAddressRepository extends Mock implements AddressRepository {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Fallback values needed:
registerFallbackValue(ThemeMode.light);
registerFallbackValue(<Address>[]);
registerFallbackValue(<Customer>[]);
registerFallbackValue(<DeliveryZone>[]);
registerFallbackValue(<ProductOption>[]);
```

---

## 8. Quick Reference: State Pattern Checklist

For every state class, verify:
- [ ] `extends Equatable`
- [ ] Has `copyWith()` that supports nulling fields (if needed)
- [ ] `props` includes ALL fields (including lists)
- [ ] Has `initial()` factory
- [ ] Status enum covers: `initial`, `loading`, `loaded`, `error` (and `saving` for forms)

For every cubit class, verify:
- [ ] `extends Cubit<State>`
- [ ] Dependencies injected via constructor (no `sl<T>()` inside methods)
- [ ] No `print()` — uses `appLogger`
- [ ] Repository calls wrapped in `try/catch` or `Either` fold
- [ ] Stream subscriptions cancelled in `close()` (if applicable)
- [ ] `!isClosed` check before `emit()` in stream listeners
- [ ] No business logic in presentation layer

---

## 9. Files That Need Creation/Modification

### New Files (5):
1. `test/application/theme/theme_cubit_test.dart`
2. `test/application/address/address_cubit_test.dart`
3. `test/application/admin/admin_customers_cubit_test.dart`
4. `test/application/admin/admin_delivery_zones_cubit_test.dart`
5. `test/application/admin/admin_product_options_cubit_test.dart`

### Modified Files (2):
1. `test/helpers/test_helpers.dart` — add missing mocks and fallback values
2. `test/core/di/injection_container_test.dart` — DI verification (new)

---

*Plan generated on 2026-06-07. Ready for implementation.*
