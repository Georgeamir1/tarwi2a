# Website Quality Improvements — Remaining Tasks

> Last rated: **7.5/10** (up from ~5.5 after Phase 1 fixes)

## Phase 2 — High Priority

### HTML (`index.html`)
1. **Fix OG/Twitter image paths** — Change `assets/images/...` to absolute URL (social sharing broken when shared on WhatsApp/Twitter)
2. **Fix `aria-disabled` on `<a href="#">`** — Footer legal links scroll to top when clicked; replace with `<span>` elements
3. **Add `loading="lazy"`** to 18 below-the-fold images (3 feature images + 15 category thumbnail `<img>` tags)
4. **Add `role="status"` / `aria-live="polite"`** to toast `#toast` (copy confirmation invisible to screen readers)
5. **Add `<link rel="canonical">`** tag in `<head>`
6. **Add `width` / `height`** attributes to key images (hero-logo, feature-image, logo-img) to prevent CLS layout shift

### CSS (`style.css`)
7. **Merge duplicate `.hero-content` blocks** — Two definitions at lines ~456 and ~600 override each other; consolidate into one
8. **Replace 3x `!important`** (lines 380, 1710, 1789) with higher-specificity selectors
9. **Add `.hidden` utility class** — Replace inline `style="display:none"` on HTML elements with CSS class
10. **Add `@media print` styles** — Hide nav, FAB, scroll indicator; show contact info
11. **Add tablet breakpoint** `@media (max-width: 1024px)` — 2-col feature grid, adjusted spacing
12. **Remove dead CSS comments** (e.g. `/* Stats (removed — no longer in HTML) */` on line 579)

### JS (`script.js`)
13. **Throttle scroll listener** — Wrap `updateActiveNavLink()` call with `requestAnimationFrame` to reduce ~60x/sec to once per frame
14. **Scope MutationObserver** — Observe `#menuGrid` instead of entire `document.body` (less GC pressure, fewer false triggers)
15. **Add `aria-pressed`** to category filter `.cat-btn` buttons — Toggle in JS on category change
16. **Wrap all JS in IIFE** — `(() => { ... })();` to prevent global scope pollution

## Phase 3 — Low Priority / Polish
17. Convert remaining ~15 hardcoded `rgba()` values to CSS custom properties
18. Add OG `og:url` meta tag (absolute URL)
19. Add `og:site_name` meta tag
20. Consider `prefers-color-scheme` dark mode (stretch goal)

---

## Instructions for Next Agent
- Read `PROGRESS.md` first for current project state
- Read `PLAN.md` for full project context
- Load relevant skills before writing code
- Run `flutter analyze` equivalent (manual browser test) after changes
- Each task above maps to a small, focused edit — no large refactors
