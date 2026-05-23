// @ts-check
import { defineConfig, devices } from '@playwright/test';

const FLUTTER_BASE_URL = 'http://localhost:8080';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : 1,
  timeout: 120000,
  expect: { timeout: 15000 },
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['list'],
  ],
  use: {
    baseURL: FLUTTER_BASE_URL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 720 } },
    },
  ],
  webServer: process.env.CI ? [] : [
    {
      command: 'flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0',
      url: FLUTTER_BASE_URL,
      reuseExistingServer: !process.env.CI,
      timeout: 180000,
    },
  ],
});
