# Fix: Order Creation Failure + Missing Notifications

## Diagnosis

### Bug 1 (CRITICAL): Checkout screen ignores order creation failures
- `checkout_screen.dart:119` calls `sl<CustomerOrdersCubit>().placeOrder(...)` which uses `Either<Failure, Order>` and **never throws**
- If the Supabase INSERT fails, the cubit emits `CustomerOrdersStatus.error`, but the checkout screen never checks this state
- The code proceeds to clear the cart, log "order created successfully", and show the success dialog — even when the order was NEVER created
- **Result:** User sees success, but order doesn't exist in Supabase, no notifications fire

### Bug 2 (DATA): `order_items` INSERT sends `selected_options` — a non-existent column
- `checkout_screen.dart:109` includes `selected_options` in the items data
- The `order_items` table has NO `selected_options` column
- Depending on PostgREST config, this either gets silently dropped (harmless) or causes the second INSERT to fail (order exists but has no items)

### Bug 3 (POTENTIAL): `order_type: 'dine_in'` violates CHECK constraint
- `OrderType` enum has `dineIn` = `'dine_in'`
- `orders` table CHECK only allows `('delivery', 'pickup')`
- A dine-in order causes a constraint violation → the entire insert fails

### Bug 4 (NOTIFICATION): DB trigger → Edge Function pipeline likely misconfigured
- `invoke_send_notification()` needs `app.settings.supabase_functions_url` and `app.settings.service_role_key` set in Postgres
- `send-notification` Edge Function needs Firebase env vars (`FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY`)
- If these aren't configured, notifications silently fail

### Bug 5 (ROBUSTNESS): Order + items not atomic
- `order_remote_data_source.dart` does two separate INSERTs (orders then order_items)
- If the first succeeds but the second fails, you get orphaned orders with no items

---

## Fix Plan

### Fix 1: Checkout screen checks cubit state after placeOrder

**File:** `lib/presentation/screens/checkout/checkout_screen.dart`

Replace the section after `placeOrder()` call to check cubit state:

```dart
final ordersCubit = sl<CustomerOrdersCubit>();
await ordersCubit.placeOrder(
  customerId: profile.id,
  customerName: _nameController.text.trim(),
  customerPhone: _phoneController.text.trim(),
  customerAddress: _orderType == OrderType.delivery
      ? _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim()
      : null,
  addressId: _selectedAddressId,
  notes: _notesController.text.trim().isEmpty
      ? null
      : _notesController.text.trim(),
  paymentMethod: _paymentMethod.value,
  totalAmount: cartState.finalTotal,
  items: items,
  scheduledFor: _scheduleOrder ? _scheduledDateTime : null,
  orderType: _orderType.value,
  couponId: cartState.appliedCouponId,
  discountAmount: cartState.discountAmount,
  deliveryFee: cartState.deliveryFee > 0 ? cartState.deliveryFee : null,
  deliveryZoneId: cartState.deliveryZoneId,
  deliveryZoneName: cartState.deliveryZoneName,
);

final orderState = ordersCubit.state;
if (orderState.status == CustomerOrdersStatus.error) {
  final errorMsg = orderState.failure?.message ?? 'حصل خطأ غير متوقع';
  appLogger.e('[CheckoutScreen] _placeOrder — order creation failed: $errorMsg');
  if (!mounted) return;
  HapticFeedback.heavyImpact();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('فشل إنشاء الطلب: $errorMsg'),
      backgroundColor: AppColors.error,
      duration: const Duration(seconds: 4),
    ),
  );
  return;
}

// Only proceed with success flow if order was actually placed
if (cartState.appliedCouponId != null) {
  await sl<CouponRepository>().incrementUsage(cartState.appliedCouponId!);
}

await sl<CustomerOrdersCubit>().loadOrders(profile.id);

if (!mounted) return;
context.read<CartCubit>().clearCart();
HapticFeedback.mediumImpact();
appLogger.i('[CheckoutScreen] _placeOrder — order created successfully, cart cleared');

if (!mounted) return;
_showSuccessDialog();
```

Also update the `catch` block to show the actual error:
```dart
} catch (e) {
  appLogger.e('[CheckoutScreen] _placeOrder — error: $e');
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('حصل خطأ: $e'),
      backgroundColor: AppColors.error,
      duration: const Duration(seconds: 4),
    ),
  );
}
```

### Fix 2: Add error logging in repository and datasource

**File:** `lib/infrastructure/repositories/order_repository_impl.dart`

Add logging in the `catch` block of `createOrder`:

