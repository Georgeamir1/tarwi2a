# Website Quality Improvements — Remaining Tasks

> Last rated: **7.5/10** (up from ~5.5 after Phase 1 fixes)

## Phase 2 — High Priority

### HTML (`index.html`)
1. [x] **Fix OG/Twitter image paths** — Changed to absolute URLs (https://tarwi2a.com/...)
2. [x] **Fix `aria-disabled` on footer links** — Replaced `<a href="#">` with `<span>` elements
3. [x] **Add `loading="lazy"`** to below-the-fold images (hero ambient + 3 feature images + footer logo)
4. [x] **Add `role="status"` / `aria-live="polite"`** to toast `#toast`
5. [x] **Add `<link rel="canonical">`** tag in `<head>`
6. [x] **Add `width` / `height`** attributes to key images (logo, hero-logo, feature images, footer logo)

### CSS (`style.css`)
7. [x] **Merge duplicate `.hero-content` blocks** — Consolidated into one block
8. [x] **Replace 3x `!important`** with higher-specificity selectors
9. [x] **Add `.hidden` utility class** — Replaced inline `style="display:none"` on HTML elements
10. ~~Add `@media print` styles~~ — SKIPPED (UI change)
11. ~~Add tablet breakpoint~~ — SKIPPED (UI change)
12. [x] **Remove dead CSS comment** (`/* Stats (removed — no longer in HTML) */`)

### JS (`script.js`)
13. [x] **Throttle scroll listener** — Wrapped `updateActiveNavLink()` with `requestAnimationFrame`
14. [x] **Scope MutationObserver** — Now observes `#menuGrid` instead of `document.body`
15. [x] **Add `aria-pressed`** to category filter buttons — Toggled in JS on category change
16. [x] **Wrap all JS in IIFE** — `(() => { ... })();`

## Phase 3 — Low Priority / Polish
17. [x] Convert remaining hardcoded `rgba()` values to CSS custom properties
18. [x] Add OG `og:url` meta tag (absolute URL)
19. [x] Add `og:site_name` meta tag
20. ~~Consider `prefers-color-scheme` dark mode~~ — SKIPPED (UI change)

---

## Instructions for Next Agent
- Read `PROGRESS.md` first for current project state
- Read `PLAN.md` for full project context
- Load relevant skills before writing code
- Run `flutter analyze` equivalent (manual browser test) after changes
- Each task above maps to a small, focused edit — no large refactors
