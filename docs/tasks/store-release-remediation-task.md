# قائمة مهام تنفيذ جاهزية المتجرين

> التنفيذ يسير بالترتيب. قبل كل مجموعة يجب تحميل الـSkills المكتوبة في الخطة، وتطبيق Red → Green → Refactor لكل إصلاح.

## المرحلة 0 — بيئة الاختبار

- [ ] حفظ Commit وحالة Git والملفات غير المتتبعة
- [ ] إنشاء فرع `codex/store-release-readiness`
- [ ] تحميل `implement-feature` و`common-git-collaboration` و`common-tdd` و`flutter-testing` و`dart-tooling`
- [ ] إصلاح DI setup في اختبار `injection_container`
- [ ] إضافة RatingCubit إلى Fixture شاشة تفاصيل طلب الإدارة
- [ ] إضافة CouponCubit وBusinessProfileRepository إلى Fixture Checkout
- [ ] إضافة NotificationsCubit إلى Fixture Home
- [ ] Stub عمليات Product Options غير المتزامنة
- [ ] تحديث 5 توقعات UI القديمة بعد تأكيد النص والسلوك المطلوبين
- [ ] نقل بيانات Integration إلى إعدادات صريحة دون Defaults
- [ ] دمج اختبارات R08 وR10 وR11 في الاختبارات الحالية ومشاهدة فشلها الصحيح
- [ ] تشغيل Format وAnalyze والاختبارات وتسجيل Baseline الجديد

## المرحلة 1 — الأمن وقاعدة البيانات

- [ ] تحميل `flutter-security` و`common-security-audit` و`auth-review` و`common-owasp`
- [ ] إزالة القيمة المرتفعة الصلاحيات من الشجرة الحالية دون استخدامها
- [ ] إضافة Migration أمامية لحماية/إزالة `app_config` من وصول العملاء
- [ ] نقل Secret الإشعارات إلى مسار server-side معتمد
- [ ] إعداد تعليمات المالك لتدوير المفتاح وتنظيف التاريخ دون تنفيذ مدمر تلقائيًا
- [ ] فرض دور `customer` عند التسجيل وتقييد أعمدة profile القابلة للتعديل
- [ ] استبدال سياسة الدور الدائرية بدالة آمنة ذات `search_path` ثابت
- [ ] تصميم واختبار عقد Order RPC الجديد ومفتاح Idempotency
- [ ] جعل السعر والرسوم والخصم والحالة والهوية خادمية
- [ ] دمج استهلاك الكوبون داخل معاملة الطلب
- [ ] توحيد حالات الدفع في SQL وDart
- [ ] تقييد Execute وإلغاء `PUBLIC` غير اللازم
- [ ] ترحيل Session إلى تخزين آمن وتنظيف القيمة القديمة
- [ ] تشغيل مصفوفة مجهول/A/B/مدير على المشروع التجريبي

## المرحلة 2 — السلة وCheckout

- [ ] تحميل `common-tdd` و`flutter-testing` و`flutter-error-handling` و`common-debugging`
- [ ] نسخ خيارات المنتج دفاعيًا عند الإضافة
- [ ] إصلاح مسح couponId وdeliveryZoneId
- [ ] مسح رسوم وعنوان ومنطقة التوصيل عند تغيير نوع الطلب
- [ ] فرض الخيارات المطلوبة والتوفر والحد الأدنى
- [ ] منع الوقت المجدول الفارغ أو الماضي
- [ ] الاحتفاظ بمفتاح الإرسال عند Retry
- [ ] اختبار الضغط المتكرر وTimeout والسعر القديم والكوبون المتزامن
- [ ] تشغيل اختبارات Cart وCheckout وOrder كاملة

## المرحلة 3 — الحساب والإشعارات

- [ ] تحميل `auth-review` و`flutter-security` و`flutter-navigation` و`flutter-notifications`
- [ ] إضافة حالة انتظار تأكيد البريد وإعادة الإرسال
- [ ] تنفيذ Recovery Deep Link ونموذج كلمة المرور الجديدة
- [ ] إصلاح نتيجة حفظ العنوان
- [ ] ربط موافقة البصمة بالحساب وتنظيفها عند التبديل
- [ ] جعل Route الطلب يحمل بالمعرف بدل Cast إجباري
- [ ] تأجيل تنقل Push البارد حتى جاهزية التطبيق
- [ ] اختبار إشعار ثانٍ والحساب المسجل وغير المسجل
- [ ] اختبار Logout وإلغاء Tokens والاشتراكات

## المرحلة 4 — الإدارة والتقارير

