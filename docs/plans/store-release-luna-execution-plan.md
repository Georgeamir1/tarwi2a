# ترويئة — خطة تنفيذ محددة لـ GPT Luna

## 1. الغرض والحالة

هذه طبقة تنفيذ فوق `prd-store-release-remediation.md` والخطة السابقة، وليست إعادة مراجعة أو إذن نشر. المطلوب تحويل النتائج R01–R28 إلى تكليفات لا تترك للمنفذ اختيار سلوك تجاري أو اختراع API. المخطط والمراجع: Codex الحالي. المنفذ: `gpt-5.6-luna`. لا تتطلب هذه الخطة AGY؛ طلب المستخدم الأحدث هو تنفيذ Luna.

نسخة التنفيذ: `D:/desktop/tarwi2a-agy-store-release`، الفرع `codex/store-release-readiness`، أساس المصدر `9d15043e95af02c2faa3a0b03b12b89c76c5c8ac`. المشروع الأصلي `D:/desktop/claude resturant` يحتفظ بوثائق الخطة وملفات المستخدم. لا تنقل العمل تلقائيًا بين النسختين.

خط الأساس المتحقق قبل هذه الخطة: عشرة ملفات اختبارات معدلة دون commit؛ اختبارات الوحدة والواجهات نجحت مع coverage. التحليل الصارم: صفر أخطاء وتحذيران عن assets/images وassets/icons. تنسيق الملفات المعدلة ناجح، وفحص مجلدي الاختبارات يرصد سبعة ملفات أخرى. عدد الاختبارات الناجحة في التشغيل الأخير لم يُحتفظ به؛ لا تستنتجه من تقرير أغسطس. Integration وSupabase الحي وAndroid/iOS لم تتحقق في هذا التشغيل.

**حالة التكليف** واحدة من: جاهز للتنفيذ، يعتمد على تكليف، يحتاج حسمًا من المخطط، يحتاج مدخلًا خارجيًا. الأخيرتان لا تعنيان أن Luna يصمم البديل. يرسل المعلومة الناقصة للمخطط ويتابع تكليفًا مستقلًا فقط إذا سُلّم له صراحة.

## 2. قواعد ثابتة لكل تكليف

1. اقرأ التكليف والملفات المذكورة وAGENTS.md. سجّل `git status --short` و`git diff --name-only` قبل التعديل. التغييرات العشرة السابقة مملوكة للعمل السابق؛ لا تمسحها أو تعيد إنشاء fixtures.
2. تحقق من وجود الرمز المشار إليه وتوقيعه قبل استخدامه. إذا اختلف المصدر، أرسل اسم الملف والرمز ووصف الاختلاف للمخطط؛ لا تصلح بالاعتماد على التخمين.
3. نفذ تكليفًا واحدًا في كل دفعة. قائمة الملفات هي حدود التعديل، بما فيها الملفات الجديدة المسماة صراحة. لا توسع النطاق لأن analyzer أظهر مشكلة قديمة.
4. لكل إصلاح سلوك: اختبار يثبت الفشل أولًا، مع نتيجة التنفيذ؛ ثم أقل تعديل؛ ثم نفس الاختبار أخضر. خطأ compilation أو mock غير مكتمل ليس إثباتًا للعيب.
5. لا تحذف اختبارًا ولا تضف skip ولا تضع ignore للتحليل لجعل البوابة خضراء. تصحيح نص قديم يتطلب مطابقة نص الواجهة الفعلي؛ المطلوب هنا إصلاح السلوك، لا تحويل التوقع إلى السلوك المعيب.
6. حافظ على BLoC وget_it وEither وFreezed. لا تستورد Flutter إلى domain ولا تضف Repository calls إلى الشاشة. لا تعدل الملفات المولدة يدويًا.
7. لا تثبت حزمًا أو ترقّيها إلا في تكليف يحدد الحزمة والإصدار المختبر. وجود مثال في Skill لا يثبت وجود TestWrapper أو Patrol أو AppException داخل المشروع؛ استخدم الأدوات الموجودة.
8. نسق الملفات التي عدلتها فقط. `dart format --output=none --set-exit-if-changed` فحص لا يكتب. اختلاف تنسيق قديم يسجل ولا يبرر تنسيق المشروع بالكامل داخل إصلاح وظيفي.
9. لا مفاتيح أو كلمات مرور أو بيانات عملاء في النصوص أو logs. لا تستعمل السر الموجود في migration. لا live Integration ولا دفع ولا WhatsApp ولا نشر ولا schema push ضمن التنفيذ المحلي.
10. يحتفظ Luna بالتعديلات دون staging/commit/merge/push؛ المراجع يفحص diff ويشغّل بوابات مستقلة ويقرر حفظ commit محدود. لا reset أو clean أو استبدال ملفات عمل سابق.
11. عند إكمال التكليف، أعد: الملفات، التغيير السلوكي، أمر RED ونتيجته، أمر GREEN ونتيجته، نتائج التحليل والتنسيق، وأي حدود باقية. لا تكفِ عبارة «تم».
12. نتائج محاكاة SDK ليست إثبات native، ونجاح اختبارات Dart ليس إثبات RLS، ونجاح unsigned build ليس إثبات signing.

## 3. Skills وكيفية تطبيقها

| نوع التكليف | Skills المطلوبة قبل التعديل |
|---|---|
| التخطيط الحالي | plan-feature، common-product-requirements؛ إعادة استخدام PRD الحالي والإجابات الموجودة |
| كل تغيير Dart | common-tdd، flutter-testing، dart-tooling، flutter-layer-based-clean-architecture |
| Git والمراجعة | common-git-collaboration، common-code-review |
| تحديثات وحسابات | flutter-error-handling، auth-review عند الصلاحيات |
| SQL والأسرار | flutter-security، common-security-audit، supabase:supabase-postgres-best-practices |
| Router وPush | flutter-navigation، flutter-notifications |
| البناء | flutter-cicd؛ xcode-project-setup لملفات Xcode |
| الواجهات | common-mobile-ux-core وflutter-design-system بالإضافة إلى Flutter testing |

