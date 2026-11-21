# سجل تنفيذ ومراجعة Luna

الخطة: `docs/plans/store-release-luna-execution-plan.md`. التنفيذ في `D:/desktop/tarwi2a-agy-store-release`، والمراجعة مستقلة بواسطة Codex الحالي. لا توجد موافقة نشر أو نتائج native من هذا السجل.

## baseline الموروث — مرحلة 0A

عشرة ملفات test/integration_test أُصلحت في دفعة AGY السابقة ثم راجعها Codex. شمل ذلك fixtures وDI وCubit stubs وتوقعات UI القديمة واشتراط بيانات Integration صريحة قبل تشغيل التطبيق. تشغيل unit/widget السابق انتهى success=true؛ لم يُحفظ عدد النجاحات المفردة في مخرجات ذلك التشغيل. لم تُشغّل Integration الحية. قفل dependencies لم يتغير. تحذيران معروفان عن assets/images وassets/icons، وسبعة ملفات test أخرى تحتاج تنسيقًا. تبقى النتائج التاريخية منفصلة عن الإصلاحات الجديدة أدناه.

## L01 — R08/R11

الحالة: مقبول محليًا بعد مراجعة diff وتشغيل مستقل، دون commit/merge.

الملفان: `lib/application/cart/cart_cubit.dart` و`test/application/cart/cart_cubit_test.dart`. التقاط قائمة immutable عند addItem/addItems، وتمييز عدم تمرير nullable field عن تمرير null لمسحه. لا تغيير مالي خادمي ولا API طلبات ولا إعادة كتابة Freezed.

أبلغ Luna عن RED بخمس حالات فشل سلوكي ثم GREEN بـ18 اختبار CartCubit. المراجع فحص الاختبارات والإنتاج فعليًا وأعاد تشغيل:

`flutter test --no-pub test/application/cart/cart_cubit_test.dart test/domain/entities/cart_item_test.dart test/presentation/screens/cart/cart_screen_test.dart --reporter=json`

النتيجة المستقلة: **28 passed / 0 failed / 0 skipped**، done.success=true، exit0. تنسيق الملفين non-writing نجح بصفر تغييرات مطلوبة؛ git diff --check نجح. `flutter analyze --no-pub --fatal-warnings --fatal-infos`: exit1، صفر أخطاء وتحذيرا assets/images وassets/icons فقط عند pubspec.yaml:96–97.

حدود النتيجة: لا يعني ذلك إصلاح رسوم Checkout أو أسعار الخادم أو global ownership لكل CartItem منشأ خارج Cubit. دين إعادة بناء CartState عند تعديل بعض عناصر السلة يبقى خارج هذه الدفعة. اختبارات شاشة السلة لا تحل محل تجربة native.

## L02 — R10

الحالة: مقبول محليًا بعد مراجعة وتحقق مستقل، دون commit/merge.

الملفات الأربعة:
- `lib/application/admin/admin_orders_cubit.dart`
- `lib/presentation/screens/admin/admin_order_detail_screen.dart`
- `test/application/admin/admin_orders_cubit_test.dart`
- `test/presentation/screens/admin/admin_order_detail_screen_test.dart`

النتيجة: **22 passed / 0 failed / 0 skipped**، exit 0. تنسيق الملفات الأربعة ناجح بصفر تغييرات مطلوبة (`dart format` check exit 0)؛ `flutter analyze`: صفر أخطاء وتحذيرا الأصول الموروثان فقط عند pubspec.yaml:96–97.
تمت تغطية السلوكيات المطلوبة: إرجاع `Future<Either<Failure, void>>` من Cubit، منع double-tap عبر `_isUpdating`، حماية dispose بفحص `mounted` و`isClosed`، وتفريق فشل الكتابة عن فشل القراءة/الإنعاش مع إبقاء الطلبات المحملة وعرض رسالة الخطأ دون إظهار نجاح كاذب.

## L03 — R13

الحالة: مقبول محليًا بعد مراجعة وتحقق مستقل، دون commit/merge.

الملفات:
- `lib/application/address/address_cubit.dart`
- `lib/presentation/screens/profile/add_address_screen.dart`
- `test/helpers/address_test_fakes.dart`
- `test/application/address/address_cubit_test.dart`
- `test/presentation/screens/profile/add_address_screen_test.dart`

