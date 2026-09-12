# Store Data Privacy & Safety Inventory

This document maps all data collected, processed, and transmitted by the Tarwi2a application to the requirements of the Google Play Data Safety form and Apple App Store Privacy Nutrition Labels.

---

## 1. Google Play Data Safety Declarations

### 1.1 Data Collection & Sharing Overview
- **Data Encryption**: All network communications use TLS 1.3 / HTTPS encryption in transit.
- **Account Deletion**: Real self-service account deletion is provided directly in-app (Settings -> Account Deletion) and via external web URL.
- **Data Sharing with Third Parties**: Data is shared ONLY with designated service providers acting as data processors (Supabase backend, Firebase Cloud Messaging, Sentry crash reporting). No data is sold or shared with advertising networks.

### 1.2 Data Types Matrix

| Category | Data Type | Collected | Shared | Purpose | Linked to User |
|---|---|---|---|---|---|
| **Personal Info** | Name | Yes | No | App functionality, Order delivery, Account management | Yes |
| | Email address | Yes | No | Account management, Authentication | Yes |
| | Phone number | Yes | No | App functionality, Order communications, Delivery contact | Yes |
| | Physical address | Yes | No | Order delivery and fulfillment | Yes |
| **Financial Info** | Payment Card Data | No | No | Not collected (App uses Cash, Wallet, and Instapay transfers) | N/A |
| | Transaction Info | Yes | No | Order processing, Receipts, Tax/accounting audit | Yes |
| **Location** | Precise Location | No | No | App does not request continuous GPS location | No |
| | Approximate Location | Yes | No | Delivery zone validation from entered address/polygon | No |
| **Photos and Videos** | Photos | Yes (Optional) | No | Admin menu item photos; Payment proof receipts | Yes |
| **Messages** | Customer Reviews / Notes | Yes | No | Order delivery notes, Feedback | Yes |
| **App Performance & Diagnostics** | Crash logs (Sentry) | Yes | No | Analytics, Bug fixes, App performance | No |
| | Performance metrics | Yes | No | App performance monitoring | No |
| **Device or other IDs** | FCM Device Token | Yes | No | Push notifications for order updates & promotions | Yes |

---

## 2. Apple App Store Privacy Nutrition Labels

### 2.1 Tracking Declarations
- **Tracking**: The app does **NOT** track users across apps and websites owned by other companies (NSPrivacyTracking = false).
- **Third-Party Advertising**: None.

### 2.2 Data Linked to the User
The following data types collected by the app may be linked to the user's identity:
- **Contact Info**: Name, Email Address, Phone Number, Physical Address
- **User Content**: Customer Reviews, Delivery Notes, Payment Proof Uploads
- **Identifiers**: User ID (Supabase Auth UID), Device Token (FCM Token)
- **Purchases**: Purchase History (Order records and transaction amounts)

### 2.3 Data Not Linked to the User
- **Diagnostics**: Crash Data and Performance Data collected via Sentry for application stability and diagnostic analysis.

### 2.4 Apple Required Reason APIs (PrivacyInfo.xcprivacy)
The app declares the following Apple Required Reason APIs:
- NSPrivacyAccessedAPICategoryUserDefaults (Reason: CA92.1 - Local preferences storage via shared_preferences)
- NSPrivacyAccessedAPICategoryFileTimestamp (Reason: C617.1 - App cache and file management via path_provider / image_picker)
- NSPrivacyAccessedAPICategorySystemBootTime (Reason: 35F9.1 - Diagnostic and scheduled notifications via lutter_local_notifications / sentry_flutter)
- NSPrivacyAccessedAPICategoryDiskSpace (Reason: E174.1 - Image cache disk space management via cached_network_image)

---

## 3. Third-Party Service Providers (Data Processors)

1. **Supabase Inc. (Backend / Database / Storage)**:
   - Processes user credentials, profile records, order data, and storage uploads.
   - Server location: Cloud-hosted Postgres with Row-Level Security.
2. **Google Firebase (FCM - Push Notifications)**:
   - Processes registration tokens to route push notifications to devices.
3. **Functional Software, Inc. (Sentry - Crash Reporting)**:
   - Collects stack traces, OS versions, and diagnostic logs on unhandled errors. Redacts personal credentials and PII.

---

## 4. Store Submission Requirements & Owner Action Items

The following assets and organizational details cannot be generated programmatically and are designated as **OWNER_REQUIRED**:

- [ ] **Public Store URLs**:
  - Privacy Policy URL: Deploy official policy to https://tarwi2a.app/privacy-policy (or custom owner domain).
  - Terms of Service URL: Deploy official terms to https://tarwi2a.app/terms-of-service.
  - Support URL: Deploy help/contact page to https://tarwi2a.app/support.
  - Account Deletion Web Request URL: Deploy public web form to https://tarwi2a.app/delete-account (mandatory for Google Play).
- [ ] **Reviewer Demo Credentials**:
  - Test customer account (email + password) with pre-populated order test flow.
  - Test admin account (email + password) to verify admin dashboard and order fulfillment review.
- [ ] **Marketing & Store Assets**:
  - Final screenshots for Google Play (phone, 7-inch, 10-inch tablet).
  - Final screenshots for Apple App Store (6.7-inch iPhone, 6.5-inch iPhone, 12.9-inch iPad).
  - Feature graphic (1024x500 PNG/JPEG) for Google Play.
- [ ] **Legal Business Details**:
  - Official DUNS number and Apple Developer Organization account verification.
  - Google Play verified developer identity and contact details.
  - Age rating questionnaire completion in App Store Connect and Play Console.
