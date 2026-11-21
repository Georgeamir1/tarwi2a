# Tarwi2a — Google Play and Apple App Store readiness review

**Review window:** 26–27 August 2026 (Africa/Cairo)  
**Source baseline:** `9d15043e95af02c2faa3a0b03b12b89c76c5c8ac`  
**Scope:** customer and admin app, checked-in Supabase backend, Android/iOS configuration, and store requirements.  
**Google Play verdict: NOT READY. Apple App Store verdict: NOT READY.**

This is a review and remediation backlog, not an implementation of the fixes. No application source, production configuration, database schema, credentials, or store submissions were changed. Tests used mocks and a separate checkout. The owner identified the Supabase project as disposable, but no backend records were created because the configured endpoint/access could not be established.

## 1. Executive assessment

The app has substantial implemented functionality and a useful existing test suite. It also has release-blocking security, order-integrity, native configuration, and store-compliance problems. Four isolated executable probes reproduced cart and admin-mutation defects against unchanged application code. Other findings are supported by source traces, with deployment and device limitations stated explicitly.

**First actions:** investigate the committed privileged credential without using it; establish the correct accessible Supabase project; close role/order authorization gaps; repair checkout/admin correctness; restore reproducible native builds; complete privacy, deletion, and review-moderation requirements.

### Evidence and baseline

| Check | Observed result | Meaning |
|---|---|---|
| Isolated checkout | Created from the commit above; existing user files preserved | Review builds do not modify the original app |
| `flutter pub get --enforce-lockfile` | Passed; dependency lock unchanged | No dependency upgrade was performed |
| Strict `flutter analyze --no-pub --fatal-warnings --fatal-infos` | Failed: 0 errors, **2 warnings**, 91.3 seconds | Both declared asset directories are absent in a clean checkout |
| Non-writing Dart format check | Exit 1; **68 of 329 files** would change | Formatting was checked, not applied |
| Existing `flutter test --no-pub --coverage --reporter json` | Exit 1; **316 passed, 28 failed outcomes**, 0 reported skipped; 155.3 seconds | One failed outcome is suite setup; not all test bodies in that suite could execute |
| Focused regression probes | **4/4 fail the intended-behavior assertions**, 14.1 seconds | Reproduces R08, R10 (two cases), and R11; these are additional to the baseline suite |
| Measured line coverage | **5,037 / 13,798 lines = 36.5%** in 180 instrumented non-generated `lib` files | Not whole-app coverage; excludes generated code and does not prove uninstrumented paths work |
| Existing integration tests | Inspected but not run; their embedded sample login defaults were replaced only in the isolated checkout with four required `String.fromEnvironment` values | Prevents accidental use without explicit admin/customer test configuration; live execution remains blocked by backend access |
| Android clean release bundle | **Failed** after 705.3 seconds in `:app:processReleaseResources`; `mipmap/ic_launcher` is absent; no AAB produced | Confirms the clean-checkout asset gap is a release blocker, not merely an analyzer warning |
| Supabase management access | Cached CLI 2.106.0 runs and authenticates, but configured project is absent from that account's project list | Original PATH launcher is broken; working executable does not confer access to this project |
| Configured Supabase endpoint | Hostname does not resolve from this machine; `api.supabase.com` resolves | Current backend URL/status needs owner confirmation; this does not prove why the project is unavailable |
| iOS native validation | Not run: no macOS/Xcode access | No archive, signing, APNs, camera, iPhone or iPad runtime approval |

Inventory: **236 non-generated application Dart files**, **54 unit/widget test files**, **2 integration-test files**, and **16 application files over 600 lines**. Complexity alone is not a release blocker. Checkout, admin editing, authentication and home screens received targeted source review.

**Evidence labels used below:**

- **Confirmed defect:** marked **executed** when observed through a command/focused test, or **source-confirmed** when the deterministic condition is demonstrated by source. Source confirmation is not a claim of device or deployed-database reproduction.
- **Suspected risk:** marked **conditional/unverified** where applicability or behavior still depends on configuration, deployed state, or an external workflow.
- **Blocked by access:** stated explicitly for the live Supabase permission matrix, native iOS work, and device/store-account checks that could not be completed.

Priorities: **P0** immediate security containment; **P1** high-priority release blocker; **P2** functional/security defect to fix or explicitly resolve before exposing the affected feature; **P3** maintenance/polish. An inaccessible environment is tracked as blocked verification, not automatically as an application vulnerability.

## 2. Security and backend findings

### R01 — P0 — Privileged credential committed beside an unrestricted configuration policy

**Status/platform:** source-confirmed; both apps/backend; credential validity and deployed grants unverified.  
**Evidence:** [configuration policy and secret location](<D:/desktop/claude resturant/supabase/migrations/20260620_000005_app_config_table.sql:9>), [notification trigger reads configuration](<D:/desktop/claude resturant/supabase/migrations/20260620_000004_improve_notification_trigger_logging.sql:8>).

