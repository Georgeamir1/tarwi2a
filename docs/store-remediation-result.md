# Store Remediation Final Decision Report — Tarwi2a (ترويئه)

**Date**: 2026-09-08  
**Branch**: `codex/store-release-readiness`  
**Repository**: `D:\desktop\tarwi2a-agy-store-release`  
**Compliance Standard**: `docs/antigravity-gemini-3.8-flash-store-remediation.md`

---

## 1. Implemented and Verified

The following architectural, security, and release-readiness requirements have been fully implemented in source code and verified with local static analysis and automated test suites:

- **Phase 1 — Credential Containment & App Configuration**:
  - Removed embedded `service_role_key` from `app_config` migration and triggers.
  - Dropped overly permissive `authenticated` policy on `app_config`; restricted table access strictly to `postgres` / `service_role`.
  - Created hardened migration `supabase/migrations/20260908_000001_secure_app_config.sql` and test suite `supabase/tests/security_app_config.sql`.
  - Enforced `search_path = public, pg_temp` and fail-closed credential validation in `invoke_send_notification` trigger.
  - Audited full repository; confirmed zero service-role keys in codebase.

- **Phase 2 — Server Authorization: Roles, Profiles, RLS, and Grants**:
  - Closed role escalation vulnerability in `handle_new_user()` (role hardcoded to `customer`).
  - Added non-recursive `is_admin()` security definer function.
  - Implemented `admin_update_user_role(target_user_id, new_role)` restricted to admins.
  - Restricted profile updates via column-level grants (`GRANT UPDATE (name, phone) ON profiles TO authenticated`).
  - Implemented missing `addresses` table schema with strict RLS policies.
  - Hardened RLS across all tables; created 4-role verification matrix in `supabase/tests/auth_rls_matrix.sql`.

- **Phase 3 — Authoritative, Atomic, and Idempotent Order Creation**:
  - Added `request_id` column and unique index on `(customer_id, request_id)` to `orders`.
  - Dropped unsafe client-trusted `create_order_with_items` RPC; deprecated and revoked `increment_coupon_usage` from client roles.
  - Created `create_authoritative_order` RPC: acquires row-level lock (`FOR UPDATE`) on coupon, calculates all item prices and order totals strictly from active database rows, validates user ownership of address, atomically increments coupon usage, and creates order and order items atomically.
  - Stripped Flutter client order payload to choices and identifiers only (`product_id`, `quantity`, `selected_option_ids`, `address_id`, `coupon_id`).
  - Enhanced `CustomerOrdersCubit` to generate UUIDv4 idempotency keys, retain keys on failure for retry, and reset keys only on successful order placement or cart clear.
  - Created regression test suite in `supabase/tests/authoritative_orders.sql` covering 10 test cases.

- **Phase 4 — Real Self-Service Account Deletion**:
  - Created `delete_user_account_data(UUID)` RPC: anonymizes order history (strips customer name, phone, address, notes, proof URL while retaining accounting records), deletes addresses, device tokens, notification preferences, notifications, ratings, and profile. Revoked execution from `PUBLIC`, `anon`, and `authenticated`; granted only to `postgres` and `service_role`.
  - Created `delete-account` Supabase Edge Function: authenticates user via JWT, strictly derives target user ID from authenticated token (rejects request body user ID), executes `delete_user_account_data` RPC, purges user storage objects, and permanently deletes user from `auth.users` via Supabase Admin API.
  - Updated Flutter layer (`AuthRepository`, `AuthRemoteDataSource`, `AuthRepositoryImpl`, `AuthCubit`).
  - Updated `SettingsScreen` with typed destructive confirmation dialog, duplicate-tap prevention, loading indicator, error handling retaining session on failure, and complete local state cleanup (biometrics, cart, session, notifications) on success routing to login.
  - Created unit and widget tests proving failure never displays success and data cleanup executes properly.

