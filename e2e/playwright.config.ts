import { defineConfig, devices } from '@playwright/test';

/** Smoke tests against a running full stack (`make up`, mock OTP). E2E_BASE_URL defaults to the compose web port. */
// One id for the whole run: workers inherit it, so setup and tests share the registered user.
process.env.E2E_RUN_ID ??= String(Date.now());

export default defineConfig({
  testDir: './tests',
  fullyParallel: false,
  workers: 1,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? [['list'], ['html', { open: 'never' }]] : 'list',
  use: {
    baseURL: process.env.E2E_BASE_URL ?? 'http://localhost:8080',
    locale: 'en-US',
    timezoneId: 'Asia/Bangkok',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [
    // Registers one user through the UI and saves the session. One per run keeps it within the API's register limit
    // (3 per IP per hour, ADR-013) for when that limit is on; it is switched off for the demo (backend auth/router.ts).
    { name: 'setup', testMatch: /auth\.setup\.ts/, use: { ...devices['Desktop Chrome'] } },
    {
      name: 'chromium',
      dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], storageState: '.auth/user.json' },
    },
  ],
});