The tracked migration contains a service-role credential at line 14. Its policy has no `TO` restriction and permits all operations with unconditional predicates. A policy name containing “Service role” does not restrict access. The notification trigger reads the destination URL and privileged header from this table. If client grants exist, clients could read the credential or alter where the trigger sends it. [PostgreSQL policy semantics](https://www.postgresql.org/docs/current/sql-createpolicy.html)

**Verify safely:** inspect effective grants/policies with authorized management access; use synthetic configuration values for negative access tests. Do not retrieve, repeat, or exercise the embedded credential. **Recommended fix:** owner-led rotation/revocation if still active, remove it from source/history, store it in a protected server secret facility, and deny client configuration reads/writes. Removing the visible string alone is insufficient. **Regression:** anonymous and customer identities cannot read or mutate synthetic privileged configuration; notifications still work through the protected server path.

### R02 — P1 — Customer-controlled role assignment and missing admin route denial

**Status/platform:** source-confirmed boundaries; deployed escalation unverified; both apps/backend.  
**Evidence:** [signup trigger](<D:/desktop/claude resturant/supabase/schema.sql:446>), [own-profile update policy](<D:/desktop/claude resturant/supabase/schema.sql:245>), [router guard](<D:/desktop/claude resturant/lib/router/app_router.dart:124>).

Signup metadata determines `profiles.role`; own-profile updates have no protected-column restriction. Later migrations do not close those paths. The router redirects unauthenticated users but does not reject authenticated customers entering `/admin`. Database authorization must remain the real boundary even after adding a route guard.

**Reproduction to run on the test backend:** sign up with admin-role metadata; attempt to update a customer's own role; navigate directly to admin routes. **Expected:** a customer remains a customer and is denied admin operations. **Recommended fix:** assign the customer role server-side, allowlist editable profile columns, use a trusted administrative role-change operation, and add role-aware routing. **Regression:** anonymous/customer A/customer B/admin access matrix, including direct URLs and notifications. Repair R07 together with this finding so removing recursion does not expose an escalation path.

### R03 — P1 — Order RPC accepts caller-supplied ownership, status and financial values

**Status/platform:** source-confirmed; deployed execution privileges unverified; both apps/backend.  
**Evidence:** [definer order function](<D:/desktop/claude resturant/supabase/migrations/20260620_000003_create_order_rpc.sql:4>).

The function inserts the supplied customer ID, order status, totals, discount, delivery fee, product prices and modifier adjustments. It does not bind the customer to `auth.uid()`, require nonempty items, or recompute prices from trusted records. A nonnegative database check still permits a fabricated zero-price order. Granting authenticated execution alone does not revoke default PUBLIC execution. [PostgreSQL function privileges](https://www.postgresql.org/docs/current/sql-createfunction.html)

**Recommended fix:** derive identity/status on the server; validate products, options, address ownership, availability and coupon; calculate the complete amount atomically; restrict execution explicitly and set a safe search path. **Regression:** reject or authoritatively correct forged identity/status/prices/options, empty carts, unavailable products, invalid zones and invalid coupons. These negative API tests were not run against the unavailable endpoint.

### R04 — P1 — A committed order can be reported as failed and duplicated on retry

**Status/platform:** source-confirmed failure path; network reproduction pending; both apps/backend.  
**Evidence:** [order creation followed by a separate read](<D:/desktop/claude resturant/lib/infrastructure/datasources/remote/order_remote_data_source.dart:15>), [order insert](<D:/desktop/claude resturant/supabase/migrations/20260620_000003_create_order_rpc.sql:10>).

After the RPC commits, the client fetches the new order separately. If that read fails, the entire operation becomes a failure and the checkout retains the cart. Retrying inserts another order: no persistent submission key or server uniqueness constraint identifies the original attempt.

**Recommended fix:** keep a customer-scoped submission key across retries; enforce uniqueness and return/recover the same order after uncertain completion. **Regression:** lose the RPC response or fail the follow-up read after commit, retry twice, and assert one order, one item set, and one coupon redemption. A button loading guard alone does not solve this network case.

### R05 — P1 — Coupon consumption is not atomic with order creation

**Status/platform:** source-confirmed; deployed RPC/locking unverified; both apps/backend.  
**Evidence:** [post-order usage increment](<D:/desktop/claude resturant/lib/presentation/screens/checkout/checkout_screen.dart:227>), [client usage validation](<D:/desktop/claude resturant/lib/application/coupon/coupon_cubit.dart:119>).

The client validates usage, commits a discounted order, then calls an independent usage increment and ignores its returned failure. Concurrent customers can pass the same last-use check; a failed increment leaves a discounted order uncounted. The referenced increment RPC is not defined in versioned SQL.

**Recommended fix:** validate/reserve/consume the coupon within the authoritative order transaction and make retries idempotent. **Regression:** two customers compete for the final use; only one succeeds, failed orders consume none, and retries do not consume twice.

### R06 — P1 — Versioned backend artifacts do not reproduce the required schema

**Status/platform:** source-confirmed; no destructive migration was attempted; backend/release engineering.  
**Evidence:** [placeholder baseline](<D:/desktop/claude resturant/supabase/migrations/20260507104146_existing_schema.sql:1>), [forward reference to delivery zones](<D:/desktop/claude resturant/supabase/schema.sql:63>), [payment-status constraint](<D:/desktop/claude resturant/supabase/schema.sql:57>), [app writes `confirmed`](<D:/desktop/claude resturant/lib/infrastructure/datasources/remote/order_remote_data_source.dart:55>).

Four baseline migrations contain comments instead of DDL. Later migrations expect those baseline objects. The alternate schema references `delivery_zones` before creating it; required address/coupon-increment definitions are absent. It also permits payment statuses `pending/paid` while the application writes `confirmed`. The deployed database may differ, which must be measured rather than assumed.

**Recommended fix:** obtain a sanitized authoritative schema, reconcile migrations and ordering, define missing objects and one payment-state contract, and prove fresh provisioning. **Regression:** bootstrap an empty isolated instance, run schema/permission checks and order/payment smoke tests, then repeat an upgrade from the previous supported schema. Do not blindly apply the current scripts to an existing project.

### R07 — P1 — Canonical profile RLS recursively selects from the same protected table

**Status/platform:** source-confirmed policy defect; deployed behavior unverified; backend/authentication.  
**Evidence:** [profile administrator policy](<D:/desktop/claude resturant/supabase/schema.sql:249>).

A policy on `profiles` queries `profiles` to determine administrator status, invoking the same policy again. Applied as written, this can produce recursive-policy errors during profile and dependent authorization queries. Failing every query is not a valid authorization design.

**Recommended fix:** use a narrowly scoped, protected role-check function with a fixed search path and appropriate owner/privileges, while closing R02. **Regression:** customers read only their profile, admins read permitted profiles, and no path produces a recursive-policy error. [Supabase explanation of recursive profile policies](https://supabase.com/docs/guides/troubleshooting/storage-error-database-schema-is-incompatible-when-uploading-files-988baa)

## 3. Customer/admin correctness findings

### R08 — P1 — Product option changes mutate an item already in the cart

**Status/platform:** **executed regression failure** and source-confirmed UI path; both apps.  
**Evidence:** [cart insertion](<D:/desktop/claude resturant/lib/application/cart/cart_cubit.dart:31>), [detail screen passes its mutable list](<D:/desktop/claude resturant/lib/presentation/screens/product/product_detail_screen.dart:487>).

Add a product with an extra, then change the selection while remaining on its detail screen. The cart retains the caller's list rather than a snapshot. The probe expected the original cheese option but found an empty list after the caller cleared it. Prices can silently change and a second variant can merge into the first.

**Recommended fix:** defensively copy option collections at the cart/domain boundary, including bulk-add paths. **Regression:** mutate the caller list after insertion; assert original options/price persist and adding a different variant creates a separate line.

### R09 — P1 — Pickup/dine-in can retain a previous delivery fee and zone

**Status/platform:** source-confirmed; submitted-order reproduction pending; both apps.  
**Evidence:** [address selection stores delivery fee](<D:/desktop/claude resturant/lib/presentation/screens/checkout/checkout_screen.dart:391>), [mode callbacks](<D:/desktop/claude resturant/lib/presentation/screens/checkout/checkout_screen.dart:628>), [submission](<D:/desktop/claude resturant/lib/presentation/screens/checkout/checkout_screen.dart:195>).

Select a delivery address with a fee, then choose pickup or dine-in. The mode changes, but cart fee/zone and selected address ID remain. Submission still sends those fields and the fee-inclusive total. For a 100 EGP basket and 20 EGP delivery fee, pickup remains 120 EGP.

**Recommended fix:** derive both displayed and submitted delivery fields from fulfillment mode; clear/restore selection consistently. **Regression:** delivery→pickup, delivery→dine-in, switch back, coupons, and zero-fee zones; the server must independently enforce the correct fee.

### R10 — P1 — Rejected admin status/payment mutations are presented as successful

**Status/platform:** **two executed regression failures**, plus source-confirmed UI feedback; both apps/admin.  
**Evidence:** [Cubit discards repository results](<D:/desktop/claude resturant/lib/application/admin/admin_orders_cubit.dart:66>), [screen updates local status](<D:/desktop/claude resturant/lib/presentation/screens/admin/admin_order_detail_screen.dart:87>), [payment confirmation](<D:/desktop/claude resturant/lib/presentation/screens/admin/admin_order_detail_screen.dart:125>).

When a repository returns `Left(Failure)`, the Cubit ignores it and starts a reload. The screen changes local state and shows success because no exception is thrown. Both probes returned a server failure followed by a successful reload; the expected failure was replaced by null. This can make staff believe an order or payment was updated when it was not.

**Recommended fix:** expose mutation results/state, fold the `Either`, await required refreshes, and show success only after confirmed persistence. **Regression:** rejected status and payment updates retain the old state, display an error, and never show success even if a subsequent read works.

### R11 — P2 — Removing a coupon or clearing a zone does not clear nullable identifiers

**Status/platform:** **executed coupon regression failure**; zone path source-confirmed; both apps.  
**Evidence:** [coupon removal](<D:/desktop/claude resturant/lib/application/cart/cart_cubit.dart:119>), [null-coalescing copy](<D:/desktop/claude resturant/lib/application/cart/cart_cubit.dart:172>).

The copy method interprets null as “retain old value.” Removing a coupon clears its amount but retains its ID; the probe expected null and received `coupon-a`. Checkout can therefore submit/consume a removed coupon. Zone clearing has the same identifier problem.

**Recommended fix:** distinguish an omitted argument from an explicit clear, or provide complete reset operations. **Regression:** apply→remove yields no coupon ID or usage call; clearing a zone removes ID/name/fee; subsequent cart changes preserve a coherent quote.

### R12 — P1 — Admin notification navigation constructs an invalid order route

**Status/platform:** source-confirmed deterministic cast path; device navigation untested; both apps/admin.  
**Evidence:** [notification navigation without extra](<D:/desktop/claude resturant/lib/presentation/screens/admin/admin_notifications_screen.dart:96>), [unconditional `Order` cast](<D:/desktop/claude resturant/lib/router/app_router.dart:443>).

The notification opens `/admin/orders/:id` without route extras. The builder casts null to `Order`, failing before the screen can load. Ordinary order-list navigation supplies an extra and misses this path. Push navigation also uses a customer destination rather than a role-aware resolver.

**Recommended fix:** resolve the order by path ID with optional initial data and explicit loading/missing/denied states; share role-aware notification routing. **Regression:** in-app notification, background push, direct URL, deleted/inaccessible order, and ordinary list navigation.

### R13 — P2 — Failed address saves dismiss the form as if saving succeeded

**Status/platform:** source-confirmed; both apps/customer.  
**Evidence:** [form save](<D:/desktop/claude resturant/lib/presentation/screens/profile/add_address_screen.dart:158>), [Cubit captures failure instead of throwing](<D:/desktop/claude resturant/lib/application/address/address_cubit.dart:28>).

The screen resolves a factory Cubit, awaits its void method, then pops with success. A repository rejection is stored in that Cubit's state, which the form does not observe; its catch block does not run. The user's form input is lost.

**Recommended fix:** retain/observe the form's Cubit or return a typed result; dismiss only on confirmed success. **Regression:** create/update failures keep the form and entered values visible, show the reason, and permit retry.

### R14 — P1 — Password reset has no complete path in the reviewed application

**Status/platform:** source gap confirmed; an external hosted completion flow is **unverified**; both apps.  
**Evidence:** [reset request](<D:/desktop/claude resturant/lib/presentation/screens/auth/forgot_password_screen.dart:39>), [auth event handling](<D:/desktop/claude resturant/lib/application/auth/auth_cubit.dart:44>), [OTP completion](<D:/desktop/claude resturant/lib/presentation/screens/auth/otp_screen.dart:105>).

The app sends a recovery email but has no new-password form/update call. Recovery events are not handled; the standalone OTP path only offers login. A separately configured hosted reset page could complete the flow, but none was supplied or verified.

**Recommended fix:** verify the configured email destination; if no working hosted flow exists, implement the complete in-app recovery route, password update, native link handling and allowlist. **Regression:** cold/warm app, valid/expired/replayed link, successful password change, old password rejected, and a clear exit from recovery. Sending an email alone is not completion. [Supabase reset-password contract](https://supabase.com/docs/reference/dart/auth-resetpasswordforemail)

### R15 — P2 — Printing dereferences a context that is never initialized

**Status/platform:** source-confirmed; physical printing untested; both apps/admin.  
**Evidence:** [printer picker](<D:/desktop/claude resturant/lib/core/services/thermal_printer_service.dart:17>), [only context assignment](<D:/desktop/claude resturant/lib/core/services/thermal_printer_service.dart:36>).

No call to the service's initialization method exists in `lib`. Once receipt generation succeeds, the picker dereferences null and the operation fails. The direct-print result is also ignored before reporting success.

**Recommended fix:** provide a live presentation-owned picker/context when printing; do not retain a stale context in a service; honor cancellation and the print result. **Regression:** chooser opens, cancel/false/error is not success, and an Arabic receipt prints correctly on the actual target printer. PDF generation alone does not prove thermal printer support.

### R16 — P2 — Custom report ranges exclude most of the selected last day

**Status/platform:** source-confirmed date/query mismatch; live query untested; both apps/admin.  
**Evidence:** [date-range selection](<D:/desktop/claude resturant/lib/presentation/screens/admin/admin_reports_screen.dart:203>), [inclusive timestamp upper bound](<D:/desktop/claude resturant/lib/infrastructure/datasources/remote/report_remote_datasource.dart:24>).

The picker supplies a date-only end value at midnight. The query uses `created_at <= end`, excluding orders later on the selected final day and corrupting KPIs/exports for that range.

**Recommended fix:** convert business-calendar ranges to `[start of first day, start of day after last)` in the business timezone, then query UTC timestamps. **Regression:** single-day range, final-day noon/23:59, next-day boundary, Cairo DST, and matching CSV totals.

### R17 — P2 — CSV sharing lacks the required iPad popover anchor

**Status/platform:** source-confirmed against the installed native plugin; iPad execution untested.  
**Evidence:** [share invocation](<D:/desktop/claude resturant/lib/presentation/screens/admin/admin_reports_screen.dart:71>), [iPad enabled](<D:/desktop/claude resturant/ios/Runner.xcodeproj/project.pbxproj:357>).

The installed `share_plus` 7.2.2 native implementation returns an error for an empty iPad popover origin. The call supplies no origin and does not await/handle its Future.

**Recommended fix:** anchor the share sheet to the export control and handle completion/failure. **Regression:** iPad portrait, landscape and Split View, cancellation, export failure, and normal phone sharing.

### R18 — P2 — Auth sessions persist in ordinary preferences

**Status/platform:** source/resolved-SDK confirmed; device extraction not attempted; both apps/security.  
**Evidence:** [Supabase initialization](<D:/desktop/claude resturant/lib/main.dart:76>).

No custom auth storage is supplied. Resolved `supabase_flutter` 2.12.4 defaults to shared-preferences storage and serializes the entire session, including reusable access/refresh tokens. The secure-storage package used for biometric credentials does not automatically protect Supabase sessions. This is a device-data/backups exposure concern, not proof of remote token theft.

**Recommended fix:** use secure session persistence, migrate/remove old preference entries and verify logout cleanup. **Regression:** login, refresh, restart, upgrade and logout leave no reusable session tokens in ordinary preferences.

## 4. Native build and store-compliance findings

### R19 — P1 — Required images/icons are absent from the versioned checkout

**Status/platform:** executed analyzer and Android release-build failures, plus source-confirmed packaging gap; both stores.  
**Evidence:** [global image ignores](<D:/desktop/claude resturant/.gitignore:15>), [declared asset directories](<D:/desktop/claude resturant/pubspec.yaml:96>), [iOS icon references](<D:/desktop/claude resturant/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json:6>).

The image directories do not exist in a clean checkout. Android launcher images, iOS icon files and the icon-generation input exist locally but are ignored. The clean Android bundle build then failed during resource linking because `mipmap/ic_launcher` was missing, so no AAB was produced. Versioned references without their inputs do not produce a reproducible release.

**Recommended fix:** track required assets or a deterministic generation process with tracked inputs. **Regression:** strict analysis and native builds from a fresh checkout without copying files from a developer machine; inspect every store icon size and launch screen. Do not suppress the analyzer warnings to conceal missing inputs.

### R20 — P1 — Android release builds use debug signing

**Status/platform:** source-confirmed; Google Play.  
**Evidence:** [release signing configuration](<D:/desktop/claude resturant/android/app/build.gradle.kts:39>).

Release selects the debug signing configuration. **Recommended fix:** establish protected upload-key ownership, proper release signing and Play App Signing without committing key material. **Regression:** inspect the final AAB certificate, upload through the approved internal testing process, and verify an installed Play-delivered build. A successful debug-signed local build is not publication readiness.

### R21 — P1 — iOS Firebase configuration is not included in Runner resources

**Status/platform:** source-confirmed configuration defect; iPhone/iPad startup unverified.  
**Evidence:** [native Firebase initialization](<D:/desktop/claude resturant/ios/Runner/AppDelegate.swift:12>), [Runner resources phase](<D:/desktop/claude resturant/ios/Runner.xcodeproj/project.pbxproj:214>).

The app calls default Firebase initialization, but the existing `GoogleService-Info.plist` is not referenced in the resources phase or an alternative copy step. **Recommended fix:** bind the correct environment plist to Runner and verify it is packaged. **Regression:** inspect the built app bundle, cold-launch on a real iPhone and verify Firebase initialization without relying on a developer's untracked Xcode state.

### R22 — P1 — iOS camera/photo usage descriptions are missing

**Status/platform:** source-confirmed; permission/runtime failure not executed; iOS/admin.  
**Evidence:** [camera/gallery calls](<D:/desktop/claude resturant/lib/presentation/widgets/image_picker_sheet.dart:105>), [Info.plist](<D:/desktop/claude resturant/ios/Runner/Info.plist:5>).

The app invokes image picking but only provides a Face ID usage description. Camera access without its required description can terminate the app. **Recommended fix:** provide accurate purpose strings for the actual access paths and handle denial, cancellation and limited-library access. Do not add unused permissions merely because a dependency exists. **Regression:** real iPhone camera/gallery, first-use prompts, denial, limited access and retry.

### R23 — P1 — iOS push capabilities and FCM integration are incomplete

**Status/platform:** source-confirmed configuration concerns; APNs delivery unverified; iOS.  
**Evidence:** [entitlements file](<D:/desktop/claude resturant/ios/Runner/Runner.entitlements:5>), [swizzling disabled](<D:/desktop/claude resturant/ios/Runner/Info.plist:76>).

Runner configurations do not bind `CODE_SIGN_ENTITLEMENTS`. FCM method swizzling is disabled despite current Flutter FCM guidance; manually assigning the APNs token does not establish complete notification handling. [Firebase Flutter setup](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)

**Recommended fix:** bind only justified capabilities and use a supported FCM integration. Verify the distribution archive's entitlements rather than treating the source's development APNs value as the final signing result. **Regression:** permission denied/granted, token refresh, account switching and foreground/background/terminated notification delivery/navigation on a real device.

### R24 — P1 — Locked iOS dependencies lack mandatory SDK privacy manifests

**Status/platform:** resolved-package/source/policy confirmed; final archive unverified; Apple App Store.  
**Evidence:** [locked connectivity package](<D:/desktop/claude resturant/pubspec.lock:275>), [locked sharing package](<D:/desktop/claude resturant/pubspec.lock:1425>).

Installed `connectivity_plus` 5.0.2 and `share_plus` 7.2.2 contain no privacy manifests/resource declarations. Both are on Apple's mandatory SDK list, which applies to their inclusion in new submissions. **Recommended fix:** select compliant compatible versions, review all transitive SDKs and required-reason APIs, and validate the archive's privacy report. Binary SDK signatures have their own applicability rules. **Regression:** archive inspection and App Store validation, plus connectivity/share behavior after the targeted dependency changes. [Apple SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/)

### R25 — P1 — Privacy/terms navigation is nonfunctional

**Status/platform:** source-confirmed; both stores.  
**Evidence:** [settings callbacks](<D:/desktop/claude resturant/lib/presentation/screens/profile/settings_screen.dart:285>), [website footer](<D:/desktop/claude resturant/website/index.html:471>).

Settings privacy and terms actions do nothing; website labels are not links. The existing short legal text does not establish complete declarations matching Supabase, Firebase, Sentry and other data processors.

**Recommended fix:** provide accessible public policies and working in-app navigation, then map actual data collection/retention/sharing to store declarations. **Regression:** open links from a fresh app and logged-out browser; verify support contact, account deletion and SDK disclosures. [Google User Data](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en), [Apple privacy rules](https://developer.apple.com/app-store/review/guidelines/#privacy)

### R26 — P1 — Account deletion is absent from the reviewed app/backend

**Status/platform:** source gap confirmed; any external implementation unverified; both stores.  
**Evidence:** [registration implementation](<D:/desktop/claude resturant/lib/infrastructure/datasources/remote/auth_remote_data_source.dart:7>), [settings](<D:/desktop/claude resturant/lib/presentation/screens/profile/settings_screen.dart:285>), [historical order fields](<D:/desktop/claude resturant/supabase/schema.sql:49>).

No account-deletion UI, repository operation or endpoint was found. Removing an auth user alone would not remove historical names, phone numbers, addresses or review snapshots. Both stores require deletion support for an app with registration; Google also requires an external request resource. Ordinary Apple apps cannot require calling/emailing support to finish deletion. [Google deletion](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en), [Apple deletion](https://developer.apple.com/support/offering-account-deletion-in-your-app/)

**Recommended fix:** design authenticated self-service deletion, session/device-token revocation, storage cleanup and documented retention/anonymization, with an external deletion entry point for Play. **Regression:** customer deletes their own account only; credentials stop working; associated data and retained exceptions match the policy; partial failures can be retried safely.

### R27 — P1 — Public reviews lack report/block/moderation safeguards

**Status/platform:** source gap confirmed; operational moderation unverified; both stores.  
**Evidence:** [comment insertion](<D:/desktop/claude resturant/lib/infrastructure/datasources/remote/rating_remote_data_source.dart:22>), [review display](<D:/desktop/claude resturant/lib/presentation/screens/product/product_reviews_screen.dart:95>).

The app accepts and displays customer names/comments. No reporting, blocking or moderation workflow was found. Limited visibility caused by a query/RLS defect would not constitute moderation. **Recommended fix:** implement the required safeguards and an operational response process, or explicitly exclude public comments from the release until compliant. **Regression:** report abusive content, block a contributor, moderate/remove content, and verify privacy-safe public review queries. [Apple user-generated content](https://developer.apple.com/app-store/review/guidelines/#user-generated-content), [Google UGC policy](https://support.google.com/googleplay/android-developer/answer/9876937?hl=en-GB)

### R28 — P2 — Existing tests and CI do not establish a mobile release baseline

**Status/platform:** executed test failures and source-confirmed CI gap; both stores.  
**Evidence:** [CI workflow](<D:/desktop/claude resturant/.github/workflows/flutter-ci.yml:10>), [test summary](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/test-summary.json>).

CI runs analysis/tests and a web build, with no Android/iOS release gate. The local suite reports 28 failed outcomes; these are not 28 independent product bugs. Failure triage found 23 dependency/fixture failures and 5 outdated UI assertions. None of the test failures was established as an asset-loading error; the asset failure is separately proven by analysis/build evidence. Some assertions remain unexercised until those fixtures are repaired.

**Recommended fix:** repair current fixtures/assertions to reflect real requirements, preserve meaningful assertions, extend existing tests for confirmed defects, and add reproducible Android/iOS build gates. **Regression:** strict checks pass, original cases run rather than being deleted/skipped, all four audit probes turn green after fixes, and native artifacts are validated. Formatting differences are a separate P3 maintenance item.

## 5. Additional triage and coverage gaps

These items are actionable but have narrower evidence or require configuration/device confirmation. They must not be presented as executed end-to-end failures.

| Priority/status | Area and evidence | Required action / regression |
|---|---|---|
| P1 conditional | Email confirmation: [signup waits for a signed-in event](<D:/desktop/claude resturant/lib/application/auth/auth_cubit.dart:110>) | With confirmation enabled, verify an awaiting-confirmation state, resend and successful return; registration must not remain indefinitely loading |
| P1 conditional | Cold-start push handled [before `runApp`](<D:/desktop/claude resturant/lib/main.dart:85>) | Queue navigation until router/auth are ready; test logged-out taps, login continuation and a second order notification while the orders tab remains mounted |
| P2 source-confirmed | Device-global biometric opt-in and [password save on manual login](<D:/desktop/claude resturant/lib/presentation/screens/auth/login_screen.dart:270>) | Test account A opt-in→logout→B login; do not silently save B's credentials under A's consent; clear/reconfirm appropriate settings |
| P2 source-confirmed | [Favorites screen always empty](<D:/desktop/claude resturant/lib/presentation/screens/profile/my_favorites_screen.dart:10>) | Persist actual favorites or remove the advertised feature; add→leave→return→remove must work |
| P2 source-confirmed | [Scheduling toggle](<D:/desktop/claude resturant/lib/presentation/screens/checkout/checkout_screen.dart:794>) can submit null/past time | Require a valid selected future time when scheduling is enabled; separately confirm business lead-time rules |
| P2 conditional | [Public ratings query reads private order items first](<D:/desktop/claude resturant/lib/infrastructure/datasources/remote/rating_remote_data_source.dart:42>) | Verify customer B sees approved product reviews without seeing A's order data; use a safe public projection rather than weakening order RLS |
| P2 verification | Required options, stock/availability, minimum order and closed/busy business | Exercise missing options, stale menu and changed business rules; enforce server-side under R03 |
| P2 verification | Android permissions contributed by unused map dependency | Inspect the fresh merged manifest; justify/remove unnecessary location/storage access and align disclosures |
| P2 verification | Sentry/release logging, alerts and restoration | Supply intended release configuration, verify a non-sensitive test crash and symbolication, test backup/restore in isolation; package presence is not proof monitoring works |
| P3 source-confirmed | [Standalone payment-proof route](<D:/desktop/claude resturant/lib/presentation/screens/checkout/payment_proof_screen.dart:63>) only toggles local upload state | It has no current UI caller; active checkout uses WhatsApp. Remove/exclude the latent route or implement it before exposing it; verify WhatsApp fallback and exact decimal amount |
| P3 executed | 68 formatting differences; domain imports infrastructure/Flutter types | Fix formatting separately; keep architecture cleanup secondary to security/correctness and avoid broad rewrites during release stabilization |
| P3 build warning | Kotlin Gradle Plugin compatibility warning from current Flutter | Plan a tested toolchain/plugin migration; this warning concerns future compatibility and is not alone a proven current build failure |

### Coverage actually achieved

- **Executed:** locked dependency resolution; strict static analysis; non-writing formatting; existing unit/widget suite; four focused no-network regression probes; configured-host DNS control; authenticated CLI project-visibility check.
- **Source reviewed:** authentication and recovery, role boundaries, cart/options/coupons, delivery/pickup/dine-in and payment paths, addresses, customer/admin order updates, notification lifecycle/routes, reports/export/printing, ratings/privacy, native configuration, migration/RLS/function contracts and CI.
- **Not exercised against a live backend:** anonymous/customer A/customer B/admin permissions, storage uploads/access, order lifecycle, simultaneous redemption, auth mail destinations, live realtime reconnects, Edge Function delivery and deletion. The endpoint/access prerequisite is unresolved.
- **Not yet established on devices:** a fresh API 34 emulator booted with a 4 KB page size, but the app could not be installed because the release build failed. The full Android minimum/current/16 KB matrix, iOS builds and iPhone/iPad behavior, real permissions, push, biometrics, WhatsApp handoff, printer output, TalkBack/VoiceOver, large text, dark/light appearance, keyboard/safe-area behavior and screen-by-screen visual quality remain unverified.
- **Performance not approved:** no representative device startup/frame/memory benchmark or live report-query latency was obtained. Do not substitute source inspection, a web screenshot, or emulator startup time for those measurements.

Positive controls observed: order and item insertion share one SQL transaction; several customer reads explicitly filter ownership; the broadcast function checks user/sender/admin identity; push preferences are consulted; multiple streams and report timers have cleanup; checkout checks an order error before clearing the cart; repository interfaces use typed failures. These controls do not cancel the findings above.

## 6. Store-specific release gates

### Google Play

| Gate | Current assessment |
|---|---|
| App identity/version | `com.tarwi2a.app`, `1.0.0+1`; confirm ownership and intended first release |
| SDK baseline | The fresh merged release manifest shows target API 36 and minSdk 24; no final AAB exists to inspect |
| Target API deadline | API 36 required for new apps/updates from **31 August 2026**. [Official requirement](https://developer.android.com/google/play/requirements/target-sdk) |
| 16 KB support | AGP 8.11.1 / NDK 28.2 meet tooling baseline, but final native libraries/alignment/runtime are unverified. Current guide discusses update enforcement from **1 February 2027**; confirm applicability in Console rather than copying an old deadline. [Official guidance](https://developer.android.com/guide/practices/page-sizes) |
| AAB/signing | R19/R20 open; protected upload signing and Play App Signing required. [App bundle guidance](https://support.google.com/googleplay/android-developer/answer/9844279?hl=en) |
| Privacy/deletion/UGC | R25–R27 open; Data safety must match actual SDK/backend behavior. [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en) |
| Account verification/testing | Owner account type/date unknown. Personal accounts created after 13 November 2023 need 12 continuously opted-in testers for 14 days before applying for production access; not a universal organization-account rule. [Testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB) |
| Review/listing | Confirm countries, audience/content rating, screenshots, support contact and stable reviewer credentials/instructions. Do not require reviewers to make a real transfer |

### Apple App Store

| Gate | Current assessment |
|---|---|
| Build SDK | Uploads require Xcode 26+ and iOS/iPadOS 26 SDK+ since **28 April 2026**. Deployment target 13 is a separate compatibility setting. [Apple requirements](https://developer.apple.com/news/upcoming-requirements/) |
| Native archive | Blocked by no Mac access; verify clean plugin integration, Runner resources, signing and capabilities. Missing Podfile alone is not proof of failure because current Flutter may integrate SwiftPM during build |
| Firebase/permissions/push | R21–R23 open; real-device validation required |
| SDK manifests | R24 open; inspect all manifests/required-reason APIs in the resulting archive |
| iPad | Enabled in project; R17 open; include large-screen, rotation and Split View checks |
| Privacy/deletion/UGC | R25–R27 open; App Privacy responses must include third-party processing. [App Privacy](https://developer.apple.com/app-store/app-privacy-details/) |
| Membership/listing/review | Confirm Developer membership, App Store Connect access, signing ownership, current age-rating questions, screenshots and reviewer access; organization enrollment may require D-U-N-S. [Enrollment](https://developer.apple.com/programs/enroll/) |

Physical food orders do not call for store in-app billing. Email/password login alone does not establish a requirement to add Sign in with Apple; reassess if social login is introduced. No unnecessary payment/login replacement is recommended. [Google payments policy](https://support.google.com/googleplay/android-developer/answer/10281818), [Apple review guidelines](https://developer.apple.com/app-store/review/guidelines/)

## 7. Ordered remediation backlog and completion criteria

| Batch | Work | Exit evidence |
|---|---|---|
| 1 — Containment and backend truth | R01; confirm current project URL/access; capture sanitized effective schema/grants/configuration | Owner confirms exposed credential revoked/inactive; correct endpoint works; authoritative export available; no client access to synthetic privileged configuration |
| 2 — Authorization and data contracts | R02, R03, R06, R07; session storage R18 | Anonymous/A/B/admin tests pass; role cannot be self-assigned; server prices/ownership/status are authoritative; fresh and upgrade migrations pass |
| 3 — Order/payment correctness | R04, R05, R08–R11, R13 and scheduling/required-option checks | One order per retry key; atomic coupon use; correct fulfillment totals; immutable cart; real save failures retained; focused probes pass |
| 4 — Account and operational flows | R12, R14–R17; signup/biometric/push/favorites/review visibility | Complete recovery; reliable notification navigation; accurate reports; working exports/printing; documented feature decisions and regression evidence |
| 5 — Native and store blockers | R19–R27 | Reproducible signed AAB and iOS archive; native smoke tests; accessible policies/deletion; compliant public reviews; accurate SDK disclosures |
| 6 — Release verification | R28; format/CI; native device matrix; monitoring/reviewer/store-account checks | All required tests pass without hiding failures; final artifacts validated; unresolved checks are zero or explicitly approved non-blocking scope exclusions |

No public API or schema change was implemented during this review. Future changes needing explicit design/review include the order RPC/submission-key contract, atomic coupon handling, protected role updates, payment-status values, deletion/retention interfaces, ID-based order routing and secure-session migration. Preserve the established BLoC/get_it/domain conventions while implementing those changes.

**Release approval rule:** no open P0/P1, no unresolved mandatory store requirement, passing meaningful regression tests, verified target backend, and platform-native build/device evidence. Finishing the source review is not a store approval. Android and iOS receive separate sign-offs.

**Informational rubric score:** the workflow's deductions (P0 −15, P1 −8, P2 −3, P3 −1, floored at zero and capped at 40 with a P0) yield **0/100** for the listed source/readiness issues. This is not a measured feature-completeness or test-pass percentage; the evidence and gates above are the useful decision criteria.

## 8. Inputs needed and evidence locations

1. **Correct Supabase endpoint and authorized access:** sign in locally to an account that can see the intended project, or provide a sanitized schema/RLS/grants/Auth/Storage/Edge Functions export. The configured project reference is `tfchunxrymewqfbafhnb`. If the project moved, provide its public URL/reference. Do not paste service-role keys, database passwords or store-account passwords.
2. **Test identities:** two customers and one admin through local test configuration once the target backend is confirmed. Replace sample integration-test credentials only in an isolated test harness; avoid real orders, payments, customer messages and unrestricted broadcasts.
3. **Native access:** Mac/macOS runner plus iPhone/iPad; Android minimum/current/16 KB devices or images and a representative physical phone. Real printer testing needs the intended printer.
4. **Owner business/store decisions:** developer-account type/status, signing ownership, countries, support contact, policy/retention approval, reviewer access and permitted release features. No accounts, paid infrastructure or submissions were created.

Evidence is preserved outside the application checkout:

- [Review workspace](<D:/desktop/tarwi2a-readiness-review-20260826-140106>) and [source-baseline checkout](<D:/desktop/tarwi2a-readiness-review-20260826-140106/checkout>).
- [Analyzer log](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/analyze.log>), [format log](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/format.log>), [locked dependency resolution](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/pub-get.log>).
- [Structured test summary](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/test-summary.json>) and [raw test events](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/tests.jsonl>).
- [Four regression probes](<D:/desktop/tarwi2a-readiness-review-20260826-140106/harness/functional_regression_probes_test.dart>), [probe summary](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/regression-probe-summary.json>) and [raw probe events](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/regression-probes.jsonl>).
- [Android clean-build log](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/android-clean-build.log>), [fresh merged release manifest](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/android-merged-release-manifest.xml>) and [device-capability check](<D:/desktop/tarwi2a-readiness-review-20260826-140106/evidence/android-device-capability-check.txt>).

The standard Flutter build migrator added compatibility flags only in the isolated checkout's `android/gradle.properties`. The two isolated integration tests were also changed to require explicit test-only environment values instead of embedded sample logins; they were not run. The original application and its tests were not edited. Required local images were not supplied to the clean-checkout check.
