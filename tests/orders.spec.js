// @ts-check
const { test, expect } = require('@playwright/test');
const { goTo, expectAppRendered, screenshot } = require('./test-utils');

test.describe('Orders Flow', () => {

  test('orders screen loads', async ({ page }) => {
    await goTo(page, '/orders');
    await expectAppRendered(page);
    await screenshot(page, 'orders-list');
  });

  test('order detail screen loads', async ({ page }) => {
    await goTo(page, '/orders/sample-id');
    await expectAppRendered(page);
  });

  test('order tracking screen loads', async ({ page }) => {
    await goTo(page, '/orders/sample-id/track');
    await expectAppRendered(page);
  });

  test('rate order screen loads', async ({ page }) => {
    await goTo(page, '/orders/sample-id/rate');
    await expectAppRendered(page);
  });

});