- [ ] تحميل `flutter-error-handling` و`flutter-testing` و`common-performance-engineering`
- [ ] معالجة نتيجة تحديث حالة الطلب
- [ ] معالجة نتيجة تأكيد الدفع
- [ ] إصلاح نهاية نطاق التاريخ
- [ ] انتظار نتيجة CSV وإضافة iPad popover origin
- [ ] إزالة Context المخزن من خدمة الطابعة ومعالجة النتيجة
- [ ] تنفيذ المفضلة أو إخفاؤها حسب القرار
- [ ] إنشاء Projection آمن للتقييمات العامة
- [ ] قياس استعلامات التقارير على بيانات تجريبية

## المرحلة 5 — الخصوصية والحذف والمحتوى

- [ ] تحميل `flutter-security` و`common-security-standards` و`common-documentation`
- [ ] اعتماد المالك لسياسة الحذف والاحتفاظ
- [ ] تنفيذ حذف الحساب وإلغاء الجلسات وDevice Tokens
- [ ] تنفيذ إخفاء/حذف البيانات الشخصية حسب السياسة
- [ ] إنشاء صفحة طلب حذف عامة وربطها
- [ ] ربط الخصوصية والشروط والدعم داخل التطبيق والموقع
- [ ] تنفيذ الإبلاغ والحظر وModeration وسجل التدقيق
- [ ] إعداد Data Safety وApp Privacy من جرد البيانات الفعلي

## المرحلة 6 — Android

- [ ] تحميل `flutter-devops` و`flutter-cicd` و`flutter-security` و`common-mobile-visual-testing`
- [ ] اعتماد وتتبع موارد الصور والأيقونات
- [ ] إعداد Release Signing من Secrets
- [ ] مراجعة وإزالة Permissions غير المستخدمة
- [ ] بناء AAB من Clone نظيف مع Symbols خاصة
- [ ] فحص الهوية والإصدار والشهادة وTarget API والـManifest
- [ ] فحص مكتبات ومحاذاة 16KB
- [ ] اختبار الحد الأدنى والحالي و16KB
- [ ] اختبار RTL والنص الكبير والإشعارات والبصمة والكاميرا وWhatsApp
- [ ] إضافة Android Release job إلى CI

## المرحلة 7 — iOS

- [ ] تحميل `xcode-project-setup` و`flutter-notifications` و`flutter-security` و`flutter-cicd`
- [ ] تجهيز ربط Firebase Resource الصحيح
- [ ] إضافة أوصاف الكاميرا والصور
- [ ] تجهيز Entitlements وCapabilities
- [ ] ترقية `connectivity_plus` و`share_plus` بصورة موجهة واختبارهما
- [ ] إعداد macOS CI دون شهادات في Git
- [ ] عند توفر Mac: تشغيل `swift --version` قبل أي تعديل Xcode
- [ ] عند توفر Mac: ربط الموارد بأداة Swift/Xcode دون Ruby
- [ ] بناء Archive بـXcode 26+ وفحص Privacy Report والتوقيع
- [ ] اختبار iPhone وiPad وPush والمشاركة وSplit View وVoiceOver

## المرحلة 8 — الاعتماد النهائي

- [ ] تحميل `flutter-cicd` و`flutter-testing` و`common-mobile-visual-testing` و`common-store-changelog`
- [ ] تشغيل Format وAnalyze وUnit وWidget وCoverage
- [ ] تشغيل Integration بحسابين ومدير على Supabase التجريبي
- [ ] اختبار Offline وRetry وRealtime وResume
- [ ] قياس Startup والتمرير والصور والتقارير
- [ ] إجراء مراجعة RTL وإتاحة الوصول للشاشات الحرجة
- [ ] إنتاج AAB وArchive نهائيين والتحقق منهما
- [ ] تجهيز وصف وصور وRelease Notes وتعليمات المراجع
- [ ] مراجعة Data Safety وApp Privacy مع المالك
- [ ] إجراء مراجعة كود وأسرار وDiff نهائية
- [ ] اعتماد Google Play بصورة مستقلة
- [ ] اعتماد Apple App Store بصورة مستقلة

## بوابات ينفذها المالك

- [ ] تدوير/إلغاء مفتاح Supabase من حساب المالك
- [ ] توفير وصول للمشروع الصحيح وحسابي عميل وحساب مدير للاختبار
- [ ] اعتماد سياسة الخصوصية والحذف والاحتفاظ والدعم
- [ ] توفير أيقونة وهوية بصرية نهائية معتمدة
- [ ] توفير Upload Key وحساب Google Play بصورة آمنة
- [ ] توفير Mac وApple Signing وiPhone/iPad
- [ ] تحديد الدول والفئة العمرية وبيانات الدعم وقرار التقييمات العامة
