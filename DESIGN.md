---
name: Levantine Clarity — Dark Cinematic
description: Dark cinematic Arabic food ordering app with warm Middle Eastern aesthetic and deep atmospheric surfaces
colors:
  # Primary - Cherry Red (Action & appetite)
  primary: "#e02b2b"
  on-primary: "#ffffff"
  primary-container: "#ffe3e3"
  on-primary-container: "#8b1e1e"
  primary-fixed: "#ffdad6"
  primary-fixed-dim: "#ffb4ab"
  on-primary-fixed: "#410002"
  on-primary-fixed-variant: "#93000a"
  inverse-primary: "#ffb4ab"
  
  # Secondary - Warm Cocoa (Structure & balance)
  secondary: "#5c4e4d"
  on-secondary: "#ffffff"
  secondary-container: "#f0e3e2"
  on-secondary-container: "#2c2120"
  secondary-fixed: "#f0e3e2"
  secondary-fixed-dim: "#d3c2c0"
  on-secondary-fixed: "#1a1110"
  on-secondary-fixed-variant: "#3f3332"
  
  # Tertiary - Amber Gold (Warmth, accent & hospitality)
  tertiary: "#C68B59"
  on-tertiary: "#ffffff"
  tertiary-container: "#FCECDD"
  on-tertiary-container: "#513116"
  tertiary-fixed: "#FCECDD"
  tertiary-fixed-dim: "#DFB897"
  on-tertiary-fixed: "#271300"
  on-tertiary-variant: "#452409"
  
  # Error
  error: "#ba1a1a"
  on-error: "#ffffff"
  error-container: "#ffdad6"
  on-error-container: "#93000a"
  
  # Dark Shell Surfaces (Primary theme for ALL screens)
  shell: "#1F1615"
  shell-elevated: "#2C2120"
  shell-high: "#382B2A"
  shell-surface: "#453837"
  shell-overlay: "#504140"
  
  # Content Cards (Light elevated surfaces for readability)
  card: "#FFFFFF"
  card-dim: "#FCF5F4"
  card-mid: "#F6ECEB"
  on-card: "#2C2120"
  on-card-secondary: "#7A6B69"
  
  # Dark theme text
  text-primary: "#F5E0DF"
  text-secondary: "#C7B4B2"
  text-muted: "#8C7B79"
  
  # Legacy warm-rose aliases (used in light content cards on dark shell)
  background-legacy: "#fdf8f7"
  surface-legacy: "#ffffff"
  
  # Status Colors
  status-pending: "#E89820"
  status-confirmed: "#3B82C4"
  status-preparing: "#8B5CF6"
  status-ready: "#2D8C5E"
  status-delivered: "#22C55E"
  status-cancelled: "#D14334"
  
  # Outlines (dark context)
  outline: "#504140"
  outline-variant: "#3D3230"

typography:
  large-title:
    fontFamily: Cairo
    fontSize: 34px
    fontWeight: '700'
    lineHeight: 41px
    letterSpacing: 0.37px
  headline:
    fontFamily: Cairo
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: -0.41px
  body:
    fontFamily: Cairo
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: -0.41px
  callout:
    fontFamily: Cairo
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 21px
    letterSpacing: -0.32px
  subheadline:
    fontFamily: Cairo
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: -0.24px
  footnote:
    fontFamily: Cairo
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: -0.08px
  caption:
    fontFamily: Cairo
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0px

rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  xxl: 2rem
  full: 9999px

spacing:
  unit: 8px
  margin-mobile: 16px
  gutter: 12px
  stack-sm: 4px
  stack-md: 8px
  stack-lg: 16px
  section-padding: 24px
---

# Design System: Levantine Clarity — Dark Cinematic

## 1. Overview

**Creative North Star: "Cinematic Arabic Hospitality"**

Tarwika is a dark cinematic experience from the first splash to the last admin screen. The entire app lives within a deep, warm dark shell — no light mode, no mid-flow theme switches. The background is always dark; content that needs contrast for readability lives in elevated light cards that float on the dark surface.

The system uses a **Committed + Drenched** color strategy. Cherry Red and Amber Gold carry significant surface area, not just accent touches. The dark shell makes food photography explode with color, creates a premium lounge atmosphere, and reduces eye strain for late-night ordering and kitchen environments.