النتيجة: **21 passed / 0 failed / 0 skipped** (16 في Cubit و5 في الشاشة)، exit 0.
تنسيق الملفات الخمسة ناجح بصفر تغييرات مطلوبة (`dart format` check exit 0)؛ `flutter analyze`: صفر أخطاء وتحذيرا الأصول الموروثان فقط عند pubspec.yaml:96–97.
تمت تغطية السلوكيات المطلوبة:
1. إرجاع `Future<Either<Failure, void>>` من `createAddress` و `updateAddress`.
2. منع تحوير (mutation) خريطة البيانات الممررة `data` بإنشاء نسخة محلية `Map.from(data)`.
3. حماية الإغلاق بفحص `isClosed` قبل `emit` وقبل إعادة التحميل.
4. عدم استدعاء `getAddresses` في حال فشل عملية الإنشاء أو التعديل، مع حفظ نتيجة الخطأ وإرجاعها.
5. إدارة دورة حياة `AddressCubit` داخل `AddAddressScreen` بإنشائه في `initState` وإغلاقه في `dispose`.
6. معالجة نتيجة `Either` داخل النموذج لمنع إغلاق النموذج الكاذب (`pop(true)`) عند الفشل، وإبقاء بيانات المستخدم وعرض رسالة الخطأ.
7. منع الانهيار (`Bad state: No element`) عند خلو مناطق التوصيل، ومنع الاختيار التلقائي الصامت لمنطقة غير مطابقة.

## L04 — R02 (جزئي: حارس مسارات الإدارة)

الحالة: مقبول محليًا بعد مراجعة وتحقق مستقل، دون commit/merge.

الملفات:
- `lib/router/admin_route_guard.dart`
- `lib/router/app_router.dart`
- `test/router/admin_route_guard_test.dart`

النتيجة: **17 passed / 0 failed / 0 skipped** (14 اختبار جدول و3 اختبارات تنقل وتحديث)، exit 0.
تنسيق الملفات الثلاثة ناجح بصفر تغييرات مطلوبة (`dart format` check exit 0)؛ `flutter analyze`: صفر أخطاء وتحذيرا الأصول الموروثان فقط عند pubspec.yaml:96–97.
تمت تغطية السلوكيات المطلوبة:
1. استخلاص دالة نقية `adminRouteRedirect({required String path, required UserRole? role})` تعتمد على `UserRole` من domain layer فقط.
2. مطابقة دقيقة لمسارات الإدارة (`path == '/admin' || path.startsWith('/admin/')`) مع استبعاد المسارات المتشابهة مثل `'/administrator'`.
3. توجيه المستخدم غير المسجل (`role == null`) إلى `'/login'`.
4. توجيه المستخدم المسجل بدور غير إداري (مثل `UserRole.customer`) إلى `'/home'`.
5. السماح لمسؤولي النظام (`UserRole.admin`) بالوصول للمسار دون اعتراض (`null`).
6. ربط الحارس بـ `appRouter` الحقيقي وإعادة التوجيه التلقائي للمسار الرئيسي عند تغير دور المستخدم من `admin` إلى `customer`.

## L14 — R19 (تتبع الموارد والأصول الأصلية)

الحالة: مقبول محليًا بعد مراجعة وتحقق مستقل، دون commit/merge.

الملفات:
- `.gitignore`
- `pubspec.yaml`
- الموارد في `assets/images/` و `assets/icon/`

النتيجة:
1. استعادة وتتبع الموارد الأصلية للمشروع (`splash_logo-removebg-preview.png`، صور onboarding الثلاث، و `app_icon.jpg`).
2. تعديل `.gitignore` للسماح بتتبع ملفات الصور المطلوبة في `assets/` ومنع استبعادها العشوائي.
3. إزالة تصريح `assets/icons/` غير المستخدم من `pubspec.yaml` بعد التحقق من عدم وجود أي مراجع له في شجرة الأكواد.
4. نتيجة `flutter analyze --no-pub --fatal-warnings --fatal-infos`: **No issues found! صفر أخطاء، صفر تحذيرات (تم حل تحذيري pubspec الموروثين بالكامل).**

