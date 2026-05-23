// @ts-check
const { test, expect } = require('@playwright/test');
const { goTo, expectAppRendered, screenshot } = require('./test-utils');

test.describe('Customer Browse', () => {

  test('home screen loads', async ({ page }) => {
    await goTo(page, '/home');
    await expectAppRendered(page);
    await screenshot(page, 'customer-home');
  });

  test('menu screen loads', async ({ page }) => {
    await goTo(page, '/menu');
    await expectAppRendered(page);
    await screenshot(page, 'customer-menu');
  });

  test('favorites screen loads', async ({ page }) => {
    await goTo(page, '/favorites');
    await expectAppRendered(page);
  });

  test('profile screen loads', async ({ page }) => {
    await goTo(page, '/profile');
    await expectAppRendered(page);
  });

  test('product detail screen loads', async ({ page }) => {
    await goTo(page, '/product/sample-id');
    await expectAppRendered(page);
  });

});
