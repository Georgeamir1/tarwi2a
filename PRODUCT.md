# Product

## Register

product

## Users

**Primary:** General Arabic restaurant customers — a broad demographic of Arabic-speaking users ordering food from their phones. Context is casual: at home, at work, or on the go. Many are first-time mobile app users who value familiarity over novelty.

**Secondary:** Restaurant staff (admin) managing orders, menus, customers, and business operations. Working in fast-paced kitchen environments, often on tablets in less-than-ideal lighting.

## Product Purpose

Tarwika (طرويقة) connects Arabic restaurant customers to their favorite local spots. Customers browse menus, build a cart, place orders, and track delivery. Restaurant admins manage incoming orders, update menus, track inventory, and grow their business through data-driven decisions.

Success is measured in:
- Completed orders per day
- Returning customers who trust the platform
- Average order value growth
- Order fulfillment speed (kitchen → delivery)
- Customer satisfaction (ratings)

## Brand Personality

**Warm, inviting, dependable.** Like walking into your neighborhood restaurant where they know your name — familiar, generous, and trustworthy. The app should feel like a welcome, not a formality. Arabic hospitality translated into pixels: generous spacing, warm tones, clear communication.

Three words: generous, grounded, appetizing.

## Anti-references

- **Fine dining / white tablecloth**: Not formal, stiff, or pretentious. No serif elegance, no hushed luxury, no minimalist austerity.
- **Corporate SaaS dashboard**: Not cold, not data-heavy for its own sake, not beige-and-blue generic tool.
- **Gamified / cartoonish food apps**: Not childish, not gimmicky, not overanimated.
- **AI-generated food delivery apps**: No purple gradients, no generic food icons, no cookie-cutter onboarding templates.

## Design Principles

1. **Kitchen warmth** — The interface should feel like a welcome, not a transaction. Generous spacing, warm tones, a sense of hospitality.
2. **Menu clarity** — Food is visual. Let photos lead, words support. Decisions should be quick and confident.
3. **Trust at every step** — Order status, pricing breakdowns, and restaurant information are always visible. No hidden costs, no ambiguous states.
4. **Arabic-first** — Designed natively for RTL Arabic speakers. Layouts, type hierarchy, and interaction patterns are built from RTL, not translated from LTR.
5. **No ceremony** — Getting food should be easy. Remove friction from every flow. Ordering is three taps from hungry to confirmed.
6. **Cinematic consistency** — The entire app speaks one visual language: dark, rich, warm. From splash to checkout to admin dashboard, the same depth and atmosphere carries through. No jarring light-to-dark transitions mid-flow. The dark shell is the constant; light surfaces are reserved for content cards that need contrast for readability (food photos, menu items, order details).

## Admin Panel Product Scope

### V1 — Completed
- Order management (view, search, filter, status update, cancel)
- Menu CRUD (products, categories)
- Basic dashboard (3 KPI cards, quick actions, recent orders)
- Admin authentication

### V2 — In Progress (Admin Enhancement)
- **Coupon Management** — Create/edit coupon codes (percentage/fixed), set usage limits, minimum order, expiry dates. Track usage statistics.
- **Customer Management** — View all customers, search, filter, view order history, total spending. Customer detail with activity log.
- **Delivery Zones** — Define delivery areas with fees, minimum order, estimated time. Toggle zones on/off.
- **Business Profile** — Edit restaurant info (name, phone, address, logo, opening hours, minimum order, default prep time). Busy mode toggle.
- **Real-time Reports** — Revenue charts with date filters (today/7d/30d/90d/custom), top products, order volume, average order value. Export to CSV/PDF.
- **Modifiers/Options** — Product customization (sizes, extras, variants, removals) with price deltas.
- **Thermal Printer** — Print orders via Bluetooth thermal printer with formatted receipt.
- **Real-time Alerts** — Sound + vibration on new orders. In-app notification badge.

### V3 — Future
- **Kitchen Display System (KDS)** — Dedicated kitchen screen with order timer, station assignment, bump system.
- **Driver Management** — Assign drivers to orders, track deliveries, driver earnings.
- **Loyalty Program** — Points system, rewards, customer tiers.
- **Push Notification Campaigns** — Targeted push notifications to customers.
- **Audit Log** — Track all admin actions (who did what and when).
- **Roles & Permissions** — Granular admin roles (manager, cashier, kitchen).
- **Multi-branch** — Support multiple restaurant locations.
- **A/B Testing** — Test banners, promotions.

## First-Run Experience

The app uses a three-stage first-run flow that establishes the cinematic dark theme immediately:

1. **Splash screen** (3.2s): Cinematic dark theme. Animated radial gradient background, floating particle system, rotating decorative arcs, pulsating glow halo, circular progress ring. Logo enters with spring physics (elasticOut). Tagline "أكلات أصيلة، طعم لا ينسى" fades + slides in. Entire screen fades out at 88-100%. Purpose: emotional anchoring, brand impression, auth check in parallel.

2. **Onboarding** (3 pages, swipe navigation): Full-bleed photography with parallax. Dark glassmorphism bottom card with BackdropFilter blur. Each page has a themed gradient (warm red, forest, deep blue), an icon tag badge, bold title with accent-highlighted word, and descriptive body text. First page shows animated swipe chevron (RTL direction). Last page pulses the CTA with a glow animation. Skip button uses frosted glass treatment. Content transitions with fade + slide (450ms).

3. **Login/Register**: Continued dark cinematic theme with warm rose content cards. Hero image header (48% screen height) with gradient fade. Glassmorphism form card with BackdropFilter blur. Staggered field entrance animations (9 intervals over 1100ms). Animated focus states (border color, shadow, icon scale). Shake animation on validation errors. Shimmer loading on CTA button. Ambient breathing background blobs. Gradient CTA buttons with box shadow glow. Register uses a 4-step progress indicator with animated connecting lines.

## Visual Theme: Unified Dark Cinematic

The entire app uses a dark cinematic theme. No separate light mode. The dark shell is constant; light surfaces appear only as elevated content cards where contrast is needed for readability (food photos, menu items, text-heavy data).

**Scene sentence:** An Arabic-speaking customer glances at their phone at 10pm after a long day, or an admin checks incoming orders on a tablet in a dim kitchen. The dark theme reduces eye strain, makes food photography pop against the background, and creates a premium dining atmosphere that matches the late-night ordering context.

**Why unified dark, not dual light/dark:**
- Food photography is more appetizing against dark surfaces (contrast makes colors vivid).
- Kitchen admins work in variable lighting, often dim. Dark surfaces reduce glare.
- The splash/onboarding already establishes the dark cinematic language. Switching to light mid-flow would break the emotional continuity.
- A single theme halves the design system surface area and eliminates light/dark consistency bugs.

## Accessibility & Inclusion

WCAG AA target on dark backgrounds. All text meets 4.5:1 contrast ratio against the dark shell. RTL Arabic is the primary language. Touch targets follow Flutter Material guidelines (minimum 44px, enforced in all interactive elements). Reduced motion respected via system settings. Minimum contrast ratios maintained across all status badges and interactive states. Light content cards maintain their own contrast ratios against the dark shell.