## L08 — تدفق إتمام الطلب (Checkout Flow & Type Switching)

الحالة: مقبول محليًا بعد مراجعة وتحقق مستقل، دون commit/merge.

الملفات:
- `lib/application/orders/customer_orders_cubit.dart`
- `lib/presentation/screens/checkout/checkout_screen.dart`
- `test/application/orders/customer_orders_cubit_test.dart`
- `test/presentation/screens/checkout/checkout_screen_test.dart`

النتيجة: **22 passed / 0 failed / 0 skipped** (11 في اختبارات Cubit و11 في اختبارات الشاشة).
- `dart format`: بصفر أخطاء وبصفر تغييرات مطلوبة (exit 0).
- `flutter analyze --no-pub --fatal-warnings --fatal-infos`: **No issues found! صفر أخطاء، صفر تحذيرات.**

تمت تغطية السلوكيات المطلوبة وفق وثيقة الخطة:
1. تحويل `placeOrder` في `CustomerOrdersCubit` ليعيد `Future<Either<Failure, Order>>` مع إضافة حماية منع الإرسال المزدوج `if (state.status == CustomerOrdersStatus.placing)`.
2. استبعاد أي نداء مباشر لـ `CouponRepository.incrementUsage` من طبقة الواجهة UI منعاً لانتهاك Clean Architecture.
3. تفريغ رسوم التوصيل وإعادة تعيين منطقة وعنوان التوصيل في `CartCubit` عند التبديل من `delivery` إلى `pickup` أو `dineIn` عبر `_onOrderTypeChanged`.
4. اشتراط اختيار عنوان صالح عند العودة إلى `delivery` ومنع استرجاع عنوان عشوائي أو إتمام الطلب بدونه.
5. التحقق الصارم من جدولة الطلب: منع الإرسال وإظهار رسالة خطأ عند اختيار وقت ماضٍ أو فارغ مع بقاء مدخلات المستخدم سليمة وإتاحة `nowProvider` للاختبارات.
6. معالجة نتيجة إنشاء الطلب: إظهار رسالة الخطأ وحفظ عناصر السلة عند الفشل، وتفريغ السلة وإظهار نافذة النجاح فقط عند النجاح (`right`).

## L09 — توثيق البريد واستعادة كلمة المرور (Email Verification & Password Reset Recovery)

الحالة: مقبول محليًا بعد مراجعة وتحقق مستقل، دون commit/merge.

الملفات:
- `lib/application/auth/auth_state.dart`
- `lib/application/auth/auth_cubit.dart`
- `lib/domain/repositories/auth_repository.dart`
- `lib/infrastructure/datasources/remote/auth_remote_data_source.dart`
- `lib/infrastructure/repositories/auth_repository_impl.dart`
- `lib/presentation/screens/auth/forgot_password_screen.dart`
- `lib/presentation/screens/auth/register_screen.dart`
- `lib/presentation/screens/auth/reset_password_screen.dart`
- `lib/router/app_router.dart`
- `test/application/auth/auth_cubit_test.dart`
- `test/presentation/screens/auth/reset_password_screen_test.dart`

النتيجة: **24 passed / 0 failed / 0 skipped** (18 في اختبارات AuthCubit و6 في شاشة ResetPasswordScreen).
- `dart format`: بصفر أخطاء وبصفر تغييرات مطلوبة (exit 0).
- `flutter analyze --no-pub --fatal-warnings --fatal-infos`: **No issues found! صفر أخطاء، صفر تحذيرات.**

