# Customer Coupon Integration Plan

## What Exists
- **Domain**: `Coupon` entity, `CouponType` enum, `CouponRepository` interface — fully built
- **Infrastructure**: `CouponRemoteDataSource`, `CouponRepositoryImpl`, `CouponDTO` — CRUD + realtime done
- **Admin**: `AdminCouponsCubit` + admin CRUD screens — done
- **Place Order API**: `placeOrder()` already accepts `couponId` + `discountAmount` params
- **Order entity**: Has `couponId` + `discountAmount` fields
- **OrderDetailScreen**: Shows discount line when `discountAmount > 0`
- **CouponInput widget**: Built but orphaned — ready to drop into checkout

## What's Missing
- No `getByCode` query on the data source/repo
- No customer-facing cubit to validate coupons
- `CartState` has no coupon awareness
- `CheckoutScreen` doesn't include coupon input, doesn't pass coupon data to `placeOrder`

## Approach

### 1. Add `getByCode` to Data Source + Repository

**File: `lib/infrastructure/datasources/remote/coupon_remote_datasource.dart`**
- Add `Future<CouponDTO?> getByCode(String code)` — queries `_client.from('coupons').select().eq('code', code).maybeSingle()`

**File: `lib/domain/repositories/coupon_repository.dart`**
- Add `Future<Either<Failure, Coupon?>> getByCode(String code);`

**File: `lib/infrastructure/repositories/coupon_repository_impl.dart`**
- Implement `getByCode` — call datasource, map to domain, catch → `left(Failure)`

### 2. Create Customer-Facing `CouponCubit`

**NEW: `lib/application/coupon/coupon_cubit.dart`**

State:
- `Coupon? appliedCoupon` — validated & applied
- `double discountAmount` — calculated discount in EGP
- `CouponStatus status` — initial, validating, applied, error, removing
- `String? errorMessage` — Arabic error message

Methods:
- `void validateAndApply(String code, double orderTotal)` — validates via repo, calculates discount
- `void removeCoupon()` — resets to initial

**Validation rules (in cubit):**
| Check | Arabic Error |
|---|---|
| Coupon not found | "كود الخصم غير صالح" |
| `isActive == false` | "الكود غير فعال" |
| Before `startDate` or after `endDate` | "الكود منتهي الصلاحية" |
| `maxUses != null && usedCount >= maxUses` | "الكود وصل للحد الأقصى من الاستخدام" |
| `orderTotal < minOrder` | "الحد الأدنى للطلب ${minOrder} ج" |
| All pass | Calculate discount, emit success |

**Discount calculation:**
- `percentage`: `discount = orderTotal * (value / 100)`, capped at `maxDiscount` if set
- `fixed`: `discount = value`, capped at `orderTotal`

### 3. Add Coupon State to CartCubit

**File: `lib/application/cart/cart_cubit.dart`**

Add to `CartState`:
- `String? appliedCouponId`
- `double discountAmount`
- `double get finalTotal => (total - discountAmount).clamp(0, double.infinity)`

Add methods:
- `void applyCoupon(String couponId, double discountAmount)`
- `void removeCoupon()`
- Update `clearCart()` to reset coupon

### 4. Integrate into CheckoutScreen

**File: `lib/presentation/screens/checkout/checkout_screen.dart`**

Changes:
1. Add `CouponCubit` import, `CouponInput` import
2. Add `_couponCodeController`, listen to `CouponCubit` state
3. Add `CouponInput` widget after order summary, before confirm button
4. Show applied coupon chip/badge with discount amount when coupon is active
5. Update order summary to show discount line + final total
6. `_placeOrder()`: Pass `couponId` + `discountAmount` from cart state

### 5. Register in DI

**File: `lib/core/di/injection_container.dart`**
```dart
sl.registerFactory<CouponCubit>(() => CouponCubit(sl<CouponRepository>()));
```

### 6. Increment Coupon Usage on Order Placement

After `_placeOrder()` succeeds, increment `used_count`:
- Add `incrementUsage(String couponId)` to `CouponRepository` and `CouponRemoteDataSource`
- Fire-and-forget after order placement

## Files Changed

| File | Action |
|---|---|
| `lib/domain/repositories/coupon_repository.dart` | Add `getByCode`, `incrementUsage` |
| `lib/infrastructure/datasources/remote/coupon_remote_datasource.dart` | Add `getByCode`, `incrementUsage` |
| `lib/infrastructure/repositories/coupon_repository_impl.dart` | Implement new methods |
| `lib/application/coupon/coupon_cubit.dart` | **NEW** — Customer coupon cubit |
| `lib/application/cart/cart_cubit.dart` | Add coupon fields to state + methods |
| `lib/core/di/injection_container.dart` | Register `CouponCubit` factory |
| `lib/presentation/screens/checkout/checkout_screen.dart` | Integrate coupon input + summary |

## Verification
1. `flutter analyze` — must pass with 0 errors, 0 warnings
2. Add items to cart → checkout → enter valid coupon → discount appears → place order → order detail shows discount
3. Enter invalid/expired/exhausted codes → verify Arabic error messages
4. Apply then remove coupon → verify discount disappears
5. Order total below minOrder → verify appropriate error