المسارات تبدأ من `C:/Users/George/.codex/skills` أو `C:/Users/George/.agents/skills` وفق فهرس Skills. يقرأ المنفذ SKILL.md فعليًا. يعاد استخدام `test/helpers/test_helpers.dart` الموجود بدل نقل جميع الاختبارات إلى تنظيم جديد. تستخدم الاختبارات الجديدة Robots للواجهات وfixtures الموجودة، ولا تُستورد أدوات اختبار غير مثبتة. لا تتحول أمثلة Skills إلى تغييرات بنية أو dependencies غير مطلوبة. مرجع متطلبات المشروع والطلب الحالي يتقدمان على أمثلة Skills العامة.

## 4. ترتيب التسليم

الأولوية الأمنية R01–R07 مستمرة وتمنع النشر. إعداد العقود الأمنية وفحص الوصول مسؤولية المخطط قبل تسليم SQL. بالتوازي مع استكمال هذه المدخلات يمكن تنفيذ إصلاحات محلية مستقلة محددة أدناه دون انتظار Supabase. **أول دفعة تسلم إلى Luna هي L01 فقط**. بعدها يراجع المخطط النتيجة قبل تكليف جديد. لا تعني هذه البداية أن الأمان مؤجل إلى ما بعد النشر.

| التكليف | النتيجة | الحالة عند كتابة الخطة |
|---|---|---|
| L00 | تثبيت سجل المرحلة السابقة والتنسيق | جاهز، يقوم به المراجع ضمن التتبع |
| L01 | تثبيت خيارات السلة ومسح nullable fields — R08/R11 | جاهز؛ أول تنفيذ |
| L02 | منع النجاح الكاذب لتحديث المدير — R10 | جاهز؛ جرد callers مكتمل، بعد مراجعة L01 |
| L03 | منع إغلاق نموذج عنوان فاشل — R13 | عقد محدد، يحتاج مراجعة fixtures قبل تسليمه |
| L04 | منع الدخول لمسارات الإدارة من حساب عميل — جزء R02 | جاهز؛ قرار helper واختباره محدد أدناه |
| L05 | احتواء السر وإغلاق app_config — R01 | المخطط يحسم مسار trigger/secret قبل SQL |
| L06 | schema قابل للإعادة وRLS — R02/R06/R07 | يحتاج export معقم وبيئة replay |
| L07 | عقد إنشاء طلب ذري — R03/R04/R05 | يعتمد على L06 وورقة العقد النهائية |
| L08 | Checkout والنوع والجدولة | محليًا بعد L01؛ الربط النهائي يعتمد على L07 |
| L09 | بريد التأكيد والاستعادة | يحتاج تثبيت رابط recovery وواجهة SDK |
| L10 | جلسة آمنة وبصمة وخروج — R18 | يحتاج فحص interface التخزين المثبت وخطة ترحيل |
| L11 | توجيه Push من معرف — R12 | يحتاج مراجعة مسار admin الحالي واختبار resolver |
| L12 | تقارير النطاق الزمني وCSV — R16/R17 | يحتاج تثبيت timezone API قبل التنفيذ |
| L13 | طباعة بنتيجة صحيحة — R15 | يحتاج تحديد adapter الطباعة؛ جهاز للإغلاق النهائي |
| L14 | تتبع الموارد — R19 | جرد الملفات الأصلية، لا اختراع صور بديلة |
| L15 | Android signing وAAB — R20 | إعداد المصدر ثم مفتاح مالك للتحقق النهائي |
| L16 | iOS source وSDK privacy — R21–R24 | حسم إصدارات SDK ثم Mac للاعتماد |
| L17 | السياسات والحذف — R25/R26 | سياسة احتفاظ وروابط ودعم معتمدة |
| L18 | التقييمات والمفضلة والوظائف المعلنة — R27 | قرار المنتج وعقد بيانات محدد |
| L19 | CI والتحقق النهائي والمتجران — R28 | جميع الاعتماديات السابقة |

## L00 — baseline والتنسيق

لا يعاد تنفيذ إصلاح fixtures السابق. ينقل المراجع نتائج المرحلة 0A من التقرير المؤقت إلى سجل دائم. يسمح بتنسيق الملفات السبعة القديمة في تغيير style مستقل فقط: `test/application/admin/admin_categories_cubit_test.dart`، `admin_coupons_cubit_test.dart`، `test/application/orders/customer_orders_cubit_test.dart`، `test/infrastructure/repositories/auth_repository_impl_test.dart`، `test/presentation/screens/cart/cart_screen_test.dart`، `product/product_detail_screen_test.dart`، `splash/splash_screen_test.dart`. لا يعتبر هذا إصلاح التطبيق. يراجع diff أنه تنسيق فقط. تحذيرا الموارد لهما L14، ولا ينشئ مجلدات وهمية لإخفائهما.

## L01 — وصفة كاملة جاهزة: ملكية خيارات السلة وcopyWith

**ملفا التعديل فقط:** `lib/application/cart/cart_cubit.dart` و`test/application/cart/cart_cubit_test.dart`. القراءة الإضافية: `lib/domain/entities/cart_item.dart`، `selected_option.dart`، `lib/infrastructure/dtos/cart_item_dto.dart`، `test/helpers/test_helpers.dart`. لا تعديل domain أو DTO أو generated code في هذه الدفعة؛ الحماية المطلوبة عند دخول السلة.

**R08: ما يتغير:** في `addItem` التقط `List<SelectedOption>.unmodifiable(selectedOptions)` قبل البحث والإضافة، واستخدم اللقطة في المقارنة والتخزين. في `addItems` أنشئ لكل عنصر نسخة `copyWith` بخيارات `List<SelectedOption>.unmodifiable(newItem.selectedOptions)`، ثم استخدم هذه النسخة في البحث والدمج والإضافة. لا تغير هوية الدمج الحالية القائمة على optionId ولا تضف مقارنة سعر جديدة. العناصر نفسها immutable؛ لا حاجة deep-clone لـSelectedOption. `loadCart` يبني قائمة جديدة عبر DTO الحالي؛ لا تغيّر serialization.

**R11: ما يتغير:** أضف sentinel خاصًا على مستوى الملف `const Object _notProvided = Object();`. في `CartState.copyWith` فقط، اجعل معاملات `appliedCouponId` و`deliveryZoneId` و`deliveryZoneName` من نوع `Object?` وقيمتها الافتراضية `_notProvided`. لكل حقل: إذا `identical(value, _notProvided)` احتفظ بالقديم، وإلا استخدم `value as String?`. بقية المعاملات typed كما هي. `removeCoupon` و`clearDeliveryZone` يظلان يمرران null صراحة؛ لا تستبدل null بسلسلة فارغة. لا تعديل حساب finalTotal أو سلوك add/remove الذي يعيد بناء CartState في نفس الدفعة.