**Why dark cinematic, everywhere:**
- Food photography is more appetizing against dark surfaces (warm colors pop, whites glow).
- Kitchen admins work in variable, often dim lighting. Dark surfaces reduce glare.
- The splash and onboarding already establish this language. Consistency is trust.
- One theme halves the design system surface area and eliminates light/dark bugs.

**Key Characteristics:**
- Dark warm shell on every screen, every context
- Three-color harmony: cherry red (action), warm cocoa (structure), amber gold (accent)
- Light content cards float on dark surfaces for readability where needed
- Cairo font for Arabic-optimized typography (Inter supplementary for Latin text)
- RTL-native layouts with generous whitespace
- Glassmorphism and backdrop blur used purposefully throughout
- Ambient motion adds life without distraction
- Cinematic depth gradients, particle effects, and glow animations across the full experience
- iOS-style bottom navigation with blur backdrop

## 2. Colors

### Dark Shell Palette (Primary Theme)

The shell is the constant background on every screen. Five tonal levels create depth through subtle warmth shifts, never cold neutrals.

- **Shell** (`#1F1615`): Base background. Deep warm charcoal with red-brown undertone. The ground everything sits on.
- **Shell Elevated** (`#2C2120`): Default surface for cards, sheets, list items. One step up from the void.
- **Shell High** (`#382B2A`): Pressed states, selected items, hovered surfaces. Noticeably warmer.
- **Shell Surface** (`#453837`): Dividers, borders, subtle separators. Visible but recessed.
- **Shell Overlay** (`#504140`): Disabled states, placeholder text, inactive elements. The faintest mark on the surface.

### Content Card Palette (Light Surfaces on Dark)

Light surfaces are reserved for content that demands contrast: food photos, menu item details, order summaries, data tables. They float above the dark shell like lighted alcoves.

- **Card** (`#FFFFFF`): Primary card background. Clean white for high-contrast content.
- **Card Dim** (`#FCF5F4`): Grouped content within cards, input field backgrounds at rest.
- **Card Mid** (`#F6ECEB`): Subtle elevation within cards, selected rows, active segments.
- **On Card** (`#2C2120`): Primary text on light card backgrounds.
- **On Card Secondary** (`#7A6B69`): Secondary text on light card backgrounds.

### Primary Accent (Cherry Red — Action & Appetite)
- **Primary** (`#E02B2B`): Main action buttons, hero highlights, selected states, focus rings, glow effects. The appetite stimulator. Carries significant surface area in the UI.
- **Primary Container** (`#FFE3E3`): Active chip fills, highlights within light cards.
- **On Primary** (`#FFFFFF`): Text on primary-colored backgrounds.
- **On Primary Container** (`#8B1E1E`): Text on primary container backgrounds.

### Secondary Accent (Warm Cocoa — Structure & Balance)
- **Secondary** (`#5C4E4D`): Structural borders on dark, secondary text emphasis, muted actions.
- **Secondary Container** (`#F0E3E2`): Selected category backgrounds within light cards.
- **On Secondary** (`#FFFFFF`): Text on secondary backgrounds.

### Tertiary Accent (Amber Gold — Warmth & Hospitality)
- **Tertiary** (`#C68B59`): Warmth accents, hospitality icons, specialty badges, informational highlights, rating stars, pricing, biometric button borders, ambient blobs in auth screens.
- **Tertiary Container** (`#FCECDD`): Info highlights within light cards, warm badge backdrops.
- **On Tertiary** (`#FFFFFF`): Text on tertiary backgrounds.
- **On Tertiary Container** (`#513116`): Text on tertiary container backgrounds.

### Text on Dark Surfaces
- **Text Primary** (`#F5E0DF`): Primary text on dark shell. Warm white with rose undertone. Not pure white.
- **Text Secondary** (`#C7B4B2`): Secondary text, descriptions, metadata on dark shell.
- **Text Muted** (`#8C7B79`): Placeholder text, disabled text, inactive icons on dark shell.

### Outlines (Dark Context)
- **Outline** (`#504140`): Borders, active dividers on dark shell.
- **Outline Variant** (`#3D3230`): Subtle dividers, separator lines on dark shell.

