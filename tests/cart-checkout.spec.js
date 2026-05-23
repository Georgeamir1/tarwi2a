// @ts-check
const { test, expect } = require('@playwright/test');
const { goTo, expectAppRendered, screenshot } = require('./test-utils');

test.describe('Cart & Checkout', () => {

  test('cart screen loads', async ({ page }) => {
    await goTo(page, '/cart');
    await expectAppRendered(page);
    await screenshot(page, 'cart');
  });

  test('empty cart screen loads', async ({ page }) => {
    await goTo(page, '/empty-cart');
    await expectAppRendered(page);
    await screenshot(page, 'cart-empty');
  });

  test('checkout screen loads', async ({ page }) => {
    await goTo(page, '/checkout');
    await expectAppRendered(page);
  });

  test('payment methods screen loads', async ({ page }) => {
    await goTo(page, '/checkout/payment');
    await expectAppRendered(page);
  });

  test('payment proof screen loads', async ({ page }) => {
    await goTo(page, '/checkout/payment-proof');
    await expectAppRendered(page);
  });

  test('order success screen loads', async ({ page }) => {
    await goTo(page, '/order-success');
    await expectAppRendered(page);
  });

});