**اختبارات مطلوبة داخل الملف الحالي، دون sleeps جديدة:**

1. منتج الاختبار، وقائمة أصلية فيها optionId=`cheese` وpriceAdjustment=10؛ بعد `addItem` غيّر الأصل إلى خيار آخر سعره20. خيارات السلة وسعرها يبقيان الأولين، والإجمالي يساوي `testProduct.price + 10`.
2. نفس المدخل باستخدام `CartItem` يمر إلى `addItems`؛ تعديل قائمة الخيارات الأصلية بعده لا يغير السطر المخزن.
3. أضف cheese ثم مجموعة مختلفة؛ يظهر سطران. أعد إضافة مجموعة مكافئة بالمعرفات بترتيب معكوس؛ تزداد كمية السطر المقابل فقط. لا تفترض مقارنة object identity.
4. طبق coupon=`coupon-a` وdiscount=15 ثم أزل الكوبون؛ المعرف null والخصم0، والعناصر والمنطقة لا تتغير.
5. اضبط zone=`zone-a` وname=`المنطقة أ` وfee=20 ثم امسحها؛ المعرف والاسم null والرسم0، والكوبون والعناصر لا تتغير.
6. على CartState يحمل القيم الثلاث: `copyWith(discountAmount: 5)` يحتفظ بها؛ `copyWith(appliedCouponId: null)` يمسح الكوبون فقط؛ وتمرير null صريح لحقلي المنطقة يمسحهما؛ وتمرير قيمة جديدة يستبدل القديمة. يمكن جمع حالات nullable في اختبار parameterized محدد.

تستخدم fixtures الموجودة وMockCartLocalDataSource الموجود دون mocks جديدة. أضف cleanup لـCubit الذي تنشئه الاختبارات الجديدة. لا توسع مهمة إصلاح دين الاختبارات القديم.

**RED:** نفذ اختبارات alias وnull على المصدر قبل التعديل؛ يجب أن تفشل بسبب اختلاف القيمة. **GREEN:** `flutter test --no-pub test/application/cart/cart_cubit_test.dart`. **قبول المراجع:** تشغيل هذا الملف و`test/domain/entities/cart_item_test.dart` و`test/presentation/screens/cart/cart_screen_test.dart`، تنسيق الملفين، وanalyze مع فصل تحذيري assets الموجودين. هذا يغلق R08 عند حدود CartCubit وR11 فقط؛ لا يثبت صحة checkout أو server prices.

## L02 — نتيجة عملية المدير

**ملفات الإنتاج:** `lib/application/admin/admin_orders_cubit.dart`، `lib/presentation/screens/admin/admin_order_detail_screen.dart`. **اختبارات:** نظيراهما في `test/application/admin/` و`test/presentation/screens/admin/`. يجب على المخطط جرد أي callers إضافية قبل فتحها للمنفذ.

**نتيجة جرد callers:** مستهلكا Cubit في الإنتاج هما `_updateStatus` و`_confirmPayment` في الشاشة نفسها، وزر الإلغاء يمر عبر `_updateStatus`. في الاختبارات: ملف Cubit وملف الشاشة المذكوران. لا تغير `OrderRepository.updateStatus` أو DataSource؛ نوع Either موجود أصلًا في Repository. نطاق L02 أربعة ملفات فقط. أضف import `dartz` مع `hide Order` لتفادي تصادم الاسم. عند Left استخدم `status: AdminOrdersStatus.error` مع failure وأبقِ orders كما هي. استدعاء Right لإعادة القراءة يحتاج guards في بداية loadOrders وبعد await قبل emit أو الاشتراك؛ لا تلمس باقي تصميم realtime. شاشة العملية تتحقق `_isUpdating` في بداية كل handler قبل await لمنع double tap.

**ترتيب RED المحدد:** أضف أولًا اختبارين إلى ملف Cubit الحالي على return-type القديم: بعد تهيئة orders بـloadOrders، صفّر/احسب سجل نداءات mock، اجعل updateStatus أو updatePaymentStatus يعيد Left(testServerFailure)، ثم تحقق بعد await أن orders القديمة باقية وfailure هي نفسها وأن getAllAdmin لم يُستدعَ مرة إضافية. هذان الاختباران يجب أن يفشلا بسبب تجاهل Left، لا بسبب نوع Future<void>. بعد إثباتهما نفذ تغيير return type والواجهة، ثم أضف اختبارات الواجهة والنجاح. استبدل فقط stubs `async {}` في اختباري advance/cancel بـRight<Failure, void>(null). fixtures RatingCubit السابقة تبقى كما هي.

**تفاصيل اختبار الواجهة:** اختبار فشل status يضغط «تأكيد الطلب» ويبقي زر «تأكيد الطلب» ولا يظهر نجاح التحديث؛ اختبار نجاح يظهر خطوة «بدء التحضير». اختبار فشل payment يستعمل order بطريقة wallet وحالة pending حتى يظهر زر التأكيد بالفعل، ثم يتحقق من بقاء الحالة ورسالة فشل دون «تم تأكيد استلام الدفع». يستخدم Robot محليًا داخل ملف الاختبار للتفاعلات الجديدة دون تحويل كل الاختبارات القديمة. لا تستخدم نصًا غير موجود للعثور على زر؛ اقرأ قسم الدفع في المصدر. حالة النجاح ثم فشل refresh تغطى في اختبار Cubit بمعرفة نتيجة Either مستقلة عن حالة قراءة القائمة. استخدم Completer لحالة dispose أثناء update، لا delays عشوائية.

القرار: تبقى واجهة Repository الحالية. يعيد `updateStatus` و`confirmPayment` من Cubit `Future<Either<Failure, void>>`. انتظر نتيجة المستودع وfold عليها؛ Left يضع failure في state دون استدعاء loadOrders أو تغيير قائمة الطلبات، ثم يعيد نفس Left. Right يعيد القراءة مع انتظارها ثم يعيد نجاح عملية الكتابة؛ فشل إعادة القراءة لا يحول كتابة مؤكدة إلى فشل ولا يختفي خطأ القراءة من state. تحقق isClosed بعد await قبل emit. لا تغير معنى payment_status='confirmed' هنا؛ توحيد SQL مهمة مستقلة.

