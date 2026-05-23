---
name: Levantine Clarity
description: iOS-inspired Arabic food ordering app with premium Middle Eastern aesthetic
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
  
  # Tertiary - Wild Pistachio Green (Freshness, organic & Levantine hospitality)
  tertiary: "#62825D"
  on-tertiary: "#ffffff"
  tertiary-container: "#e2efe0"
  on-tertiary-container: "#1e351b"
  tertiary-fixed: "#e2efe0"
  tertiary-fixed-dim: "#b8cbb4"
  on-tertiary-fixed: "#081e07"
  on-tertiary-fixed-variant: "#344a30"
  
  # Error
  error: "#ba1a1a"
  on-error: "#ffffff"
  error-container: "#ffdad6"
  on-error-container: "#93000a"
  
  # Surfaces (Warm Rose White theme)
  background: "#fdf8f7"
  on-background: "#2c2120"
  surface: "#ffffff"
  on-surface: "#2c2120"
  on-surface-variant: "#7a6b69"
  inverse-surface: "#3b302f"
  inverse-on-surface: "#faf0ef"
  surface-variant: "#f5e7e5"
  surface-dim: "#fcf5f4"
  surface-bright: "#fdf8f7"
  surface-tint: "#e02b2b"
  
  # Surface Containers
  surface-container-lowest: "#ffffff"
  surface-container-low: "#fcf5f4"
  surface-container: "#f6eceb"
  surface-container-high: "#efe2e0"
  surface-container-highest: "#e7d8d6"
  
  # Outlines
  outline: "#8c7b79"
  outline-variant: "#e0d2d0"

typography:
  large-title:
    fontFamily: Inter
    fontSize: 34px
    fontWeight: '700'
    lineHeight: 41px
    letterSpacing: 0.37px
  headline:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: -0.41px
  body:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: -0.41px
  callout:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 21px
    letterSpacing: -0.32px
  subheadline:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: -0.24px
  footnote:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: -0.08px
  caption:
    fontFamily: Inter
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

# Design System: Levantine Clarity

## 1. Overview

**Creative North Star: "Modern Arabic Hospitality"**

Tarwika looks like a premium iOS-native experience infused with the warmth of Middle Eastern dining. The visual system follows Apple's Human Interface Guidelines (HIG) while honoring Arabic cultural aesthetics: clean but never cold, structured but never rigid, premium but never pretentious.

The system uses a **Full Palette** strategy with three distinct color roles. Cherry Red drives primary actions and stimulates appetite. Warm Cocoa provides a balanced, natural structural framework. Wild Pistachio Green handles freshness tags, organic elements, specialty options, and culinary delight highlights.

**Key Characteristics:**
- iOS-native feel with Arabic hospitality warmth
- Three-color harmony: cherry red (action), warm cocoa (structure), wild pistachio green (accent)
- Cozy warm rose surfaces with subtle tonal layering
- Inter font for systematic, highly legible typography
- RTL-native layouts with generous whitespace
- Card-based layouts with soft shadows and generous rounding
- iOS-style bottom navigation with blur backdrop

## 2. Colors

### Primary Accent (Cherry Red — Action & Appetite)
- **Primary** (`#e02b2b`): Main action buttons, hero highlights, selected states, focus rings. The appetite stimulator.
- **Primary Container** (`#ffe3e3`): Active chip fills, active segment backdrops, highlights.
- **On Primary** (`#ffffff`): Text on primary-colored backgrounds.
- **On Primary Container** (`#8b1e1e`): Text on primary container backgrounds.

### Secondary Accent (Warm Cocoa — Structure & Balance)
- **Secondary** (`#5c4e4d`): Success states, natural/vegetarian tags, secondary actions, and balanced structures.
- **Secondary Container** (`#f0e3e2`): Selected category backgrounds, success pill backgrounds.
- **On Secondary** (`#ffffff`): Text on secondary backgrounds.
- **On Secondary Container** (`#2c2120`): Text on secondary container backgrounds.

### Tertiary Accent (Wild Pistachio Green — Freshness & Levantine Hospitality)
- **Tertiary** (`#62825D`): Freshness tags, rating stars, vegan/vegetarian indicators, hospitality icons, special discounts, and balanced botanical accents.
- **Tertiary Container** (`#e2efe0`): Info highlights, nutritional tags, light badge backdrops.
- **On Tertiary** (`#ffffff`): Text on tertiary backgrounds.
- **On Tertiary Container** (`#1e351b`): Text on tertiary container backgrounds.