- **Phase 5 — Android Release Signing and Artifact Gate**:
  - Removed release-to-debug fallback from `android/app/build.gradle.kts`.
  - Added compile-time validation: release builds fail fast with a descriptive `GradleException` if `key.properties` is missing or any required property (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`) is missing or blank, or the keystore file does not exist.
  - Restricted debug signing exclusively to the debug build type.
  - Updated `.gitignore` and `android/.gitignore` to protect all keystores (`*.jks`, `*.keystore`, `*.p12`), `key.properties`, and `*service-account*.json`.
  - Generated full Android mipmap icons (`mdpi` to `xxxhdpi`) and iOS `AppIcon` PNGs from `assets/icon/app_icon.jpg`.
  - Created `docs/android-release-signing.md`.
  - Verified: `flutter build appbundle --release` fails fast with exit code 1; `flutter build apk --debug` compiles cleanly with exit code 0.

- **Phase 6 — Native Privacy, Notifications, and Store Declarations**:
  - Linked `GoogleService-Info.plist` into the Runner target resources in `project.pbxproj`.
  - Created `Runner-Debug.entitlements` (`aps-environment = development`) and `Runner-Release.entitlements` (`aps-environment = production`); separated build configurations in `project.pbxproj`.
  - Audited `PrivacyInfo.xcprivacy` and permission strings in `Info.plist`.
  - Added real, configurable legal and support URLs to `AppConstants` (`privacyPolicyUrl`, `termsOfServiceUrl`, `supportUrl`, `accountDeletionUrl`).
  - Connected `SettingsScreen` with an About dialog and external browser launching via `url_launcher` for privacy policy, terms, support, and web account deletion.
  - Created comprehensive data inventory in `docs/store-data-privacy-inventory.md`.

- **Phase 7 — Format and Full Regression**:
  - Formatted 345 Dart files with `dart format`; verified `dart format --output=none --set-exit-if-changed` exits 0.
  - Resolved trailing whitespace; verified `git diff --check` exits 0.
  - Verified `flutter analyze --no-pub --fatal-warnings --fatal-infos` exits 0 (zero issues found).
  - Verified `flutter test --no-pub --coverage --reporter=compact` exits 0 (all 455 tests passed).
  - Verified integration tests require explicit environment variables and fail fast without real credentials.

---

## 2. Implemented but Awaiting Deployed / Device Verification

The following items are fully implemented in code but require deployment to a live Supabase environment or target mobile devices:

1. **Supabase Database Migrations**:
   - `supabase/migrations/20260908_000001_secure_app_config.sql`
   - `supabase/migrations/20260908_000002_auth_and_rls_hardening.sql`
   - `supabase/migrations/20260908_000003_authoritative_order_creation.sql`
   - `supabase/migrations/20260908_000004_delete_account_rpc.sql`
   *Status*: Ready for deployment via Supabase CLI or Dashboard. Marked `BLOCKED_BY_ACCESS`.

2. **Supabase SQL Test Suites**:
   - `supabase/tests/security_app_config.sql`
   - `supabase/tests/auth_rls_matrix.sql`
   - `supabase/tests/authoritative_orders.sql`
   - `supabase/tests/delete_account.sql`
   *Status*: Ready for execution against a deployed database. Marked `BLOCKED_BY_ACCESS`.

3. **Supabase Edge Function**:
   - `supabase/functions/delete-account/index.ts`
   *Status*: Ready for deployment via `supabase functions deploy delete-account`. Marked `BLOCKED_BY_ACCESS`.

4. **Integration Test Suite Execution on Real Device / Emulator**:
   - `integration_test/admin_dashboard_flow_test.dart`
   - `integration_test/customer_order_flow_test.dart`
   *Status*: Requires connected mobile device/emulator and live test credentials.

---

## 3. Blocked by Owner Input or Access

| Blocker Item | Type | Impact | Mitigation / Owner Action |
|---|---|---|---|
| Supabase Remote Access | `BLOCKED_BY_ACCESS` | Cannot apply migrations, deploy edge functions, or run live SQL tests | Owner deploys migrations and edge function using Supabase CLI or Dashboard |
| Supabase Service Role Key Rotation | `OWNER_REQUIRED` | Previously committed service key must be invalidated | Rotate service-role key in Supabase Dashboard -> Project Settings -> API |
| Git History Scrubbing | `OWNER_REQUIRED` | Previous commits contain retired service key | Coordinate git-filter-repo or BFG repo purge with team before public release |
| Android Keystore & `key.properties` | `OWNER_REQUIRED` | Cannot produce signed production AAB | Provide release keystore file and configure `android/key.properties` |
| 16 KB Page-Size Native Library Inspection | `OWNER_REQUIRED` | Verification requires signed release bundle | Inspect `.so` ELF alignment using `objdump` / `readelf` after AAB generation |
| macOS / Xcode 26+ Toolchain | `BLOCKED_BY_ACCESS` | Cannot archive iOS build, inspect APNs distribution signing, or verify iPad layout | Run iOS archive and device verification on a macOS build machine |
| Legal Policy Content & Web Hosting | `OWNER_REQUIRED` | App Store and Google Play require public live URLs | Host owner-approved Privacy Policy, Terms of Service, and Account Deletion web page |
| Store Listing Credentials & Metadata | `OWNER_REQUIRED` | Store submission forms require reviewer accounts, age ratings, screenshots | Prepare test accounts and store graphics for submission |

---

## 4. Remaining Defects Ranked P0–P3

### Priority 0 (Blockers for Production Launch)
- **P0-1: Live Database Credentials & Migration Deployment**
  - *Risk*: Database migrations and RLS hardening must be applied to the active database before publishing client changes.
  - *Action*: Apply SQL migrations `20260908_000001` through `20260908_000004` to Supabase; rotate the Supabase service-role key.

### Priority 1 (Release Gate Requirements)
- **P1-1: Production Android Release Signing & AAB Verification**
  - *Risk*: Release build configuration intentionally fails fast without owner keystore.
  - *Action*: Provision `android/key.properties` with release keystore; generate AAB and verify 16 KB page-size alignment.
- **P1-2: Native iOS Archive & Distribution Verification**
  - *Risk*: Windows environment cannot run Xcode archive, native entitlements verification, or iOS device tests.
  - *Action*: Perform archive build on a Mac host and verify push notification entitlement and App Store submission checks.

### Priority 2 (Store Review Requirements)
- **P2-1: Public Hosting of Mandatory Web URLs**
  - *Risk*: Google Play requires an active web URL for account deletion; both stores require a live Privacy Policy URL.
  - *Action*: Deploy official policy, terms, and deletion form to the public web and set corresponding `--dart-define` values.

### Priority 3 (Store Presentation & Metadata)
- **P3-1: App Store & Play Store Assets**
  - *Risk*: Submission cannot be completed without localized screenshots, feature graphics, and completed store questionnaires.
  - *Action*: Owner completes store questionnaires and uploads final screenshot bundles.

---

## 5. Commands and Exact Results

| Phase | Command | Working Directory | Exit Code | Result Summary |
|---|---|---|---|---|
| Phase 0 | `flutter analyze --no-pub --fatal-warnings --fatal-infos` | Workspace root | `0` | Clean baseline: 0 issues found |
| Phase 0 | `flutter test --no-pub --reporter=compact` | Workspace root | `0` | 447 tests passed |
| Phase 3 | `flutter analyze --no-pub --fatal-warnings --fatal-infos` | Workspace root | `0` | 0 issues found |
| Phase 3 | `flutter test --no-pub --reporter=compact` | Workspace root | `0` | 449 tests passed (+2 idempotency tests) |
| Phase 4 | `flutter analyze --no-pub --fatal-warnings --fatal-infos` | Workspace root | `0` | 0 issues found |
| Phase 4 | `flutter test --no-pub --reporter=compact` | Workspace root | `0` | 455 tests passed (+6 account deletion tests) |
| Phase 5 | `flutter build appbundle --release --no-pub` | Workspace root | `1` | Fails fast as designed: `Release signing error: 'key.properties' was not found` |
| Phase 5 | `flutter build apk --debug --no-pub` | Workspace root | `0` | Builds successfully: `build\app\outputs\flutter-apk\app-debug.apk` |
| Phase 6 | `flutter analyze --no-pub --fatal-warnings --fatal-infos` | Workspace root | `0` | 0 issues found |
| Phase 6 | `flutter test --no-pub --reporter=compact` | Workspace root | `0` | 455 tests passed |
| Phase 7 | `dart format lib test integration_test` | Workspace root | `0` | Formatted 345 files (58 modified, 0 remaining) |
| Phase 7 | `dart format --output=none --set-exit-if-changed lib test integration_test` | Workspace root | `0` | Code formatting 100% compliant |
| Phase 7 | `git diff --check` | Workspace root | `0` | Zero trailing whitespace or conflict markers |
| Phase 7 | `flutter analyze --no-pub --fatal-warnings --fatal-infos` | Workspace root | `0` | No issues found (strict analyzer) |
| Phase 7 | `flutter test --no-pub --coverage --reporter=compact` | Workspace root | `0` | All 455 tests passed, coverage collected |

---

## 6. Files Changed

### Backend & Migrations
- `supabase/migrations/20260908_000001_secure_app_config.sql`: Purged service-role key; secured app_config table & notification triggers.
- `supabase/migrations/20260908_000002_auth_and_rls_hardening.sql`: Role escalation fix, non-recursive `is_admin()`, profile column grants, addresses schema & policies.
- `supabase/migrations/20260908_000003_authoritative_order_creation.sql`: `create_authoritative_order` RPC, request_id idempotency, coupon locking.
- `supabase/migrations/20260908_000004_delete_account_rpc.sql`: `delete_user_account_data` RPC for PII anonymization and record deletion.
- `supabase/schema.sql`: Synchronized cumulative schema reflecting all migrations and clean syntax.
- `supabase/functions/delete-account/index.ts`: Edge function for secure authenticated account deletion.
- `supabase/tests/security_app_config.sql`: SQL test suite for app_config access control.
- `supabase/tests/auth_rls_matrix.sql`: SQL test suite for 4-role access matrix and addresses RLS.
- `supabase/tests/authoritative_orders.sql`: SQL test suite for authoritative order calculation and coupon locking.
- `supabase/tests/delete_account.sql`: SQL test suite for account deletion and data anonymization.

### Flutter Domain, Infrastructure, Application & UI
- `lib/core/constants/app_constants.dart`: Added legal and support URL constants.
- `lib/domain/repositories/auth_repository.dart`: Added `deleteAccount()` interface.
- `lib/domain/repositories/order_repository.dart`: Updated `createOrder()` interface to accept pure choices and `requestId`.
- `lib/infrastructure/datasources/remote/auth_remote_data_source.dart`: Added Edge Function invocation for account deletion.
- `lib/infrastructure/datasources/remote/order_remote_data_source.dart`: Switched to `create_authoritative_order` RPC.
- `lib/infrastructure/repositories/auth_repository_impl.dart`: Implemented `deleteAccount()` with local session cleanup.
- `lib/infrastructure/repositories/order_repository_impl.dart`: Implemented authoritative order creation and DTO mappings.
- `lib/application/auth/auth_cubit.dart`: Implemented `deleteAccount()` with unauthenticated state transition.
- `lib/application/orders/customer_orders_cubit.dart`: Idempotency key lifecycle management (`_activeRequestId`).
- `lib/presentation/screens/checkout/checkout_screen.dart`: Stripped client pricing calculations from order placement payload.
- `lib/presentation/screens/profile/settings_screen.dart`: Real destructive account deletion confirmation dialog, URL opening via `url_launcher`, About dialog.

### Android & iOS Configuration
- `android/app/build.gradle.kts`: Removed release-to-debug signing fallback; added strict compile-time signing validation.
- `android/.gitignore`: Ignored keystores, key.properties, and service account JSON files.
- `.gitignore`: Hardened secret ignoring and whitelisted Android/iOS launcher icon PNGs.
- `android/app/src/main/res/mipmap-*/ic_launcher.png`: Generated full Android mipmap icon set.
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`: Generated full iOS AppIcon set.
- `ios/Runner.xcodeproj/project.pbxproj`: Linked `GoogleService-Info.plist` into Runner target; separated debug and release entitlements.
- `ios/Runner/Runner-Debug.entitlements`: Development APNs configuration.
- `ios/Runner/Runner-Release.entitlements`: Production APNs configuration.
- `ios/Runner/Runner.entitlements`: Hardened default to production.

### Tests & Documentation
- `test/infrastructure/repositories/auth_repository_impl_test.dart`: Unit tests for account deletion repository flow.
- `test/infrastructure/repositories/order_repository_impl_test.dart`: Unit tests for authoritative order creation.
- `test/application/auth/auth_cubit_test.dart`: Unit tests for account deletion Cubit flow.
- `test/application/orders/customer_orders_cubit_test.dart`: Unit tests for idempotency key retention and resets.
- `test/presentation/screens/profile/settings_screen_test.dart`: Widget tests for account deletion dialog, Cubit invocation, and failure handling.
- `test/presentation/screens/checkout/checkout_screen_test.dart`: Updated checkout widget tests.
- `docs/android-release-signing.md`: Android release signing runbook and 16 KB inspection guide.
- `docs/store-data-privacy-inventory.md`: Google Play Data Safety and Apple Privacy Nutrition mapping.
- `docs/antigravity-gemini-3.8-flash-store-remediation.md`: Updated checklists and execution logs across all phases.

---

## 7. Google Play Verdict

### **NOT READY**

**Rationale**:
Per the remediation standard, a passing automated test suite cannot produce a `READY` verdict while external dependencies and release gates remain pending:
1. **Signing & Artifacts**: The production release keystore has not yet been provisioned by the owner. Consequently, a production AAB could not be compiled or inspected for 16 KB page-size compliance.
2. **Backend Migrations**: Database migrations `20260908_000001` through `20260908_000004` and the `delete-account` edge function have not been deployed to the live Supabase project.
3. **Public Deletion URL**: Google Play requires a publicly accessible web deletion URL (separate from the in-app flow) before submission.
4. **Store Console Metadata**: Data Safety form, screenshots, age rating questionnaire, and developer identity verification must be completed in the Google Play Console by the owner.

---

## 8. Apple App Store Verdict

### **NOT READY**

**Rationale**:
Per the remediation standard, Apple must remain `NOT READY` until a real archive and native device checks pass on a macOS/Xcode toolchain:
1. **Environment Constraint**: Current execution environment is Windows. Native Xcode archive compilation, App Store Connect distribution export, and APNs certificate pairing are marked `BLOCKED_BY_ACCESS — native iOS archive/device verification`.
2. **Backend Migrations**: Deployed Supabase instance must have the authoritative order and account deletion RPCs active.
3. **App Store Connect Metadata**: Privacy nutrition questionnaire, App Store review demo credentials, and localized screenshot sets must be submitted by the owner.

---

## 9. Owner Action Checklist

This prioritized checklist outlines the specific actions George must complete to finalize store releases:

### Step 1: Database & Backend Deployment (Immediate)
- [ ] Log in to the Supabase Dashboard for project `tfchunxrymewqfbafhnb`.
- [ ] In SQL Editor, execute the following migration files in order:
  1. `supabase/migrations/20260908_000001_secure_app_config.sql`
  2. `supabase/migrations/20260908_000002_auth_and_rls_hardening.sql`
  3. `supabase/migrations/20260908_000003_authoritative_order_creation.sql`
  4. `supabase/migrations/20260908_000004_delete_account_rpc.sql`
- [ ] Run the SQL test suites in `supabase/tests/` to verify RLS policies and authoritative RPC behavior.
- [ ] Deploy the account deletion Edge Function using the Supabase CLI:
  ```bash
  supabase functions deploy delete-account
  ```
- [ ] In **Project Settings -> API**, rotate the Supabase `service_role` key. Ensure the new service key is stored only in Supabase Edge Function secrets and never checked into Git.

### Step 2: Android Production Release Signing
- [ ] Copy `android/key.properties.example` to `android/key.properties`.
- [ ] Populate `android/key.properties` with production keystore path and passwords (see `docs/android-release-signing.md`).
- [ ] Build the release App Bundle:
  ```bash
  flutter build appbundle --release --no-pub --obfuscate --split-debug-info=./symbols
  ```
- [ ] Inspect the generated AAB native libraries for 16 KB page-size compliance following the instructions in `docs/android-release-signing.md`.

### Step 3: iOS Archive & macOS Verification
- [ ] On a Mac running macOS with Xcode 15/16+:
  - Clone or pull branch `codex/store-release-readiness`.
  - Open `ios/Runner.xcworkspace`.
  - Select target `Runner`, configure Apple Developer Team signing.
  - Verify `GoogleService-Info.plist` is present in Runner Resources.
  - Create an Archive (`Product -> Archive`) and validate the archive for App Store distribution.
  - Verify push notification entitlement uses `production` environment in the release export.

### Step 4: Web Hosting for Legal & Deletion URLs
- [ ] Publish the Privacy Policy at `https://tarwi2a.app/privacy-policy` (refer to `docs/store-data-privacy-inventory.md`).
- [ ] Publish Terms of Service at `https://tarwi2a.app/terms-of-service`.
- [ ] Publish Support / Help page at `https://tarwi2a.app/support`.
- [ ] Publish the Account Deletion Request web form at `https://tarwi2a.app/delete-account` (required for Google Play Data Safety compliance).

### Step 5: Store Submissions
- [ ] Complete the Google Play Data Safety form using the exact field mapping provided in `docs/store-data-privacy-inventory.md`.
- [ ] Complete the Apple App Store Privacy Nutrition Labels using `docs/store-data-privacy-inventory.md`.
- [ ] Provide App Review test credentials:
  - Customer account: email + password with sample addresses.
  - Admin account: email + password for restaurant order management review.
- [ ] Upload screenshots and promotional graphics to Google Play Console and App Store Connect.\n