الشاشة تنتظر النتيجة وتفحص mounted قبل أي setState. Left يبقي `_currentStatus` و`_currentPaymentStatus` ويعرض failure.message فقط؛ Right وحده يحدّثهما ويعرض النص الموجود للنجاح. finally يعيد loading. الضغط المتكرر أثناء العملية لا يستدعي repository ثانية. لا تحول Left إلى exception أو نجاح.

RED لكل من status/payment: repo يعيد Left مع read متاح يعيد Right؛ لا نجاح ولا تغيير قيمة ولا read بسبب الكتابة المرفوضة. GREEN: Right مرة واحدة يعرض النجاح، وRight كتابة ثم Left قراءة يحتفظ بالتمييز بين العمليتين؛ dispose أثناء await لا يولد setState بعد dispose. حدّث stubs المتأثرة بنوع الإرجاع صراحة.

## L03 — حفظ العنوان

**ملفات:** `lib/application/address/address_cubit.dart` و`lib/presentation/screens/profile/add_address_screen.dart`؛ اختبارات جديدة عند غياب ملف مناسب: `test/application/address/address_cubit_test.dart` و`test/presentation/screens/profile/add_address_screen_test.dart`، helpers المشتركة فقط عند الحاجة.

تأكد المخطط أن AddressCubit مسجل factory، وأن create/update في AddressRepository يعيدان Either<Failure, Address>. لا تحول repository إلى void؛ حوّل نتيجة Cubit فقط. في الشاشة أنشئ `late final AddressCubit _addressCubit` مرة واحدة في initState عبر sl، وأغلقه في dispose لأنه مملوك لهذا النموذج. guards في loadAddresses وبعد awaits تمنع emit إذا أغلق النموذج. لا تغلق singleton AuthCubit. fixture الشاشة: MaterialApp + BlocProvider<AuthCubit>.value بـAuthenticated(testUserProfile) الموجود، وتسجيل AddressCubit حقيقي بمستودع fake في GetIt وDeliveryZoneRepository fake؛ يجب استخدام اسم fixture الموجود فعلًا بعد قراءته، لا استيراد TestWrapper مفترض. فakes مشتركة في ملف `test/helpers/address_test_fakes.dart` جديد محدد لهذا التكليف، بفشل/نجاح مضبوطين وقائمة مناطق، دون backend.

القرار: `createAddress` و`updateAddress` يعيدان `Future<Either<Failure, void>>` بعد mapping نتيجة repository إلى void. استعمل نسخة من Map الإدخال عند إضافة user_id؛ لا تعدّل Map الممرر. Left يحفظ الخطأ ولا يعيد التحميل؛ Right يسمح بإغلاق النموذج بعد تأكيد الحفظ، وفشل refresh يسجل كفشل قراءة مستقل. تحصل الشاشة على Cubit واحد لكل عملية وتفحص النتيجة، لا تعتمد على استدعاء ثانٍ لـsl factory لقراءة state.

Left: يبقى النص والاختيار والنموذج، يظهر الخطأ، ويُعاد تفعيل الحفظ. Right: pop(true) مرة واحدة. `_loadZones` لا يستخدم `_zones.first` إذا كانت القائمة فارغة ولا يختار منطقة مختلفة صامتًا إذا اختفت المنطقة القديمة؛ يجعل الاختيار null ويطلب اختيار منطقة متاحة. لا تغير الإحداثيات الافتراضية إلى سياسة جغرافية جديدة؛ يسجل المخطط مشكلة الإحداثيات ويحددها قبل contract الطلب.

اختبارات: إنشاء وتعديل مع Left ثم retry ناجح؛ unmount أثناء الحفظ؛ zones فارغة مع عنوان قديم؛ عدم mutation لـMap المدخل. يحسم المخطط fixture/DI للشاشة قبل التسليم.

## L04 — حارس الإدارة

**ملفات الإنتاج فقط:** `lib/router/app_router.dart` وملف جديد `lib/router/admin_route_guard.dart`. **اختبار جديد:** `test/router/admin_route_guard_test.dart`. الشرط: path يساوي `/admin` أو يبدأ بـ`/admin/`، لا startsWith عامًا يقبل `/administrator`.

الـhelper المحدد `String? adminRouteRedirect({required String path, required UserRole? role})` يستورد UserRole من domain فقط: path غير إداري→null؛ إداري وrole=null→'/login'؛ إداري وrole ليس admin→'/home'؛ إداري وadmin→null. في redirect الحالي، بعد استثناء splash وقبل بقية auth redirects، مرّر matchedLocation وrole من Authenticated أو null؛ أعد نتيجة helper إن لم تكن null. لا تغير initialLocation ولا بناء الصفحات ولا ترتيب recovery مستقبلًا دون تكليف مستقل.

اختبر الـhelper بـDart table: '/admin' و'/admin/orders/order-a' لكل من null/customer/admin؛ '/administrator' و'/home' تعيدان null. اختبار widget صغير يستخدم GoRouter محليًا ومسارات وهمية للصفحات الثلاث مع نفس helper وValueNotifier<UserRole?> كـrefreshListenable؛ يبدأ admin ثم يتحول إلى customer ويثبت الوصول إلى home. هذا يثبت سياسة التنقل والتحديث؛ المراجع يفحص ربط helper بالـappRouter الحقيقي، ويظل اختبار deep link native ضمن L19. لا يستورد الاختبار appRouter العالمي الذي يهيئ GetIt/services عند تحميل المكتبة.

قبل بناء أي صفحة admin: غير المسجل يرجع login؛ Authenticated ودوره ليس admin يرجع `/home`؛ admin مسموح. لا تغير منطق splash/recovery في هذه الدفعة. اختبار deep link إلى صفحة فرعية والتبديل admin→customer أثناء وجود المسار. نجاح هذا الاختبار لا يغلق RLS؛ R02 لا يغلق إلا مع L06.

## L05–L07 — الأمان والطلب: عقود إلزامية قبل تسليم SQL

