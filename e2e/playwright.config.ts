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
    // Registers one user through the UI (the API allows 3 registrations per IP per hour) and saves the session.
    { name: 'setup', testMatch: /auth\.setup\.ts/, use: { ...devices['Desktop Chrome'] } },
    {
      name: 'chromium',
      dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], storageState: '.auth/user.json' },
    },
  ],
});