### Status Colors (Used on both dark and light surfaces)
- **Pending:** Grain amber (`#E89820`)
- **Confirmed:** Denim blue (`#3B82C4`)
- **Preparing:** Eggplant (`#8B5CF6`)
- **Ready:** Herb green (`#2D8C5E`)
- **Delivered:** Spring leaf (`#22C55E`)
- **Cancelled:** Clay red (`#D14334`)

### Color Restrictions
- Never use pure black (`#000000`) or pure white (`#FFFFFF`) as background fills. The shell is `#1F1615`, not black. Cards are `#FFFFFF` for content only.
- Cherry Red is for actions, active states, and glow effects. Permitted at 20-30% surface area (Committed strategy).
- Amber Gold signals warmth and hospitality. Permitted at 10-15% surface area as secondary accent.
- Status colors are semantically locked. Never reuse a status color for decoration.
- Light card surfaces are always contained within the dark shell. Never use a full light background.

## 3. Typography

**Primary Font:** Cairo (Google Fonts) — Arabic-optimized with excellent weight distribution and readability.
**Latin Font (supplementary):** Inter (Google Fonts) — for mixed-language contexts (email, phone, prices in LTR).

### Hierarchy
- **Large Title** (w700, 34px, 41px lh): Screen titles, hero headlines. Used sparingly.
- **Headline** (w600, 17px, 22px lh, -0.41px ls): Card titles, section headers, button labels.
- **Body** (w400, 17px, 22px lh, -0.41px ls): Primary reading text. Most common style.
- **Callout** (w400, 16px, 21px lh, -0.32px ls): Emphasized body text, form labels.
- **Subheadline** (w400, 15px, 20px lh, -0.24px ls): Secondary labels, metadata.
- **Footnote** (w400, 13px, 18px lh, -0.08px ls): Tertiary info, timestamps, helper text.
- **Caption** (w400, 12px, 16px lh, 0px ls): Badges, small labels, price modifiers.

### Named Rules
- **Arabic line height boost:** Increase line-height by 10-15% for Arabic text to accommodate taller diacritics.
- **Weight contrast:** Minimum 200 weight difference between hierarchical levels (e.g., 400 vs 600).
- **RTL-first:** All text alignment starts from the right. Numeric values (prices) align right in Arabic contexts.
- **LTR fields:** Email, phone, and password fields use `TextDirection.ltr` regardless of app locale.
- **Dark surface text:** Always use warm-tinted white (`#F5E0DF`) for primary text on dark backgrounds. Pure white creates glare.

## 4. Spacing

**Grid:** 8px soft grid with 4px micro-adjustments

| Token | Value | Usage |
|-------|-------|-------|
| Stack SM | 4px | Tight internal gaps (icon + label, inline elements) |
| Stack MD | 8px | Standard element spacing (button padding, row gaps) |
| Stack LG | 16px | Section internal padding, card padding |
| Gutter | 12px | Grid gaps between cards |
| Margin Mobile | 16px | Screen edge margins |
| Section Padding | 24px | Major section vertical spacing |
| Unit | 8px | Base grid unit |

## 5. Shape

| Component | Radius | Usage |
|-----------|--------|-------|
| Small (SM) | 4px | Small buttons, inline tags, checkboxes |
| Default | 8px | Input fields, small cards, chips |
| Medium (MD) | 12px | Standard cards, modals, buttons |
| Large (LG) | 16px | Large cards, bottom sheets, image containers |
| Extra Large (XL) | 24px | Hero banners, featured content, CTA buttons |
| Extra Extra Large (XXL) | 24px | Glassmorphism cards, form containers, onboarding bottom sheet |
| Full | 9999px | Pills, avatars, FABs, search bars, CTA buttons |

## 6. Elevation & Shadows

On dark surfaces, elevation is communicated through **lighter tonal layers** (shell → shell-elevated → shell-high) and strategic glow shadows, not traditional drop shadows. On light content cards, standard shadow elevations apply.