```dart
} catch (e, st) {
  appLogger.e('[OrderRepository] createOrder failed', error: e, stackTrace: st);
  return left(Failure.unexpected(message: e.toString()));
}
```

Add import: `import '../../../core/logger/app_logger.dart';`

**File:** `lib/infrastructure/datasources/remote/order_remote_data_source.dart`

Add logging before and after Supabase calls:

```dart
Future<OrderDTO> createOrder({
  required Map<String, dynamic> orderData,
  required List<Map<String, dynamic>> itemsData,
}) async {
  appLogger.d('[OrderRemoteDataSource] createOrder — orderData keys: ${orderData.keys.toList()}');
  try {
    final result =
        await _client.from('orders').insert(orderData).select().single();
    final orderId = result['id'] as String;
    appLogger.d('[OrderRemoteDataSource] order inserted, id: $orderId');
    
    final orderItems =
        itemsData.map((item) => {...item, 'order_id': orderId}).toList();
    await _client.from('order_items').insert(orderItems);
    appLogger.d('[OrderRemoteDataSource] ${orderItems.length} items inserted for order $orderId');
    
    return OrderDTO.fromJson({...result, 'order_items': []});
  } catch (e, st) {
    appLogger.e('[OrderRemoteDataSource] createOrder failed', error: e, stackTrace: st);
    rethrow;
  }
}
```

Add import: `import '../../../../core/logger/app_logger.dart';`

### Fix 3: Add `selected_options` JSONB column to `order_items`

**New migration file:** `supabase/migrations/20260620_000001_order_items_selected_options.sql`

```sql
ALTER TABLE order_items
  ADD COLUMN IF NOT EXISTS selected_options JSONB DEFAULT '[]'::jsonb;
```

Also update `supabase/schema.sql` to include the column for fresh setups:
```sql
-- In the CREATE TABLE order_items block, add:
selected_options JSONB DEFAULT '[]'::jsonb,
```

### Fix 4: Update `orders` CHECK constraint for `dine_in`

**New migration file:** `supabase/migrations/20260620_000002_orders_dine_in_constraint.sql`

```sql
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_order_type_check;
ALTER TABLE orders ADD CONSTRAINT orders_order_type_check
  CHECK (order_type IN ('delivery', 'pickup', 'dine_in') OR order_type IS NULL);
```

Also update `supabase/schema.sql`:
```sql
-- Change line:
--   order_type TEXT DEFAULT 'delivery' CHECK (order_type IN ('delivery', 'pickup')),
-- To:
  order_type TEXT DEFAULT 'delivery' CHECK (order_type IN ('delivery', 'pickup', 'dine_in')),
```

### Fix 5: Create Supabase RPC for atomic order+items creation

**New migration file:** `supabase/migrations/20260620_000003_create_order_rpc.sql`

```sql
CREATE OR REPLACE FUNCTION create_order_with_items(p_order JSONB, p_items JSONB)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_id UUID;
  v_item JSONB;
BEGIN
  INSERT INTO orders (
    customer_id, customer_name, customer_phone, customer_address,
    notes, payment_method, total_amount, status,
    scheduled_for, order_type, address_id, coupon_id,
    discount_amount, delivery_fee, delivery_zone_id, delivery_zone_name
  ) VALUES (
    (p_order->>'customer_id')::UUID,
    p_order->>'customer_name',
    p_order->>'customer_phone',
    p_order->>'customer_address',
    p_order->>'notes',
    p_order->>'payment_method',
    (p_order->>'total_amount')::DECIMAL,
    COALESCE(p_order->>'status', 'pending'),
    (p_order->>'scheduled_for')::TIMESTAMPTZ,
    p_order->>'order_type',
    (p_order->>'address_id')::UUID,
    (p_order->>'coupon_id')::UUID,
    (p_order->>'discount_amount')::DECIMAL,
    (p_order->>'delivery_fee')::DECIMAL,
    (p_order->>'delivery_zone_id')::UUID,
    p_order->>'delivery_zone_name'
  ) RETURNING id INTO v_order_id;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    INSERT INTO order_items (
      order_id, product_id, product_name, product_price,
      quantity, subtotal, selected_options
    ) VALUES (
      v_order_id,
      (v_item->>'product_id')::UUID,
      v_item->>'product_name',
      (v_item->>'product_price')::DECIMAL,
      (v_item->>'quantity')::INT,
      (v_item->>'subtotal')::DECIMAL,
      COALESCE(v_item->'selected_options', '[]'::jsonb)
    );
  END LOOP;

  RETURN v_order_id;
END;
$$;
```