**أدلة المصدر:** migration `20260620_000005_app_config_table.sql` و`20260620_000004_improve_notification_trigger_logging.sql` و`20260620_000003_create_order_rpc.sql`؛ `supabase/schema.sql`؛ `supabase/functions/send-notification/index.ts` و`send-push-notification/index.ts`؛ `lib/infrastructure/datasources/remote/order_remote_data_source.dart`، `lib/domain/repositories/order_repository.dart`، `lib/infrastructure/repositories/order_repository_impl.dart`، `lib/application/orders/customer_orders_cubit.dart`.

**L05:** يحدد المخطط أولًا الدالة والـtrigger المستخدمة بالفعل ومن يملك حق إرسال Push. تنظيف السر من الشجرة الحالية يتم دون طباعته، وتقييد جدول الإعدادات يتم في migration أمامية، لا اعتمادًا على تحرير migration قديم فقط. يمنع SELECT/INSERT/UPDATE/DELETE لـanon/authenticated على القيم السرية. لا تُنقل قيمة service-role إلى client أو ملف config. تدوير المفتاح الفعلي وفحص الأثر يعتمدان على وصول المالك؛ تنظيف المصدر لا يثبت إبطال المفتاح. لا يختار Luna من تلقائه Vault أو cron أو webhook أو تعطيل الإشعارات كبديل.

**L06، مدخل حاسم:** export معقم يتضمن tables/columns/types/defaults/constraints/indexes/functions/triggers/policies/grants/storage ونسخ migrations المطبقة، دون صفوف عملاء أو أسرار. المخطط يكتب جدول drift ويثبت ترتيب bootstrap والـforward migrations وأسماء الدوال وسياسة الملكية. لا تطبق local schema.sql على بيئة منشورة. دور signup='customer' بصرف النظر عن metadata. حقول self-update قائمة سماح محددة من المخطط تستبعد role/id. دالة فحص admin محدودة وsearch_path ثابت تتجنب استعلام RLS الدائري. يمنع العملاء من تغيير order/payment state بصورة عامة. جدول انتقالات الحالة وحقوق إلغاء العميل ومدير تغيير الدور لا تُخترع.

**L07، قرارات العقد المطلوبة:** اسم endpoint المقترح `create_order_v2` يُثبت في ورقة مستقلة بعد L06. الطلب يحتوي requestId وproductId/quantity/optionIds وfulfillmentType وaddressId عند delivery وcouponCode أو معرف واحد مثبت وscheduledFor وnotes ومعلومات اتصال مسموحة. لا يقبل customerId كسلطة أو status أو أسعار أو مجموع مخفض من العميل. الخادم يشتق auth.uid، ويقرأ المنتجات والخيارات والعنوان والمنطقة والمطعم والكوبون، ويحسب المبلغ باستخدام numeric لا float.

يحدد المخطط حرفيًا في ورقة العقد: JSON request/response وأسماء الأعمدة، سياسة السعر الذي تغير أثناء checkout، طريقة التقريب، حد الكوبون وأساس min_order، سياسة جدولة المطعم ومنطق مناطق التوصيل، جدول حالات الدفع، error codes→Failure. حتى اكتمال هذه الحقول الحالة «يحتاج حسم المخطط»، وليس «اكتب أفضل ما تراه».

قرارات ثابتة: مفتاح فريد مركب (customer_id, request_id)؛ مفتاح العميل نفسه يعاد استخدامه بعد timeout/restart للنية نفسها؛ payload مختلف بالمفتاح نفسه يُرفض conflict؛ نجاح واحد يعيد Order كاملًا بعناصره فلا يعتمد على قراءة ثانية لإثبات الإنشاء. تزامن نفس المفتاح لا ينتج unique-violation مرئية بدل النتيجة السابقة. حجز آخر استخدام كوبون داخل نفس المعاملة مع قفل/تحديث شرطي، وrollback لا يستهلكه. ترتيب locks محدد لتقليل deadlocks. لا إعادة استهلاك عند retry. لا حذف legacy RPC قبل خطة ترحيل العميل، ولا إبقاؤه مفتوحًا كمسار التفاف مالي.

اختبارات SQL المطلوبة قبل الاعتماد: anon مرفوض؛ A لا ينشئ باسم B؛ metadata role غير مؤثر؛ self-update role مرفوض؛ لا recursion؛ empty cart/quantity<=0/خيار أجنبي/منتج متوقف/عنوان B مرفوضة؛ pickup/dine-in رسوم0 وعنوانnull؛ خصم وحدود وتوقيت وفق العقد؛ عميلان وآخر كوبون ينجح واحد؛ نداءان بنفس المفتاح order واحد وعناصر مرة وusage مرة؛ قطع الرد بعد commit ثم retry يعيد نفس order. تجرى فقط على disposable target مؤكَّد.

## L08 — Checkout

**ملفات:** checkout_screen، CartCubit، CustomerOrdersCubit وواجهات order المذكورة أعلاه. يجهز المخطط `lib/application/checkout/checkout_cubit.dart` وعقد state/action واختباره قبل استخراج منطق الشاشة؛ لا يختار Luna بنية Checkout جديدة.

قواعد لا تتغير: التحويل من delivery إلى pickup أو dineIn يصفر fee ويمسح addressId/zoneId/zoneName/selectedAddress ورسالة خطأ العنوان، ويحافظ على عناصر السلة. العودة إلى delivery تتطلب اختيار عنوان صالح ولا تعيد معلومات منسية. القيم المرسلة والإجمالي المعروض مشتقان من نفس state. خصم الكوبون يعاد التحقق منه مع تغير الإجمالي طبقًا لـL07. جدولة مفعلة بلا وقت أو وقت غير مستقبلي تفشل قبل الإرسال وتبقى المدخلات؛ الساعة injectable في الاختبار. لا successful dialog إلا placed من نفس Cubit الذي نفذ الطلب؛ لا clearCart عند failure؛ لا نداء incrementUsage من الشاشة بعد العقد الذري. أثناء placing تتجاهل المحاولة الثانية.

مصفوفة الاختبار: delivery→pickup، delivery→dineIn، العودة، كوبون موجود/محذوف، وقتnull/ماضٍ/صالح، فشل شبكة ثم retry، تغير سعر، مطعم مغلق/مشغول، required options. قيم رسوم الاختبار20 والمنتج100 والخصم10 تعطي110 للتوصيل و90 للاستلام؛ الخادم يظل المرجع النهائي. الحسابات الرقمية هنا fixtures فقط.