### Dark Shell Elevation (Primary)
| Level | Treatment | Usage |
|-------|-----------|-------|
| **Level 0 (Void)** | Shell background, no treatment | Screen backgrounds, behind everything |
| **Level 1 (Surface)** | `shell-elevated` fill | Cards, list items, form containers, bottom nav |
| **Level 2 (Raised)** | `shell-high` fill + `0 2px 8px rgba(0,0,0,0.3)` | Elevated cards, hover states, active selections |
| **Level 3 (Floating)** | `shell-overlay` fill + `0 8px 32px rgba(0,0,0,0.4)` + blur | Modals, bottom sheets, FABs |
| **Level 4 (Glow)** | Light card fill (`card`) + primary glow shadow | Light content cards floating on dark |

### Light Card Elevation (Within Dark Shell)
| Level | Treatment | Usage |
|-------|-----------|-------|
| **Card Base** | `card` fill, `0 2px 12px rgba(0,0,0,0.15)` | Menu item cards, order cards, admin data cards |
| **Card Hover** | `card` fill, `0 4px 16px rgba(0,0,0,0.2)` | Hovered menu items, pressed states |
| **Card Elevated** | `card` fill, `0 8px 32px rgba(0,0,0,0.25)` | Bottom sheets, dialogs, popovers |

### Primary Glow Shadow
Used on primary CTA buttons and key interactive elements on dark surfaces:
- **Standard:** `0 8px 18px rgba(224,43,43,0.4)` — default button shadow
- **Amplified:** `0 8px 28px rgba(224,43,43,0.6)` — pulse/glow states, onboarding CTA
- **Subtle:** `0 4px 12px rgba(224,43,43,0.2)` — input focus glow

### Tertiary Glow Shadow
Used on hospitality-themed elements (biometric button ambient border):
- **Standard:** `0 4px 8px rgba(198,139,89,0.15)` — subtle ambient glow

### Backdrop Blur
Core to the dark cinematic system. Used throughout, not limited to first-run:
- **Navigation bars:** `shell/90` with blur(10), top bar and bottom nav
- **Bottom sheets:** `shell-elevated/95` with blur(16)
- **Form containers on dark:** `shell-elevated/80` with blur(24)
- **Onboarding overlay:** `black/62` with blur(24)
- **Login glass card:** `white/72` with blur(24) on photographic background
- **Admin modals:** `shell-elevated/95` with blur(16)

## 7. Components

### Buttons (Dark Shell)
- **Primary CTA:** Cherry Red gradient (primary → primary+dark 15%), `text-primary` or white text, 12-16px radius, full-width on mobile (56-58px height). Primary glow shadow. Press scale: 0.96.
- **Secondary (Dark):** `shell-elevated` background, `outline` border, `text-primary` text. 12px radius. Lighter on press.
- **Ghost:** Transparent background, `text-primary` or primary text. For "View All" and text actions.
- **Icon Button:** 44x44px minimum, `shell-elevated` background, `text-secondary` icon, `shell-high` on press.
- **Biometric Button:** 56x56px, `shell-elevated` with primary border (1.5px), tertiary ambient-breathing glow shadow. Fingerprint icon, primary color.

### Buttons (Light Card Context)
- **Primary CTA (in card):** Same Cherry Red gradient, but shadow adapts to light surface: `0 4px 16px rgba(224,43,43,0.3)`.
- **Minor action:** `card-dim` background, `outline` (adapted) border, `on-card` text.

### Cards

Two card contexts exist in this system: dark-on-dark (structural) and light-on-dark (content).

#### Dark Structure Cards
- `shell-elevated` fill, `outline-variant` or `outline` border (1px), 16px radius
- Shadows: `0 2px 8px rgba(0,0,0,0.3)` for elevation
- Example: admin sidebar items, order status cards, settings rows

#### Light Content Cards (Food, menu items, orders)
- `card` fill (white), 16px radius, `0 2px 12px rgba(0,0,0,0.15)` shadow
- Food photo uses high contrast against the white card
- Price text in primary color
- On dark shell, these cards glow outward: shadow is darker/bigger than it would be on a light background

#### Glassmorphism Cards
- **On dark backgrounds:** `shell-elevated/80` with blur(24), `outline` border (1px), 24px radius
- **On photographic/light backgrounds:** `white/72` with blur(24), `white/85` border, 24px radius
- **Top edge glow:** 1px gradient line (transparent → light/60 → transparent) for depth
- **Used throughout:** login form, onboarding bottom sheet, admin overlays, filter panels

