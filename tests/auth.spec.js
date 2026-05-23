// @ts-check
const { test, expect } = require('@playwright/test');
const { goTo, expectAppRendered, expectPath, screenshot } = require('./test-utils');

test.describe('Auth Flow', () => {

  test('splash redirects to onboarding when unauthenticated', async ({ page }) => {
    await goTo(page, '/');
    await expectAppRendered(page);
    // Splash waits 2s then checks auth → redirects to onboarding
    await page.waitForTimeout(6000);
    await expect(page).toHaveURL(/\/onboarding/);
  });

  test('login screen loads and renders', async ({ page }) => {
    await goTo(page, '/login');
    await expectAppRendered(page);
    await screenshot(page, 'auth-login');
  });

  test('register screen loads', async ({ page }) => {
    await goTo(page, '/register');
    await expectAppRendered(page);
    await screenshot(page, 'auth-register');
  });

  test('forgot password screen loads', async ({ page }) => {
    await goTo(page, '/forgot-password');
    await expectAppRendered(page);
    await screenshot(page, 'auth-forgot-password');
  });

  test('OTP screen loads', async ({ page }) => {
    await goTo(page, '/otp');
    await expectAppRendered(page);
  });

  test('onboarding screen loads', async ({ page }) => {
    await goTo(page, '/onboarding');
    await expectAppRendered(page);
  });

});
