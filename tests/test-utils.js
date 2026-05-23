// @ts-check
const { expect } = require('@playwright/test');

const BASE_URL = 'http://localhost:8080';

/**
 * Navigate to a path and wait for the Flutter app to initialize.
 * Flutter 3.41+ uses skwasm/WebGL renderer — renders to an opaque canvas.
 * We can only verify page load, canvas presence, and URL changes.
 */
async function goTo(page, path) {
  await page.goto(BASE_URL + path, { waitUntil: 'load', timeout: 60000 });
  await page.waitForSelector('flutter-view', { state: 'attached', timeout: 30000 });
  await page.waitForTimeout(4000);
}

/**
 * Assert the current URL ends with the expected path.
 */
async function expectPath(page, expectedPath) {
  await expect(page).toHaveURL((url) => url.pathname === expectedPath);
}

/**
 * Assert the page has a Flutter canvas (app rendered).
 */
async function expectAppRendered(page) {
  await expect(page.locator('flutter-view')).toBeAttached();
}

/**
 * Take a named screenshot for visual comparison.
 */
async function screenshot(page, name) {
  await page.screenshot({ path: `test-results/screenshots/${name}.png`, fullPage: true });
}

module.exports = {
  goTo,
  expectPath,
  expectAppRendered,
  screenshot,
  BASE_URL,
};