### Chips (Dark Shell)
- **Category Chip (Unselected):** `shell-high` background, `text-secondary` text, full radius (pill).
- **Category Chip (Selected):** Primary background, on-primary text, full radius, primary glow shadow.
- **Tag Chip:** `shell-surface` background, `text-muted` text, 8px radius.
- **Icon Tag Badge:** Primary background pill with icon + footnote text.

### Input Fields (Dark Shell Context)
- **At rest:** `shell-elevated` background, `outline-variant` border (1px), `text-secondary` hint text.
- **Focused:** `shell-high` background, primary border (2px), primary glow shadow (`0 4px 12px primary/20%`).
- **Prefix icon:** Animated scale (1.0 → 1.08 on focus). Color shifts from `text-muted` → primary.
- **Label:** Footnote text, color shifts from `text-secondary` → primary on focus.
- **Error handling:** Shake animation (4-bounce sequence, 400ms) on validation failure. Error border in `error` color.

### Input Fields (Light Card Context)
- **At rest:** `card-dim` background, `outline-variant` border (1px), `on-card-secondary` hint text.
- **Focused:** `card` background, primary border (2px), primary shadow (`0 4px 12px primary/12%`).
- **Prefix icon:** Same animation, `on-card-secondary` → primary.

### Navigation (Dark Shell)
- **Mobile Top Bar:** `shell/80` with backdrop blur(10). `text-primary` title, `text-secondary` actions. Glass effect on scroll.
- **Mobile Bottom Nav:** `shell-elevated/90` with backdrop blur(10), top border `outline-variant`, 5 tabs with icon + label. Active tab: primary color + primary glow shadow. Inactive: `text-muted`.
- **Admin Sidebar (Desktop/Tablet):** `shell-elevated` background, `outline-variant` right border, user profile at top. Active item: `shell-high` background + primary left/RTL-right accent.

### Status Badges (Both Contexts)
- **Pending:** Grain amber (`#E89820`) — on dark: pill with amber/20% background + amber text. On light cards: amber fill + dark text.
- **Confirmed:** Denim blue (`#3B82C4`) — same pattern.
- **Preparing:** Eggplant (`#8B5CF6`) — same pattern.
- **Ready:** Herb green (`#2D8C5E`) — same pattern.
- **Delivered:** Spring leaf (`#22C55E`) — same pattern.
- **Cancelled:** Clay red (`#D14334`) — same pattern.

On dark: always use the `color/20%` background + full color text for readability. On light cards: full color background + white/dark text as contrast allows.

## 8. Layout Patterns

### Mobile Screen Structure (Dark Shell)
```
[Status Bar] — system
[Top App Bar] — shell/80 + blur, 56px height, text-primary
[Content Area] — shell background, scrollable, 16px horizontal margins
  [Dark structure cards] — shell-elevated, for navigation/settings/status
  [Light content cards] — card fill, for food/menu/order data
[Bottom Safe Area] — 16px minimum
[Bottom Navigation] — shell-elevated/90 + blur, 84px height
```

### Home Screen Layout (Dark Shell)
1. **Top Bar:** Logo (primary glow) + notification bell + profile avatar. Shell background with blur on scroll.
2. **Search:** Pill-shaped search bar on `shell-elevated`, search icon, `text-muted` placeholder.
3. **Category Chips:** Horizontal scroll on `shell-elevated` track, `shell-high` background per chip. Active: primary fill.
4. **Hero Banner:** `card`-filled card with food photo, gradient overlay, title + price at bottom. Floating on shell.
5. **Popular Section:** Horizontal snap-scroll, `card`-filled cards with food photos. Section header in `text-primary`.
6. **Menu Grid:** 2-column grid of `card`-filled food cards on dark shell.

### Product Detail Layout (Dark Shell)
1. **Hero Image:** Full-width on `card` surface, parallax scroll, rounded bottom corners.
2. **Product Info:** Light card below hero. Name (Large Title), description (Body), price (Headline, primary color).
3. **Customization Sections:** Dark structure cards (`shell-elevated`) with expandable sections.
4. **Sticky Footer:** `shell-elevated` with blur, quantity selector + primary CTA.