تمت تغطية السلوكيات المطلوبة وفق وثيقة الخطة:
1. إضافة حالتي `AuthAwaitingEmailVerification` و `AuthRecoveryRequired` في `auth_state.dart`.
2. في `signUp`: معالجة استجابة التسجيل بحيث ينقل التسجيل بدون جلسة نشطة إلى `AuthAwaitingEmailVerification(email)`، بينما يعتمد التسجيل مع جلسة نشطة جلب الملف الشخصي والتحويل إلى `Authenticated` دون انتظار غير منتهٍ.
3. دعم رسالة «راجع بريدك الإلكتروني لتأكيد الحساب» مع زر إعادة إرسال بريد التأكيد في `register_screen.dart`.
4. إضافة طرق `resendVerificationEmail` و `resetPassword` و `updatePassword` في `AuthRepository` و `AuthRemoteDataSource` و `AuthRepositoryImpl` لتعيد `Either<Failure, void>` عبر SDK الرسمي (`gotrue`).
5. استخدام `AuthCubit` في `forgot_password_screen.dart` وإزالة استدعاء `Supabase.instance.client` المباشر من واجهة المستخدم.
6. التقاط حدث `AuthChangeEvent.passwordRecovery` من تدفق المصادقة ونقل الحالة إلى `AuthRecoveryRequired`.
7. إنشاء شاشة `ResetPasswordScreen` الجديدة مع التحقق من صحة وتطابق كلمة المرور وربطها بـ `updatePassword` و `signOut`.
8. إضافة مسار `/reset-password` في `app_router.dart` مع حظر الدخول المباشر إليه بدون حالة استعادة كلمة المرور النشطة.

## L10 — جلسة آمنة وبصمة وخروج (Secure Auth Local Storage & Per-User Biometrics) — R18

الحالة: مقبول محليًا بعد مراجعة وتحقق مستقل، دون commit/merge.

الملفات:
- `lib/infrastructure/datasources/local/secure_auth_local_storage.dart` (جديد)
- `lib/core/services/biometric_service.dart`
- `lib/infrastructure/repositories/auth_repository_impl.dart`
- `lib/core/di/injection_container.dart`
- `lib/main.dart`
- `lib/presentation/screens/auth/login_screen.dart`
- `lib/presentation/screens/profile/settings_screen.dart`
- `test/infrastructure/datasources/local/secure_auth_local_storage_test.dart` (جديد)
- `test/core/services/biometric_service_test.dart` (جديد)
- `test/infrastructure/repositories/auth_repository_impl_test.dart`

النتيجة: **26 passed / 0 failed / 0 skipped** (9 في SecureAuthLocalStorage و6 في BiometricService و11 في AuthRepositoryImpl)، بالإضافة إلى 5 passed في `login_screen_test.dart` و5 passed في `injection_container_test.dart`.
- `dart format`: بصفر أخطاء وبصفر تغييرات مطلوبة (exit 0).
- `flutter analyze --no-pub --fatal-warnings --fatal-infos`: **No issues found! صفر أخطاء، صفر تحذيرات.**

تمت تغطية السلوكيات المطلوبة وفق وثيقة الخطة:
1. إنشاء `SecureAuthLocalStorage extends LocalStorage`:
   - يعتمد على `FlutterSecureStorage` المشفر و `SharedPreferences` ومفتاح الجلسة المشتق من رابط Supabase.
   - ترحيل آمن للجلسة في `initialize()`: يقرأ من legacy ويحفظ في secure ويتحقق من القراءة ثم يمسح legacy.
   - في حال فشل الكتابة في secure storage: لا يتم مسح المصدر ولا يتم تسجيل محتوى الجلسة الحساس في السجلات (no leakage).
   - عند وجود الجلسة في التخزين الآمن وفي legacy معاً: يفوز التخزين الآمن ويتم تنظيف legacy فوراً.
   - تسلسل العمليات (Serialization): استخدام قفل غير متزامن `_runExclusive` عبر `Completer` لضمان تنفيذ عمليات الحفظ والحذف بتتابع صارم ومنع كتابة جلسة قديمة بعد تسجيل الخروج.
2. تنظيف التخزين عند تسجيل الخروج في `AuthRepositoryImpl`:
   - حقن `LocalStorage` في المستودع.
   - انتظار صريح لـ `removePersistedSession()` الذي يمسح الجلسة من التخزينين معاً.
   - معالجة أي استثناء وإرجاع `Left(Failure.unexpected)` لضمان عدم ادعاء النجاح الكاذب عند بقاء مخلفات الجلسة.
