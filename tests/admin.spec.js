// @ts-check
const { test, expect } = require('@playwright/test');
const { goTo, expectAppRendered, screenshot } = require('./test-utils');

test.describe('Admin Panel', () => {

  test('admin route redirects to auth when not logged in', async ({ page }) => {
    // Admin routes are auth-protected — unauthenticated users get redirected
    await page.goto('http://localhost:8080/admin', { waitUntil: 'load', timeout: 60000 });
    await page.waitForTimeout(5000);
    // Should redirect away from admin to auth (onboarding or login)
    const url = page.url();
    expect(url).not.toContain('/admin');
  });

  test('admin orders screen loads', async ({ page }) => {
    await goTo(page, '/admin/orders');
    await expectAppRendered(page);
    await screenshot(page, 'admin-orders');
  });

  test('admin menu screen loads', async ({ page }) => {
    await goTo(page, '/admin/menu');
    await expectAppRendered(page);
  });

  test('admin categories screen loads', async ({ page }) => {
    await goTo(page, '/admin/categories');
    await expectAppRendered(page);
  });

  test('admin coupons screen loads', async ({ page }) => {
    await goTo(page, '/admin/coupons');
    await expectAppRendered(page);
  });

  test('admin customers screen loads', async ({ page }) => {
    await goTo(page, '/admin/customers');
    await expectAppRendered(page);
  });

  test('admin delivery zones screen loads', async ({ page }) => {
    await goTo(page, '/admin/delivery-zones');
    await expectAppRendered(page);
  });

  test('admin reports screen loads', async ({ page }) => {
    await goTo(page, '/admin/reports');
    await expectAppRendered(page);
  });

  test('admin business profile screen loads', async ({ page }) => {
    await goTo(page, '/admin/business-profile');
    await expectAppRendered(page);
  });

  test('admin product form screen loads', async ({ page }) => {
    await goTo(page, '/admin/product/new');
    await expectAppRendered(page);
  });

  test('admin coupon form screen loads', async ({ page }) => {
    await goTo(page, '/admin/coupons/create');
    await expectAppRendered(page);
  });

  test('admin delivery zone form screen loads', async ({ page }) => {
    await goTo(page, '/admin/delivery-zones/create');
    await expectAppRendered(page);
  });

  test('admin printer settings screen loads', async ({ page }) => {
    await goTo(page, '/admin/printer-settings');
    await expectAppRendered(page);
  });

  test('admin notifications screen loads', async ({ page }) => {
    await goTo(page, '/admin/notifications');
    await expectAppRendered(page);
  });

});