## L09–L11 — الحساب والجلسات والإشعارات

**L09:** ملفات auth_cubit/auth_state وAuthRepository/Impl/AuthRemoteDataSource وشاشات auth وRouter. يثبت المخطط نوع نتيجة signup (session موجودة أو pending verification) من SDK المقفل. pending verification تُنهي loading وتظهر تأكيد البريد وإعادة إرسال بنتيجة خطأ/نجاح؛ لا تسجيل دخول وهمي. يثبت رابط recovery من إعداد Supabase المصرح ثم يحدد شاشة `reset_password_screen.dart` وحالة recovery في AuthState وطريقة تحديث password الموجودة في SDK. recovery يسبق تحويل المستخدم العام إلى home، ولا تقبل شاشة reset كإذن لتغيير الحساب دون session recovery. اختبارات رابط صالح/منتهي، cold/warm، كلمة غير صالحة، logout أثناء الطلب.

حسم المصدر: signUp يعيد `Either<Failure, AuthResponse>` بالفعل؛ لا تضف result DTO آخر لهذه المشكلة. Right مع session=null ينقل إلى حالة جديدة `AuthAwaitingEmailVerification(email)` في auth_state.dart، تعرضها register_screen مع النص «راجع بريدك الإلكتروني لتأكيد الحساب» وزر إعادة الإرسال. Right مع session موجودة يعتمد مسار signedIn الحالي دون انتظار بلا نهاية؛ بعد await تحقق من عدم overwrite لحالة authenticated وصلت عبر stream. حدث `AuthChangeEvent.passwordRecovery` موجود ضمن SDK ويجب أن يسبق signedIn routing. أضف `AuthRecoveryRequired` ومسار `/reset-password`؛ حدث signedOut يخرج منه. RemoteDataSource يستخدم `auth.updateUser(UserAttributes(password: value))` و`auth.resend(type: OtpType.signup, email: email)`؛ هاتان الواجهتان موجودتان في gotrue2.20.0. تضيف Repository طرقًا تعيد Either للنتائج وتستخدم Cubit بدل Supabase مباشرة في forgot_password_screen. يظل redirectTo/associated-links مدخل إعداد خارجي لا URI مخترعًا. اختبارات SDK mocks لا تغلق اختبار البريد الحقيقي.

**L10:** ملفات main.dart وbiometric_service.dart وauth infrastructure. المخطط يقرأ LocalStorage interface واسم مفتاح legacy من إصدار supabase_flutter المثبت؛ لا يتخيل API. محول secure storage يرحّل الجلسة: read legacy→write secure→read/verify→remove legacy؛ عند فشل secure write لا يمسح المصدر ولا يسجل محتواه. logout يمسح المخزنين ويعالج فشل الإزالة. موافقة biometrics مرتبطة بالـuserId، لا consent عام ولا حفظ password لحساب B بموافقة A. حساب A→logout→B ثم restart اختبار إلزامي. نتائج migrations الحساسة ومخاطر backup/restore توثق قبل التسليم.

حسم API من supabase_flutter2.12.4: الملف الجديد `lib/infrastructure/datasources/local/secure_auth_local_storage.dart` يعرّف `SecureAuthLocalStorage extends LocalStorage` بتنفيذ initialize، hasAccessToken، accessToken، removePersistedSession، persistSession(String). يحقن FlutterSecureStorage وSharedPreferences وpersistSessionKey في constructor لتجربتها دون منصة. مفتاح legacy الحالي يبنى بنفس المصدر `sb-${Uri.parse(url).host.split('.').first}-auth-token`، ولا تُكتب قيمته الفعلية أو محتواه في تقرير. الربط في `Supabase.initialize(authOptions: FlutterAuthClientOptions(localStorage: ...))`. secure read موجود يفوز على legacy عند اختلافهما، وبعد تأكيد قراءته يزال legacy؛ لا تسترجع جلسة legacy أقدم فوق جلسة secure أحدث. SDK ينادي بعض storage operations دون انتظار، لذلك لا يكفي افتراض أن signOut انتظر تنظيف adapter: يضيف AuthRepositoryImpl تنظيفًا صريحًا منتظرًا، ويعيد Failure إذا فشل مع عدم السماح للواجهة بادعاء إزالة المخلفات. serialise writes/remove داخل adapter لمنع كتابة token قديم بعد logout، وتختبر هذه المنافسة بـCompleter.

PKCE له مخزن مستقل `GotrueAsyncStorage` بواجهات getItem/removeItem/setItem؛ لا تعتبر ترحيل session ترحيلًا تلقائيًا للـcode verifier. يحدد تكليف منفصل استخدام secure adapter له إذا كان recovery يحتاجه. على Web لا تدّع ضمان keystore؛ إعداد Web يظل موثقًا منفصلًا ولا تُكسر اختبارات browser لتحسين native. اسم consent في preferences يصبح مرتبطًا بالـuserId، ويُلغى consent القديم العام عند أول migration بدل نقله تلقائيًا لكل الحسابات. يمنع saveCredentials قبل إعادة موافقة الحساب الحالي.

**L11:** ملفات push_notification_service.dart وapp_router.dart وorders_screen.dart وصفحات admin notification/detail. المصدر الحالي يتضمن أصلًا مسار العميل `/orders?expand=`؛ لا يعيد المنفذ شاشة order_detail محذوفة من التقرير القديم. الـpayload غير موثوق: تحقق reference_type/reference_id، واحتفظ بمعرف فقط، ثم حمّل Order عبر Repository مع RLS؛ لا `extra as Order` دون fallback. cold-start يؤجل الوجهة حتى auth/router جاهزين. إزالة الحساب أو logout تمسح الوجهة، وحدث ثانٍ يعدل expand ولا يعتمد initState وحده. يحدد المخطط resolver وDI وloading/not-found state بالاسم قبل التنفيذ. اختبارات admin/customer/غير مسجل/order غير مملوك/طلب محذوف/حدث ثانٍ/close أثناء fetch. لا صلاحيات إدارة من payload.

## L12–L13 — التقارير والطباعة