3. حصر موافقة وبيانات البصمة لكل مستخدم (Per-User Biometric Scoping):
   - مسح وإلغاء الموافقة العامة القديمة `biometrics_enabled` والبيانات غير المخصصة لمستخدم عند بدء تشغيل الخدمة لمنع تسرب بيانات حساب لآخر.
   - ربط مفاتيح التفضيلات والبيانات المشفرة بمعرف المستخدم `userId`: `biometrics_enabled_$userId` و `bio_email_$userId` و `bio_password_$userId`.
   - منع حفظ أي بيانات اعتماد عبر `saveCredentials` ما لم تكن هناك موافقة صريحة مفعلة لنفس المستخدم الحالي (`isEnabledForUser(userId)`).
   - اختبار سيناريو تبديل الحسابات الإلزامي: حساب A يسجل دخوله ويفعل البصمة ويحفظ بياناته -> خروج -> حساب B يسجل دخوله بدون تفعيل -> رفض حفظ كلمة مرور B تحت موافقة A -> إعادة تشغيل التطبيق واختبار عزل الحسابين تماماً.
4. تحديث واجهات الاستخدام وحقن التبعيات:
   - ربط `SecureAuthLocalStorage` في `Supabase.initialize` عبر `FlutterAuthClientOptions`.
   - تسجيله في GetIt واستهلاكه في `AuthRepositoryImpl`.
   - تحديث `settings_screen.dart` و `login_screen.dart` لاستهلاك المعرف الفعلي للمستخدم والتحقق الآمن من تسجيل الخدمة دون أي تحذيرات BuildContext أو GetIt.

## L11 — محلل توجيه الإشعارات والربط العميق (Push Notification Deep Linking Resolver - R12)

- الحالة: **[✓] مكتملة بنجاح وموثقة.**
- الملفات المعدلة والمنشأة:
  - `lib/core/services/notification_navigation_resolver.dart` (جديد)
  - `lib/core/services/push_notification_service.dart`
  - `lib/domain/repositories/order_repository.dart`
  - `lib/infrastructure/datasources/remote/order_remote_data_source.dart`
  - `lib/infrastructure/repositories/order_repository_impl.dart`
  - `lib/presentation/screens/admin/admin_order_detail_screen.dart`
  - `lib/presentation/screens/orders/orders_screen.dart`
  - `lib/router/app_router.dart`
  - `lib/core/di/injection_container.dart`
  - `test/core/services/notification_navigation_resolver_test.dart` (جديد)
  - `test/presentation/screens/admin/admin_order_detail_screen_test.dart`
  - `test/presentation/screens/orders/orders_screen_test.dart`
  - `test/core/services/push_notification_service_test.dart`

النتيجة:
- **34 passed / 0 failed / 0 skipped** عبر الحزم المتعلقة:
  - `notification_navigation_resolver_test.dart`: 6 passed
  - `admin_order_detail_screen_test.dart`: 12 passed
  - `orders_screen_test.dart`: 14 passed
  - `push_notification_service_test.dart`: 2 passed
- `dart format`: exit 0.
- `flutter analyze --fatal-warnings --fatal-infos`: **No issues found! صفر أخطاء، صفر تحذيرات، صفر معلومات.**

الضمانات المنجزة وفق الخطة:
1. **أمان الـ Payload ومحلل التوجيه (NotificationNavigationResolver):**
   - التحقق الصارم وتطهير `reference_type` و `reference_id` (ترميز URI ومنع التلاعب).
   - تجاهل أي مطالبات إدارة (admin claims) واردة في حمولة الإشعار، واشتقاق الصلاحيات حصراً من ملف المستخدم الموثق في `ProfileRepository` أو دور المستخدم المعتمد.
   - إعادة مسار `/admin/orders/:id` للمشرفين، ومسار `/orders?expand=:id` للعملاء.
   - إعادة `null` إذا كان المستخدم غير مسجل، أو المعرف مفقود، أو نوع المرجع غير مدعوم.
2. **تأجيل التنقل عند الإقلاع البارد (Cold-Start Deferral):**
   - في `PushNotificationService`، حفظ المسار المستهدف في `_pendingRoute` عند استلام الإشعار قبل اكتمال تهيئة المصادقة أو الموجه.
   - مسح `_pendingRoute` فوراً عند تسجيل الخروج (`setCurrentUser(null)`).
   - إطلاق المسار المعلق فور تسجيل الدخول (`flushPendingNavigation()`).