### Neutral Surfaces (Warm Rose White theme)
- **Background** (`#fdf8f7`): Main app background. Soft warm rose off-white. Extremely inviting.
- **Surface** (`#ffffff`): Card and sheet backgrounds. Clean high-contrast white.
- **Surface Container Low** (`#fcf5f4`): Grouped content areas, input fields at rest.
- **Surface Container** (`#f6eceb`): Elevated sections, grouped list backgrounds.
- **Surface Container High** (`#efe2e0`): Higher elevation surfaces, selected rows.
- **Surface Variant** (`#f5e7e5`): Borders, dividers, inactive track backgrounds.

### Text Colors
- **On Surface** (`#2c2120`): Primary text, headings. Deep cocoa black.
- **On Surface Variant** (`#7a6b69`): Secondary text, descriptions, placeholders. Soft rose grey.
- **Outline** (`#8c7b79`): Borders, inactive icons, disabled text.
- **Outline Variant** (`#e0d2d0`): Subtle dividers, section separators.

### Inverse (Dark Mode)
- **Inverse Surface** (`#3b302f`): Dark mode elevated surfaces.
- **Inverse On Surface** (`#faf0ef`): Dark mode primary text.
- **Inverse Primary** (`#ffb4ab`): Dark mode primary accent.

## 3. Typography

**Font:** Inter (Google Fonts) — systematic, legible, neutral

Inter serves as a highly legible alternative to SF Pro, providing systematic hierarchy without personality conflicts. It pairs beautifully with Arabic script when Cairo is used for Arabic text.

### Hierarchy
- **Large Title** (w700, 34px, 41px lh): Screen titles, hero headlines. Used sparingly.
- **Headline** (w600, 17px, 22px lh, -0.41px ls): Card titles, section headers, button labels.
- **Body** (w400, 17px, 22px lh, -0.41px ls): Primary reading text. Most common style.
- **Callout** (w400, 16px, 21px lh, -0.32px ls): Emphasized body text, form labels.
- **Subheadline** (w400, 15px, 20px lh, -0.24px ls): Secondary labels, metadata, captions.
- **Footnote** (w400, 13px, 18px lh, -0.08px ls): Tertiary info, timestamps, helper text.
- **Caption** (w400, 12px, 16px lh, 0px ls): Badges, small labels, price modifiers.

### Named Rules
- **Arabic line height boost:** Increase line-height by 10-15% for Arabic text to accommodate taller diacritics.
- **Weight contrast:** Minimum 200 weight difference between hierarchical levels (e.g., 400 vs 600).
- **RTL-first:** All text alignment starts from the right. Even numeric values (prices) align right in Arabic contexts.

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
| Small (SM) | 4px (0.25rem) | Small buttons, inline tags, checkboxes |
| Default | 8px (0.5rem) | Input fields, small cards, chips |
| Medium (MD) | 12px (0.75rem) | Standard cards, modals, buttons |
| Large (LG) | 16px (1rem) | Large cards, bottom sheets, image containers |
| Extra Large (XL) | 24px (1.5rem) | Hero banners, featured content |
| Full | 9999px | Pills, avatars, FABs, search bars |

## 6. Elevation & Shadows

Depth is communicated through tonal layers and ambient shadows, following iOS HIG principles.

| Level | Shadow | Usage |
|-------|--------|-------|
| **Level 0 (Base)** | None | Background surfaces |
| **Level 1 (Cards)** | `0 2px 8px rgba(0,0,0,0.04)` | Content cards, elevated buttons |
| **Level 2 (Modals)** | `0 4px 16px rgba(0,0,0,0.08)` + backdrop blur | Bottom sheets, dialogs |
| **Level 3 (Floating)** | `0 8px 32px rgba(0,0,0,0.12)` | FABs, floating action bars |

### Backdrop Blur
- Modals use `backdrop-filter: blur(12px)` with semi-transparent backgrounds (`bg-surface/80`)
- Navigation bars use `backdrop-filter: blur(10px)` for frosted glass effect

## 7. Components

### Buttons
- **Primary:** Cherry Red (`#e02b2b`) background, white text, 12px radius, full-width on mobile (52px height)
- **Secondary:** Surface background, primary border, primary text. 12px radius.
- **Ghost:** Transparent background, primary text. For "View All" and text actions.
- **Icon Button:** 40x40px circle, surface background, subtle hover state.

### Cards
- **Food Card (Horizontal):** White surface, 16px radius, `0 2px 8px rgba(0,0,0,0.04)` shadow.
  - Image left (RTL: right), 120px square
  - Title (Headline), description (Subheadline, 2 lines max), price (Headline, primary color)
  - Circular add button (primary, 32px diameter)
- **Food Card (Vertical/Grid):** White surface, 16px radius, image top (16:10 aspect ratio), content below.
- **Hero Card:** Full-width, 220px height, 16px radius, image with gradient overlay (transparent to black 80% at bottom).
  - Badge (primary container) top-right
  - Title + price at bottom over gradient