**L12 ملفات:** report_remote_datasource.dart، report_repository_impl.dart، admin_reports_cubit.dart، admin_reports_screen.dart، csv_exporter.dart. عقد النطاق: أول يوم محلي في Africa/Cairo inclusive وبداية اليوم التالي لآخر يوم exclusive؛ حوّل الحدين إلى UTC وفق zone rules، لا offset ثابت ولا اعتماد timezone جهاز المطور. غيّر `.lte` إلى `.lt` فقط بعد توحيد جميع callers إلى endExclusive، ولا تضف يومًا مرتين. يثبت المخطط استخدام حزمة timezone المقفلة/المتاحة قبل الكود. CSV والأرقام من نفس التقرير والفترة. اختبارات يوم واحد، منتصف اليوم، آخر لحظة، بداية اليوم التالي مستبعدة، عبور DST، والجهاز في timezone مختلفة.

حسم الحزمة: timezone0.11.0 موجودة في package_config كاعتماد transitive وليست direct في pubspec. التكليف يضيف dependency مباشرًا **لنفس الإصدار0.11.0 فقط**، ويمنع أي upgrade آخر. بعد `flutter pub get` يجب أن يكون اختلاف lock متعلقًا بتصنيف dependency فقط. أضف helper `lib/core/utils/report_date_range.dart`، يعيد حدين UTC بعد بناء `TZDateTime(cairo, start.year, start.month, start.day)` و`TZDateTime(cairo, end.year, end.month, end.day + 1)` من تواريخ calendar التي اختارها المستخدم. initialise database مرة واحدة عبر `timezone/data/latest.dart`، لا setLocalLocation عالميًا. استخرج date الافتراضي من `TZDateTime.from(now, cairo)` بدل تاريخ جهاز قد يكون في اليابان. defaults وchips/custom picker تستخدم نفس التعريف، والـrepository يستقبل startInclusiveUtc/endExclusiveUtc ولا يحوّل مرة أخرى. حد DST يبنى باليوم التقويمي التالي، لا بإضافة Duration(hours:24).

المشاركة: احسب Rect لزر CSV عبر Builder/RenderBox صالح وأرسله sharePositionOrigin وانتظر الاستدعاء وتعامل مع الإلغاء كإلغاء والفشل كخطأ. لا تعتبر فتح share sheet تسليمًا ناجحًا لملف. إذا تغير share_plus في L16 تطابق API الجديدة المعتمدة؛ لا استعمال مثال من إصدار آخر. تحقق iPad portrait/landscape/split-view يبقى native gate.

**L13 ملفات الإنتاج:** thermal_printer_service.dart وprint_repository_impl.dart؛ PrintRepository وcallers للقراءة فقط لأن العقد bool لا يتغير. لا BuildContext في domain ولا static context طويل العمر. إلغاء الطباعة يعيد false دون نجاح؛ exception يحوَّل إلى Failure في repository. إذا كانت هناك كتابة order_prints في callers فتُراجع ولا تضاف كتابة جديدة تخمينية؛ نجاح SDK لا يثبت خروج ورقة فعلية. استخدم خطوط Cairo المتتبعة في إيصال offline بدل الاعتماد الإجباري على تنزيلها. اختبار إلغاء/رفض/نجاح ثم إيصال عربي على الطابعة المستهدفة.

قرار التنفيذ بعد فحص printing5.14.3: استبدل اختيار printer المعتمد على `_rootContext!` بـ`Printing.layoutPdf` الذي يعيد Future<bool> ولا يحتاج BuildContext، باستخدام `format: _paperSize` وonLayout يعيد الإيصال. هذا يستخدم حوار الطباعة الأصلي؛ لا حاجة descriptor جديد أو تغيير PrintRepository. احذف static context وinit بعد إثبات عدم وجود caller عبر rg. أدخل callback `Future<bool> Function(Uint8List bytes)` إلى constructor الخدمة، افتراضيًا دالة خاصة تستدعي layoutPdf، لتختبر true/false/throw دون طابعة. return هو نتيجة SDK الفعلية، وليس true غير مشروط. التحقق بالطابعة الحقيقية باقٍ.

## L14–L16 — البناء والموارد

**L14 ملفات:** .gitignore، pubspec.yaml والموارد الأصلية في assets/images وassets/icon وAndroid mipmap وiOS asset catalogs. جرد محدد من source: splash_logo-removebg-preview.png، onboarding_food.png، onboarding_delivery.png، onboarding_payment.png، ومدخل launcher `assets/icon/app_icon.jpg`. يفحص المخطط وجود هذه الملفات في نسخة المستخدم وتطابق أبعادها ومصدرها قبل النسخ. لا صورة مولدة أو placeholder ولا حذف استخدامها لإسكات analyzer. أضف استثناءات ignore ضيقة للموارد اللازمة فقط. assets/icons لا توجد له مراجع في البحث الحالي: يراجع المخطط مجلده الأصلي؛ إن لم يوجد استعمال فعلي تزال declaration وحدها، لا صور أخرى. اختبر كل path من شجرة tracked نظيفة لا من build cache.

تأكد المخطط من وجود الملفات الخمسة المذكورة في نسخة المستخدم الأصلية؛ assets/icons لم يظهر كمجلد بملفات في الجرد. الأبعاد وتطابق مدخل launcher مع الحزم ما زالا فحصًا مطلوبًا قبل أي توليد. هذا يتيح استعادة الموارد الأصلية ولا يتطلب تصميم علامة تجارية جديدة.

**L15 ملفات:** android/app/build.gradle.kts وandroid/.gitignore وملف إعداد نموذجي بأسماء حقول دون قيم سرية. release يقرأ upload keystore من إعداد محلي/CI ويمنع fallback إلى debug. missing keys يفشل برسالة آمنة وقت مهمة release فقط؛ debug/test لا يطلبان أسرارًا. لا تغيير com.tarwi2a.app دون قرار هوية. افحص merged target/minSdk من الحزمة. الحد الحالي لتطبيق هاتف جديد API36، وتحقق16KB يشمل alignment لكل native .so وتثبيت/تشغيل على page-size16KB، لا مجرد NDK حديث. مفتاح توقيع وشهادة final AAB والرفع الداخلي بوابات مالك.