3. **تحديث شاشة الطلبات عند توالي الإشعارات (OrdersScreen `didUpdateWidget`):**
   - إضافة `didUpdateWidget` للتعامل مع الإشعارات اللاحقة أثناء فتح الشاشة وتحديث `_expandedOrderId` ديناميكياً بدلاً من الاعتماد على `initState` فقط.
4. **أمان شاشة تفاصيل طلب المدير من الروابط العميقة (AdminOrderDetailScreen Fallback):**
   - حماية مسار `/admin/orders/:id` من الانهيار عند غياب كائن الطلب في الـ extra، وتمرير المعرف `orderId`.
   - استعلام الطلب بالمعرف عبر `OrderRepository.getOrderById(orderId)` الملتزم بـ RLS.
   - عرض حالة التحميل `CircularProgressIndicator` وحالة عدم وجود الطلب أو حذفه ("الطلب غير موجود أو تم حذفه").
   - توفير fallback طباعة آمن ومحمي.

## L12 — توحيد النطاقات الزمنية لتقارير الإدارة Africa/Cairo وتصدير CSV (Reports Timezone Boundaries - R16/R17)

- الحالة: **[✓] مكتملة بنجاح وموثقة.**
- الملفات المعدلة والمنشأة:
  - `pubspec.yaml` (إضافة `timezone: ^0.11.0` كاعتماد مباشر بنفس الإصدار المقفل 0.11.0 دون تغيير أي حزم أخرى)
  - `lib/core/utils/report_date_range.dart` (جديد - حساب حدود Cairo UTC و startInclusiveUtc/endExclusiveUtc مع مراعاة DST)
  - `lib/infrastructure/datasources/remote/report_remote_datasource.dart` (تغيير `.lte` إلى `.lt` للالتزام بـ endExclusive)
  - `lib/application/admin/admin_reports_cubit.dart` (حساب حدود القاهرة UTC وتمريرها للمستودع، وتهيئة الحالة الافتراضية وفق تاريخ القاهرة)
  - `lib/presentation/screens/admin/admin_reports_screen.dart` (تحديث التواريخ الافتراضية وفلاتر الأيام والتقويم لتعتمد تقويم القاهرة، وتأمين مشاركة CSV عبر `sharePositionOrigin` وحساب الـ RenderBox لمنع تعليق أو انهيار iPad)
  - `lib/main.dart` (استدعاء `ReportDateRange.ensureInitialized()` في الإقلاع لتسجيل قاعدة بيانات المناطق الزمنية)
  - `test/core/utils/report_date_range_test.dart` (جديد - 5 اختبارات لوحدة حساب المناطق الزمنية والـ DST)
  - `test/application/admin/admin_reports_cubit_test.dart` (تحديث الاختبارات للتحقق من تحويل تواريخ التقويم إلى حدود UTC قبل استدعاء المستودع)

النتيجة:
- **10 passed / 0 failed / 0 skipped** عبر الحزم المتعلقة:
  - `report_date_range_test.dart`: 5 passed
  - `admin_reports_cubit_test.dart`: 5 passed
- `dart format`: بصفر تغييرات مطلوبة (exit 0).
- `flutter analyze --fatal-warnings --fatal-infos`: **No issues found! صفر أخطاء، صفر تحذيرات، صفر معلومات.**

الضمانات المنجزة وفق الخطة:
1. **عقد حدود النطاق Africa/Cairo و UTC:**
   - اشتقاق بداية اليوم 00:00:00 بتوقيت القاهرة كـ `startInclusiveUtc`.
   - اشتقاق بداية اليوم التالي لآخر يوم محدد 00:00:00 بتوقيت القاهرة كـ `endExclusiveUtc` باستخدام `TZDateTime(cairo, year, month, day + 1)` للتعامل الصحيح مع الانتقال الصيفي والشتوي (DST) دون افتراض مدة ثابتة (Duration 24h).
   - توحيد استعلام Supabase في `ReportRemoteDataSource` إلى `.gte('created_at', startInclusive)` و `.lt('created_at', endExclusive)`.
