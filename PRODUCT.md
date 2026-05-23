# Product

## Register

product

## Users

**Primary:** General Arabic restaurant customers — a broad demographic of Arabic-speaking users ordering food from their phones. Context is casual: at home, at work, or on the go.

**Secondary:** Restaurant staff (admin) managing orders, menus, customers, and business operations.

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

## Anti-references

- **Fine dining / white tablecloth**: Not formal, stiff, or pretentious. No serif elegance, no hushed luxury, no minimalist austerity.
- **Corporate SaaS dashboard**: Not cold, not data-heavy for its own sake, not beige-and-blue generic tool.
- **Gamified / cartoonish food apps**: Not childish, not gimmicky, not overanimated.

## Design Principles

1. **Kitchen warmth** — The interface should feel like a welcome, not a transaction. Generous spacing, warm tones, a sense of hospitality.
2. **Menu clarity** — Food is visual. Let photos lead, words support. Decisions should be quick and confident.
3. **Trust at every step** — Order status, pricing breakdowns, and restaurant information are always visible. No hidden costs, no ambiguous states.
4. **Arabic-first** — Designed natively for RTL Arabic speakers. Layouts, type hierarchy, and interaction patterns are built from RTL, not translated from LTR.
5. **No ceremony** — Getting food should be easy. Remove friction from every flow. Ordering is three taps from hungry to confirmed.

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

## Accessibility & Inclusion

Standard WCAG AA target. RTL Arabic is the primary language. Touch targets follow Flutter Material guidelines (minimum 48px). Dark theme supported for low-light ordering. Reduced motion respected via system settings.