**L16 ملفات:** ios/Runner/Info.plist، Runner.entitlements، AppDelegate.swift، Runner.xcodeproj/project.pbxproj، وpubspec/locks فقط بعد تكليف upgrade محدد. ربط Firebase plist الصحيح في Resources مرة واحدة؛ تحقق bundle id يطابق إعداد Apple الفعلي؛ ربط CODE_SIGN_ENTITLEMENTS لكل configuration. تثبيت تكامل FCM (swizzling أو يدوي كامل) قرار المخطط بعد فحص delegate، وليس إضافة flags عشوائية. أوصاف كاميرا/صور تطابق رفع صور الإدارة، لا صلاحية غير مستخدمة. لا hardcode production APNs entitlement لإخفاء signing.

قبل ترقية connectivity_plus/share_plus: جدول source API الحالي→الإصدار المحدد→تغييرات callers→حد Flutter/Dart/iOS→manifest coverage، يكتبه المخطط من changelog الرسمي وSDK المقفل. لا يختار Luna latest. macOS job يستخدم Xcode/SDK المطلوبين وقت الإرسال ويُثبت وجود Firebase resources والـprivacy manifests داخل archive والتوقيع وAPNs. unsigned build يساعد compilation فقط. iPhone/iPad camera/photos/FaceID/Push/sharing/printing اختبارات مستقلة.

مراجع أصلية تحقق منها المخطط أثناء إعداد الخطة: [Target API](https://developer.android.com/google/play/requirements/target-sdk)، [16KB](https://developer.android.com/guide/practices/page-sizes)، [Apple upcoming requirements](https://developer.apple.com/news/upcoming-requirements/). تُراجع مجددًا قبل التقديم؛ لا يستنتج القبول من نسخة تقرير قديمة.

## L17–L18 — السياسات والحذف والمحتوى

**L17:** settings_screen.dart وwebsite مع AuthRepository/Deletion endpoint جديد بعد تثبيت اسمه وعقده. يبدأ المخطط بجرد بيانات Supabase/Firebase/Sentry والصور وTokens ومزودي الدفع الخارجيين، ويملأ جدول delete/anonymize/retain/duration/reason لكل عمود ونسخة order snapshot. مدة الاحتفاظ ومعلومات الدعم والدول وروابط الصفحات يقررها المالك. لا يولد Luna نصًا قانونيًا «معتمدًا» أو يختار عدد أيام. رابط عام خارجي لطلب الحذف مع مسار داخل التطبيق، والتأكيد يوضح الأثر الفعلي.

Endpoint الحذف يتحقق من جلسة صاحب الطلب وrecent reauth حسب العقد، ولا يقبل userId كسلطة. خدمة admin على الخادم فقط؛ حذف قابل للاستكمال بعد partial failure ومرجع job لا يحتوي بيانات خاصة. تعطيل Tokens/الجلسات وتنظيف storage والتقييمات والـorder snapshots يطابق الجدول المعتمد. لا success نهائي إذا بقيت خطوات إلزامية، ولا تسرب وجود حساب عبر المورد العام. تختبر هوية A/B، replay، فشل خطوة وسطى، ثم استكمالها. يثبت المخطط ترتيب التعامل مع foreign keys قبل migration.

**L18:** rating_remote_data_source.dart وRatingRepository/rating_cubit/product_reviews_screen وadmin moderation جديدة عند اعتماد العقد. يحدد المالك إبقاء التعليقات العامة أو تأجيلها؛ لا يخفيها Luna من تلقائه. إذا بقيت: يحدد المخطط report/block/moderation schema وRLS، public projection لا يعتمد على قراءة order_items الخاصة ولا يكشف order/customer IDs بلا حاجة، ومن يملك مراجعة البلاغات. اختبارات report/block/remove وعدم كشف الطلب. المفضلة الحالية تحتاج قرار التخزين والحسابات قبل تنفيذها؛ لا يعرض زرًا يوهم بالحفظ دون persistence. مسار payment proof القديم إما تنفيذ بعقد أو إزالته من التنقل المعلن بقرار محدد؛ لا رسالة نجاح محلية مزيفة.

## L19 — قبول نهائي مستقل لكل متجر

**ملفات:** .github/workflows/flutter-ci.yml ثم jobs native محددة؛ docs الخاصة بالتسليم. ثبّت runtime versions التي نجحت، dependency locks، analyze صارم، format غير كتابي، tests مع تقرير محفوظ وcoverage. secret scan يخرج paths/redacted findings فقط؛ لا ينشر artifact يتضمن أسرارًا. Android وmacOS jobs منفصلان؛ غياب signing يوقف signed-release gate ولا يتحول إلى نجاح/skip صامت.

سيناريوهات وظيفية على disposable backend وحسابين عميل ومدير: signup/verify/login/recovery/logout/account-switch، تصفح/خيارات/سلة/كوبون/عنوان، الأنواع الثلاثة، cash/wallet/InstaPay دون تحويل حقيقي، تتبع/إلغاء/تقييم، إدارة menu/zones/coupons/business/reports/printing/audit، ثم offline/retry/realtime/restart. جدول جهاز Android minimum/current/16KB وiPhone/iPad يسجل ما جُرّب فعلًا. small-screen 360px/text scaling2/RTL/keyboard يختبر دون زيادة viewport لإخفاء overflow؛ لا يُعلن معيار أداء رقمي غير مقاس.

Google Play وApp Store لهما verdict مستقل: blocker مفتوح يعني غير معتمد. تجهيز screenshots والوصف والفئة العمرية وبيانات الدعم وreviewer access/data disclosures وفق التطبيق النهائي؛ حسابات المراجع test-only. تسجيل/شراء الحسابات وإرسال production لا يحدثان تلقائيًا. ترسل الحزمة القابلة للمراجعة أولًا للمالك عند الحاجة للاعتماد النهائي.

## 5. بوابة المراجع بعد كل تنفيذ

يفحص المراجع فرق ملفات التكليف مقارنة بما قبل تسليمه، ويتحقق من عدم تعديل العقود أو حذف التغطية. يعيد الاختبار الأقرب ثم اختبارات المستهلكين عند تغيير API، ويشغّل analyze والتنسيق. النتائج الحالية القديمة تسجل بأسمائها ولا تُسمى passing. لا تكرار full suite دون تغيير يبرره؛ عند نهاية دفعة إنتاج مترابطة تُشغل suite كاملة وتحفظ النتيجة. لا ينتقل إلى تكليف يحتاج معلومة لم تُحسم. القرارات المفتوحة السابقة مسؤولية المخطط، وليست أسئلة تصميم محولة إلى Luna.