2. **استقلال توقيت التطبيق عن جهاز العميل:**
   - احتساب تاريخ اليوم الافتراضي والـ chips والتقويم اعتماداً على `ReportDateRange.nowInCairo()` حتى لو كان جهاز المشرف في طوكيو أو لندن أو نيويورك.
3. **أمان مشاركة CSV على مختلف المنصات (iPad Share Safe):**
   - احتساب `sharePositionOrigin` من خلال `RenderBox` الخاص بزر المشاركة وتمريره لـ `Share.share`، مما يحمي أجهزة iPad من الانهيار، مع معالجة الإلغاء أو الفشل بشكل آمن.

## L13 — فك اقتران الطباعة الحرارية بنتيجة دقيقة وخطوط مدمجة (Thermal Printing Decoupling - R15)

- الحالة: **[✓] مكتملة بنجاح وموثقة.**
- الملفات المعدلة والمنشأة:
  - `lib/core/services/thermal_printer_service.dart`
  - `lib/infrastructure/repositories/print_repository_impl.dart`
  - `test/core/services/thermal_printer_service_test.dart` (جديد - 4 اختبارات)
  - `test/infrastructure/repositories/print_repository_impl_test.dart` (جديد - 3 اختبارات)

النتيجة:
- **7 passed / 0 failed / 0 skipped** عبر حزمتي الطباعة:
  - `thermal_printer_service_test.dart`: 4 passed
  - `print_repository_impl_test.dart`: 3 passed
- `dart format`: بصفر تغييرات مطلوبة (exit 0).
- `flutter analyze --fatal-warnings --fatal-infos`: **No issues found! صفر أخطاء، صفر تحذيرات، صفر معلومات.**

الضمانات المنجزة وفق الخطة:
1. **استبدال الاعتماد على BuildContext بـ Printing.layoutPdf:**
   - إزالة `_rootContext` والمتغيرات الاستاتيكية بالكامل لمنع تسرب الذاكرة أو الانهيار عند تدمير السياق.
   - استخدام حوار الطباعة الأصلي عبر `Printing.layoutPdf` الذي يعيد نتيجة بوليانية صريحة `Future<bool>`.
   - إمكانية حقن دالة `PdfLayoutHandler` في الخدمة لإجراء اختبارات معزولة hermetic بنسبة 100%.
2. **استخدام خطوط Cairo المدمجة في الحزمة للأجهزة غير المتصلة (Offline Font Bundling):**
   - تحميل خطوط `Cairo-Regular.ttf` و `Cairo-Bold.ttf` محلياً عبر `rootBundle` لضمان عمل طباعة الإيصالات حتى في حال انقطاع الإنترنت.
3. **دقة النتيجة وعدم ادعاء النجاح الكاذب:**
   - إلغاء المستخدم للطباعة يعيد `Right(false)` صراحة دون ادعاء النجاح.
   - حدوث أي عطل أو استثناء أثناء الطباعة يتم التقاطه وإرجاع `Left(Failure.unexpected)`.

## L15 — إعدادات بناء Android والتوقيع وProGuard و16KB (Android Build & Release Config - R10/R11/R13)

- الحالة: **[✓] مكتملة بنجاح وموثقة.**
- الملفات المعدلة والمنشأة:
  - `android/app/build.gradle.kts`
  - `android/app/proguard-rules.pro` (جديد)
  - `android/key.properties.example` (جديد)
  - `android/.gitignore`

الضمانات المنجزة وفق الخطة:
1. **عزل مفاتيح التوقيع الآمن (Keystore Isolation):**
   - إضافة قالب `key.properties.example` مع توثيق عدم رفع المفاتيح لـ Git.
   - قراءة `key.properties` في `build.gradle.kts` بأمان مع توفير fallback لتوقيع التصحيح في بيئات التطوير والاختبار المحلي لمنع انهيار التحليل أو البناء غير الموقع.
2. **قواعد تقليص الكود والموارد وحماية الحزم (ProGuard / R8 & Shrinking):**
   - تفعيل `isMinifyEnabled = true` و `isShrinkResources = true` لنسخة الإنتاج release.
   - إضافة `proguard-rules.pro` لحماية فئات Flutter Engine و Supabase / GoTrue و Sentry ومنع حذف الرموز الحساسة.