### Admin Dashboard Layout (Dark Shell)
1. **KPI Cards:** Dark structure cards (`shell-elevated`) with `text-primary` values, `text-secondary` labels.
2. **Performance Chart:** Dark card with light chart content overlay. Chart grid lines in `outline-variant`.
3. **Recent Orders:** Dark list items (`shell-elevated`), light avatar circles, status badges with contextual coloring.
4. **Pending Actions:** Primary-glowed alert cards on `shell-elevated` surface.

## 9. Motion & Animation

### Principles
- Duration: Fast (100-200ms), Medium (300-450ms), Slow (500ms+)
- Easing: `easeOutCubic` for entrances, `easeInOut` for loops, `elasticOut` for spring entries
- Movement: Purposeful, atmospheric. Dark cinematic surfaces invite more motion than light product surfaces.
- Orchestrated page-load sequences are permitted where they serve emotional anchoring (splash, onboarding). Product surfaces should still load into task.

### Dark Cinematic Motion Catalog

#### Ambient Effects (Continuous)
- **Ambient breathing blobs:** Two radial gradient circles (primary 9%, tertiary 12%) breathing on 7s cycle. Present on all full-screen surfaces where photographic or gradient headers exist (splash, onboarding, login, home header).
- **Particle shimmer:** Subtle floating particles on splash screen only. Not carried to product surfaces.
- **Glow pulse:** Primary shadow opacity oscillation on CTAs during focused states (1.6s cycle on last onboarding page, 7s on ambient).

#### Entrance Animations
- **Splash:** Multi-layered cinematic sequence (3200ms). Background gradient fade, vignette, particle system, rotating arcs, glow halo, logo elasticOut spring, progress ring, tagline slide, exit fade.
- **Onboarding:** Content fade-out (450ms) → page swipe (600ms, easeInOutCubic) → content fade-in (450ms).
- **Auth staggered entrance:** 9 animation intervals over 1100ms (register), 3 over 900ms (login). Header → form fields → CTA.
- **Product screen entrance:** Subtle fade + slide (250ms, easeOutCubic). No orchestrated sequences.

#### Interactive Feedback
- **Card press:** Scale 0.98 (100ms)
- **Button press:** Scale 0.96 (100ms)
- **Add to cart:** Icon bounce + badge count pop (300ms, spring)
- **Input focus:** Border width 1→2px (200ms), glow shadow fade-in (200ms), icon scale 1.0→1.08 (200ms)
- **Shake error:** 5-item TweenSequence, 400ms
- **Shimmer loading:** 3-stop animated sweep across CTA button
- **Bottom sheet:** Slide up + fade (300ms)
- **Modal:** Scale from 0.95 + fade (250ms)
- **Status change:** Color transition + subtle pulse

#### Onboarding Specific
- **Swipe hint:** Pulsing chevron pair (1.2s cycle, 12px offset, RTL direction)
- **CTA glow pulse (last page):** Shadow opacity 0.25→0.6 (1.6s cycle)
- **Page indicators:** Animated width 8px→28px (350ms, easeInOut)
- **Parallax:** Image offset at 30% of page delta

#### Register Specific
- **Step indicator:** 4 numbered circles (24px) with animated connecting lines (300ms, easeOut)
- **Password strength:** 4-segment animated bar, color progression red→orange→green→dark green, AnimatedSwitcher label (200ms)

## 10. First-Run Visual Language

The splash, onboarding, and auth screens establish the dark cinematic language that continues through the entire app. These screens have more decorative motion and atmosphere, but the dark shell and color strategy are persistent.

### Splash Screen
- **Background:** Deep cherry radial gradient (center `#3D1010` → shell), animated center color shift (4s cycle)
- **Atmosphere:** Floating particle system (14 particles), rotating decorative arcs (primary + tertiary), pulsating glow halo
- **Navigation:** Auto-advances after 3200ms + auth resolution
- **Fallback:** Circular placeholder with primary border and restaurant icon

### Onboarding Screen
- **Background:** Full-bleed photography with page-specific gradient overlays
  - Page 1 (Food): Deep cherry gradients
  - Page 2 (Delivery): Forest green gradients
  - Page 3 (Payment): Deep blue gradients
