from playwright.sync_api import sync_playwright
import time, json

results = {}

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)

    # Test 1: Desktop performance
    page = browser.new_page(viewport={"width": 1440, "height": 900})

    console_msgs = []
    page.on("console", lambda msg: console_msgs.append(f"[{msg.type}] {msg.text}"))

    errors = []
    page.on("pageerror", lambda err: errors.append(str(err)))

    # Measure load time
    start = time.time()
    page.goto("http://localhost:8080", wait_until="networkidle")
    load_time = round((time.time() - start) * 1000)

    # Screenshot desktop
    page.screenshot(
        path="D:/desktop/claude resturant/website/test-desktop.png", full_page=True
    )

    # Check image loading
    images = page.evaluate("""() => {
        const imgs = document.querySelectorAll('img');
        const results = [];
        imgs.forEach(img => {
            results.push({
                src: img.src.split('/').pop(),
                loaded: img.complete && img.naturalWidth > 0,
                width: img.naturalWidth,
                height: img.naturalHeight
            });
        });
        return results;
    }""")

    # Check CSS/JS file sizes
    resources = page.evaluate("""() => {
        const entries = performance.getEntriesByType('resource');
        return entries.map(e => ({
            name: e.name.split('/').pop(),
            type: e.initiatorType,
            duration: Math.round(e.duration),
            size: e.transferSize || 0
        }));
    }""")

    # Check for render-blocking
    paint = page.evaluate("""() => {
        const entries = performance.getEntriesByType('paint');
        return entries.map(e => ({ name: e.name, time: Math.round(e.startTime) }));
    }""")

    # LCP
    lcp = page.evaluate("""() => {
        return new Promise(resolve => {
            new PerformanceObserver(list => {
                const entries = list.getEntries();
                resolve(Math.round(entries[entries.length - 1].startTime));
            }).observe({type: 'largest-contentful-paint', buffered: true});
            setTimeout(() => resolve(null), 3000);
        });
    }""")

    # CLS
    cls = page.evaluate("""() => {
        return new Promise(resolve => {
            let score = 0;
            new PerformanceObserver(list => {
                list.getEntries().forEach(e => { if (!e.hadRecentInput) score += e.value; });
            }).observe({type: 'layout-shift', buffered: true});
            setTimeout(() => resolve(Math.round(score * 1000) / 1000), 2000);
        });
    }""")

    # DOM stats
    dom = page.evaluate("""() => ({
        elements: document.querySelectorAll('*').length,
        dom_depth: (() => {
            let max = 0;
            function walk(el, depth) {
                if (depth > max) max = depth;
                for (const child of el.children) walk(child, depth + 1);
            }
            walk(document.body, 0);
            return max;
        })(),
        inline_styles: document.querySelectorAll('[style]').length,
        scripts: document.querySelectorAll('script').length,
        stylesheets: document.querySelectorAll('link[rel=stylesheet]').length
    })""")

    # Test 2: Mobile performance
    mobile = browser.new_page(viewport={"width": 375, "height": 812})
    mobile.goto("http://localhost:8080", wait_until="networkidle")
    mobile.screenshot(
        path="D:/desktop/claude resturant/website/test-mobile.png", full_page=True
    )

    # Test 3: Tablet
    tablet = browser.new_page(viewport={"width": 768, "height": 1024})
    tablet.goto("http://localhost:8080", wait_until="networkidle")
    tablet.screenshot(
        path="D:/desktop/claude resturant/website/test-tablet.png", full_page=True
    )

    # Check accessibility basics
    a11y = page.evaluate("""() => {
        const issues = [];
        // Check all images have alt
        document.querySelectorAll('img').forEach(img => {
            if (!img.alt && !img.getAttribute('alt') && img.alt !== '') {
                issues.push('Missing alt: ' + img.src.split('/').pop());
            }
        });
        // Check buttons have labels
        document.querySelectorAll('button').forEach(btn => {
            if (!btn.getAttribute('aria-label') && !btn.textContent.trim()) {
                issues.push('Unlabeled button');
            }
        });
        // Check heading hierarchy
        const headings = Array.from(document.querySelectorAll('h1,h2,h3,h4,h5,h6')).map(h => parseInt(h.tagName[1]));
        for (let i = 1; i < headings.length; i++) {
            if (headings[i] - headings[i-1] > 1) {
                issues.push('Heading skip: h' + headings[i-1] + ' -> h' + headings[i]);
            }
        }
        return issues;
    }""")

    browser.close()

# Build report
broken_images = [img for img in images if not img["loaded"]]
total_transfer = sum(r["size"] for r in resources)

report = f"""
========================================
  PERFORMANCE REPORT — tarwi2a.com
========================================

LOAD TIME:        {load_time}ms
LCP:              {lcp}ms  (target: < 2500ms)
CLS:              {cls}  (target: < 0.1)

PAINT TIMINGS:
"""
for p_entry in paint:
    report += f"  {p_entry['name']}: {p_entry['time']}ms\n"

report += f"""
DOM STATS:
  Total elements:    {dom["elements"]}
  Max DOM depth:     {dom["dom_depth"]}
  Inline styles:     {dom["inline_styles"]}
  Scripts:           {dom["scripts"]}
  Stylesheets:       {dom["stylesheets"]}

IMAGES ({len(images)} total):
  Broken:            {len(broken_images)}
"""
for img in broken_images:
    report += f"  X {img['src']}\n"

report += f"""
RESOURCES ({len(resources)} total):
  Transfer size:     {round(total_transfer / 1024, 1)}KB
"""
for r in sorted(resources, key=lambda x: -x["size"])[:10]:
    size_kb = round(r["size"] / 1024, 1) if r["size"] else "?"
    report += (
        f"  {r['type']:12} {r['name'][:40]:40} {size_kb:>6}KB  {r['duration']}ms\n"
    )

report += f"""
CONSOLE ({len(console_msgs)} messages):
"""
for msg in console_msgs[:10]:
    report += f"  {msg}\n"

report += f"""
JS ERRORS ({len(errors)}):
"""
for err in errors[:5]:
    report += f"  {err[:120]}\n"

report += f"""
ACCESSIBILITY ({len(a11y)} issues):
"""
for issue in a11y:
    report += f"  ! {issue}\n"

# Score calculation
score = 100
if load_time > 3000:
    score -= 15
elif load_time > 1500:
    score -= 5
if lcp and lcp > 2500:
    score -= 15
elif lcp and lcp > 1000:
    score -= 5
if cls > 0.1:
    score -= 10
if broken_images:
    score -= 10
if errors:
    score -= 10
if len(console_msgs) > 5:
    score -= 5
if dom["elements"] > 1500:
    score -= 5
if a11y:
    score -= len(a11y) * 2
if total_transfer > 500000:
    score -= 10

report += f"""
========================================
  OVERALL SCORE: {max(score, 0)}/100
========================================
"""

print(report)

with open(
    "D:/desktop/claude resturant/website/PERFORMANCE_REPORT.txt", "w", encoding="utf-8"
) as f:
    f.write(report)