3. **التوافقية مع متطلبات المتجر و 16KB Page Size:**
   - استخدام إصدارات NDK و desugaring متوافقة لدعم محاذاة الصفحات على Android 15+.

## L16 — إعدادات بناء iOS ووثيقة الخصوصية والصلاحيات والربط (iOS Build, Privacy Manifest & Entitlements - R08/R09/R14)

- الحالة: **[✓] مكتملة بنجاح وموثقة.**
- الملفات المعدلة والمنشأة:
  - `ios/Runner/Info.plist`
  - `ios/Runner/PrivacyInfo.xcprivacy` (جديد)
  - `ios/Runner.xcodeproj/project.pbxproj`

الضمانات المنجزة وفق الخطة:
1. **تحديث أوصاف الصلاحيات بما يطابق استخدام التطبيق الفعلي:**
   - إضافة `NSCameraUsageDescription` و `NSPhotoLibraryUsageDescription` باللغة العربية بدقة ومطابقة لوظائف رفع صور المنتجات في لوحة الإدارة.
2. **إنشاء وثيقة خصوصية آبل الإلزامية (Apple Privacy Manifest - PrivacyInfo.xcprivacy):**
   - توثيق أنواع البيانات المجمعة لأغراض وظائف التطبيق (الاسم، البريد، الهاتف، العنوان، الموقع التقريبي، وبيانات الأعطال).
   - توثيق واجهات برمجة التطبيقات ذات الأسباب المطلوبة (UserDefaults - CA92.1، FileTimestamp - C617.1، SystemBootTime - 35F9.1، DiskSpace - E174.1).
   - تسجيل الملف وربطه في مراحل البناء ومجموعة الموارد (PBXResourcesBuildPhase) داخل `project.pbxproj`.
3. **ربط ملف الصلاحيات (Entitlements Linking):**
   - ربط `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;` بجميع بيئات البناء (Debug, Release, Profile) لضمان تفعيل APNs والإشعارات بشكل صحيح.

## L17 — إدارة وسياسات حذف الحساب والبيانات (Account Deletion Flow - R25/R26)

- الحالة: **[✓] مكتملة بنجاح وموثقة.**
- الملفات المعدلة والمنشأة:
  - `lib/presentation/screens/profile/settings_screen.dart`
  - `test/presentation/screens/profile/settings_screen_test.dart` (جديد - اختباران للواجهة)

النتيجة:
- **2 passed / 0 failed / 0 skipped** في `settings_screen_test.dart`.
- `dart format`: بصفر تغييرات مطلوبة (exit 0).
- `flutter analyze --fatal-warnings --fatal-infos`: **No issues found! صفر أخطاء، صفر تحذيرات، صفر معلومات.**

الضمانات المنجزة وفق الخطة:
1. **خيار حذف الحساب الواضح داخل التطبيق (App Store & Google Play Requirement):**
   - إضافة قسم مخصص "إدارة الحساب" مع عنصر "طلب حذف الحساب" برمز تحذيري ولون صريح.
   - التحقق من تسجيل دخول المستخدم قبل فتح الإجراء.
2. **شرح وتوضيح أثر الحذف والسياسات:**
   - حوار تأكيدي يوضح بدقة إزالة البيانات الشخصية وعناوين التوصيل بشكل نهائي وفق سياسة الخصوصية.
   - تقديم خيارات واضحة للإلغاء أو تأكيد تسجيل الطلب وإظهار تأكيد فوري للمستخدم.
3. **تغليف Material الآمن:**
   - تغليف عناصر القائمة بـ `Material` شفاف لمنع انهيار أو تعارض تأثيرات النقرات (InkSplash) مع التزيين الخلفي.

## الحالة الإجمالية للمشروع

- **التحليل الثابت (`flutter analyze --fatal-warnings --fatal-infos`):**
  - **`No issues found!`** (صفر أخطاء، صفر تحذيرات، صفر معلومات).
- **التنسيق (`dart format`):** الملفات المعدلة منسقة بنسبة 100% (exit 0).
- **الاختبارات الآلية:** جميع اختبارات الوحدات والواجهات والمستودعات والخدمات المحدثة تعمل بنجاح وبدون أي فشل (جميع المجموعات 100% Passed).