- **Bottom card:** Dark glassmorphism (`black/62`, blur 24, white/12 top border, 32px top radius)
- **Tag badge:** Primary background pill with icon + footnote
- **Title pattern:** Bold Arabic title + accent-colored highlight word
- **Skip button:** Frosted glass pill (`white/18`, blur 12, `white/30` border), 44x44 minimum touch target
- **CTA:** Gradient button with dynamic glow shadow

### Login Screen
- **Hero image:** Top 48% with food photography, gradient fade to `shell`
- **Ambient blobs:** Primary (9%) + tertiary (12%) breathing on 7s cycle
- **Form card:** Glassmorphism (`shell-elevated/80`, blur 24, `outline` border, 24px radius, top edge glow)
- **Password field:** Animated focus container with primary glow shadow
- **Biometric button:** 56x56 with ambient-breathing primary border glow

### Register Screen
- **Header:** Gradient mesh with 3 procedural radial circles (primary, tertiary) over dark base, fading to `shell`
- **Form card:** `shell-elevated` with `outline` border, 24px radius. Top edge: 2px primary gradient glow line.
- **Step indicator:** 4-step progress with animated connecting lines

### Transition Pattern
No jarring light-to-dark transitions. The dark shell is constant from splash through every screen. The visual shift is:
1. **Cinematic entry (splash):** Rich gradients, particles, glow halos, spring animations.
2. **Atmospheric browsing (home, menu):** Dark shell with ambient blobs in headers, light content cards, restrained primary accent.
3. **Functional depth (cart, checkout, admin):** Dark shell with dark structure cards, light data cards, focused glow shadows on actions only.

The shell is the constant. Atmosphere adjusts per context.

## 11. Dark-to-Light Surface Usage Rules

Not every element gets a light card. The dark shell is the default; light surfaces are reserved for content that demands high contrast.

### When to use Light Cards (`card` = white)
- Food item cards (photo + name + price need to pop)
- Menu category content areas
- Order summary cards
- Product detail hero image area
- Admin data tables (readability for dense data)
- Form inputs within glassmorphism containers (readability for text entry)
- Receipt/thermal printer previews

### When to use Dark Structure Cards (`shell-elevated` / `shell-high`)
- Navigation sidebar items
- Category chips (horizontal scroll)
- Settings rows
- Status indicators (inherent color provides contrast)
- Search bar background
- Bottom navigation
- Admin KPI cards (large numbers in `text-primary` read well on dark)
- Filter toggles and controls

### Text Placement
- **`text-primary` (warm white)** on all dark surfaces: `shell`, `shell-elevated`, `shell-high`
- **`on-card` (deep cocoa)** on all light card surfaces: `card`, `card-dim`, `card-mid`
- Never mix. If the background is dark, text is warm white. If the background is light, text is deep cocoa.

## 12. Do's and Don'ts

### Do:
- Use Cherry Red for primary actions, glow shadows, and active states (Committed strategy, 20-30% surface area)
- Use Amber Gold for warmth accents, hospitality icons, specialty badges, rating stars
- Use Warm Cocoa for structural borders, secondary elements, muted actions
- Use the dark shell (`#1F1615`) as the constant background across every screen
- Use light content cards (`#FFFFFF`) only where contrast demands it (food photos, dense data, form inputs)
- Use backdrop blur for navigation, modals, form containers, and overlay panels
- Use Cairo for all Arabic text, Inter for Latin text in mixed contexts
- Design every layout RTL-first
- Provide skeleton loading states with dark shimmer (shell-high on shell background)
- Use staggered entrance animations on key screens
- Enforce 44x44px minimum touch targets on all interactive elements
- Use primary glow shadows on CTAs and focus states (dark surfaces interact with light differently)

### Don't:
- Use pure black (`#000000`) or pure white (`#FFFFFF`) as fills. Shell is `#1F1615`; cards are `#FFFFFF` for content only.
- Use gradient text (`background-clip: text` with gradient background)
- Use glassmorphism decoratively on dark structure cards (blur serves readability, not aesthetics)
- Use side-stripe borders as accents
- Use identical card grids without variation
- Animate layout properties (width, height, top, left)
- Use modals as the first solution (prefer inline or progressive)
- Apply letter-spacing to Arabic text
- Switch to a light theme mid-flow. The dark shell is the constant.
- Use light backgrounds for structural elements that don't contain photos or dense text
- Place warm white text on light card surfaces, or deep cocoa text on dark surfaces