Then update the datasource to use the RPC:

**File:** `lib/infrastructure/datasources/remote/order_remote_data_source.dart`

```dart
Future<OrderDTO> createOrder({
  required Map<String, dynamic> orderData,
  required List<Map<String, dynamic>> itemsData,
}) async {
  try {
    final result = await _client.rpc('create_order_with_items', params: {
      'p_order': orderData,
      'p_items': itemsData,
    });

    final orderId = result as String;
    final orderResult = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();

    return OrderDTO.fromJson(orderResult);
  } catch (e, st) {
    appLogger.e('[OrderRemoteDataSource] createOrder RPC failed', error: e, stackTrace: st);
    rethrow;
  }
}
```

### Fix 6: Verify notification pipeline configuration

**Required Supabase SQL (run in Dashboard > SQL Editor):**

```sql
-- 1. Set the Edge Function URL
ALTER DATABASE postgres SET app.settings.supabase_functions_url = 'https://<YOUR_PROJECT_REF>.supabase.co/functions/v1';

-- 2. Set the service role key
ALTER DATABASE postgres SET app.settings.service_role_key = '<YOUR_SERVICE_ROLE_KEY>';

-- 3. Verify settings
SELECT current_setting('app.settings.supabase_functions_url', true) AS functions_url,
       current_setting('app.settings.service_role_key', true) AS has_service_key;

-- 4. Check that device_tokens exist for admin users
SELECT dt.*, p.role FROM device_tokens dt JOIN profiles p ON dt.user_id = p.id WHERE p.role = 'admin';

-- 5. Test: manually insert a notification and check Edge Function logs
INSERT INTO notifications (user_id, title_ar, body_ar, type, reference_type, reference_id)
VALUES ('<ADMIN_USER_ID>', 'اختبار', 'إشعار تجريبي', 'system', 'order', '<SOME_ORDER_ID>');
```

**Required Supabase CLI (deploy Edge Functions and set secrets):**

```bash
supabase functions deploy send-notification --no-verify-jwt
supabase secrets set FIREBASE_PROJECT_ID=<your-project-id>
supabase secrets set FIREBASE_CLIENT_EMAIL=<your-client-email>
supabase secrets set FIREBASE_PRIVATE_KEY=<your-private-key>
```

**Verify in Edge Function logs:**
```bash
supabase functions logs send-notification
```

### Fix 7: Add logging to the DB trigger

**New migration file:** `supabase/migrations/20260620_000004_trigger_logging.sql`

Enhance the `invoke_send_notification()` function to log more details when the URL or key is missing:

```sql
CREATE OR REPLACE FUNCTION invoke_send_notification()
RETURNS TRIGGER AS $$
DECLARE
  v_url text;
  v_request_id bigint;
  v_service_key text;
BEGIN
  v_url := current_setting('app.settings.supabase_functions_url', true);
  v_service_key := current_setting('app.settings.service_role_key', true);

  IF v_url IS NULL OR v_url = '' THEN
    RAISE WARNING '[invoke_send_notification] app.settings.supabase_functions_url is NOT configured';
    RETURN NEW;
  END IF;

  IF v_service_key IS NULL OR v_service_key = '' THEN
    RAISE WARNING '[invoke_send_notification] app.settings.service_role_key is NOT configured';
    RETURN NEW;
  END IF;

  v_url := v_url || '/send-notification';

  SELECT net.http_post(
    url := v_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_service_key
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'notifications',
      'record', row_to_json(NEW)
    )
  ) INTO v_request_id;

  RAISE LOG '[invoke_send_notification] dispatched request % for notification %',
    v_request_id, NEW.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Execution Order

1. **Fix 2** — Add logging (so we can see the actual error when testing)
2. **Fix 1** — Checkout error handling (so user sees errors)
3. **Fix 3** — Add `selected_options` column to `order_items`
4. **Fix 4** — Update CHECK constraint for `dine_in`
5. **Test** — Try placing an order and check logs
6. **Fix 5** — Migrate to RPC (atomic order creation)
7. **Fix 6** — Verify notification pipeline settings
8. **Fix 7** — Improve trigger logging
9. **Run `flutter analyze`** to verify

## Quick Verification After Fixes

After implementing fixes 1-4, test by:
1. Place an order in the app
2. Check logcat for `[OrderRemoteDataSource]` and `[OrderRepository]` messages
3. If order fails, the error message will now be visible in the UI and logs
4. Check Supabase Dashboard > Table Editor > `orders` to verify the order exists
5. Check `notifications` table for admin notification rows