### Chips
- **Category Chip (Unselected):** Surface container low background, on-surface-variant text, full radius (pill), 10px vertical / 18px horizontal padding.
- **Category Chip (Selected):** Primary background, on-primary text, full radius.
- **Tag Chip:** Surface variant background, outline text, 8px radius.

### Input Fields
- **Search Bar:** Surface container low background, 8px or full radius (pill), search icon right (RTL), microphone icon left.
- **Text Input:** Surface container lowest background, 12px radius, 1px outline border, focus: 2px primary border.
- **Text Area:** Same as text input, multiline, 24px min height.

### Navigation
- **Mobile Top Bar:** Surface/80 with backdrop blur. Logo/title center, actions right (RTL: left).
- **Mobile Bottom Nav:** Surface/90 with backdrop blur, rounded top corners (24px radius top), 84px total height with 16px bottom safe area. 5 tabs with icon + label.
- **Admin Sidebar (Desktop):** 320px width, surface background, shadow-2xl. User profile at top, nav links below.

### Status Badges
- **Pending:** Grain amber (`#E89820`) background, dark text
- **Confirmed:** Denim blue (`#3B82C4`) background, white text
- **Preparing:** Eggplant (`#8B5CF6`) background, white text
- **Ready:** Herb green (`#2D8C5E`) background, white text
- **Delivered:** Spring leaf (`#22C55E`) background, white text
- **Cancelled:** Clay red (`#D14334`) background, white text

## 8. Layout Patterns

### Mobile Screen Structure
```
[Status Bar]
[Top App Bar] - Blur backdrop, 56px height
[Content Area] - Scrollable, 16px horizontal margins
[Bottom Safe Area] - 16px minimum
[Bottom Navigation] - Fixed, 84px height (includes safe area)
```

### Home Screen Layout
1. **Top Bar:** Logo + notification bell + profile avatar
2. **Search:** Collapsible pill-shaped search bar
3. **Category Chips:** Horizontal scroll, snap to center
4. **Hero Banner:** Full-width carousel, auto-advance 5s, parallax
5. **Popular Section:** Horizontal snap-scroll cards (240px width)
6. **Menu Grid:** 2-column masonry-style grid on mobile, 3-column on tablet

### Product Detail Layout
1. **Hero Image:** Full-width, parallax scroll, collapsible
2. **Product Info:** Name (Large Title), description (Body), price (Headline, primary)
3. **Customization Sections:** Accordion-style expanders for sizes, extras, variants, removals
4. **Notes:** Text area for kitchen instructions
5. **Related Items:** Horizontal scroll cards
6. **Sticky Footer:** Quantity selector + "Add to Cart" CTA

### Admin Dashboard Layout
1. **KPI Cards:** 2x2 grid on mobile, 4-column on desktop
2. **Performance Chart:** Line + bar combo chart
3. **Recent Orders:** List with avatar, order info, status badge
4. **Pending Actions:** Alert cards for orders awaiting confirmation

## 9. Motion & Animation

### Principles
- Duration: Fast (200ms), Medium (300ms), Slow (500ms)
- Easing: `ease-out-cubic` for entrances, `ease-in-out` for transitions
- Movement: Subtle, purposeful, never distracting

### Specific Animations
- **Screen transitions:** Fade + slight slide (250ms, ease-out-cubic)
- **Card press:** Scale 0.98 (100ms)
- **Button press:** Scale 0.96 + shadow inset (100ms)
- **Add to cart:** Icon bounce + badge count pop (300ms, spring curve)
- **Image loading:** Skeleton shimmer (1.5s, infinite)
- **Bottom sheet:** Slide up from bottom + fade (300ms)
- **Modal:** Scale from 0.95 + fade (250ms)
- **Status changes:** Color transition + subtle pulse

## 10. Do's and Don'ts

### Do:
- Use Cherry Red for primary actions only (buttons, CTAs, focus states)
- Use Warm Cocoa for structural elements (selected chips, success states, category markers)
- Use Amber Gold for informational accents (links, scheduled indicators, badges)
- Stack surfaces with tonal shifts (background → surface → container)
- Use Inter for all Latin text, Cairo for Arabic text
- Design every layout RTL-first
- Use backdrop blur for navigation and modals
- Provide skeleton loading states for all async content
- Support dark mode with proper surface inversions

### Don't:
- Use pure black (`#000000`) or pure white (`#ffffff`)
- Use gradient text or decorative gradients
- Use heavy, dark shadows (keep shadows subtle and diffused)
- Use side-stripe borders as accents
- Use identical card grids without variation
- Animate CSS layout properties (width, height, top, left)
- Use modals as the first solution (prefer inline or progressive disclosure)
- Apply letter-spacing to Arabic text
