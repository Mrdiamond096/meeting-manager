import { expect, test } from '@playwright/test';
import { OTP, user } from './user';

/** Tomorrow as YYYY-MM-DD in the browser's zone (playwright.config: Asia/Bangkok), so the meeting is upcoming. */
const tomorrow = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Bangkok' }).format(Date.now() + 24 * 3600_000);
/** The week view labels each day column with its full date. */
const dayLabel = new Intl.DateTimeFormat('en-US', { dateStyle: 'full', timeZone: 'UTC' }).format(new Date(`${tomorrow}T12:00:00Z`));
const candidate = `E2E Candidate ${process.env.E2E_RUN_ID}`;

test.describe('signed out', () => {
  test.use({ storageState: { cookies: [], origins: [] } });

  test('a private page redirects to login', async ({ page }) => {
    await page.goto('/meetings/new');
    await expect(page).toHaveURL(/\/login\?next=%2Fmeetings%2Fnew/);
    await expect(page.getByRole('button', { name: 'Log in' })).toBeVisible();
  });

  test('log in with password and OTP returns to the dashboard', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('Email').fill(user.email);
    await page.getByLabel('Password').fill(user.password);
    await page.getByRole('button', { name: 'Log in' }).click();
    await expect(page).toHaveURL(/\/verify\?/);
    await page.getByLabel('Verification code digit 1').fill(OTP);
    await page.getByRole('button', { name: 'Verify' }).click();
    await expect(page.getByRole('heading', { name: 'Upcoming Meetings', exact: true })).toBeVisible();
  });
});

test.describe.serial('meeting life cycle', () => {
  test('book a meeting with a new candidate from a calendar slot', async ({ page }) => {
    await page.goto(`/?view=calendar&date=${tomorrow}`);
    // Empty grid at 10:00 (48px per hour) opens the form with that slot filled in.
    await page.getByRole('list', { name: dayLabel, exact: true }).click({ position: { x: 20, y: 10 * 48 + 10 } });
    await expect(page).toHaveURL(new RegExp(`/meetings/new\\?date=${tomorrow}&start=10:00`));
    await expect(page.getByLabel('Date', { exact: true })).toHaveValue(tomorrow);
    await expect(page.getByLabel('Start time', { exact: true })).toHaveValue('10:00');

    await page.getByLabel('Candidate (optional)', { exact: true }).fill(candidate);
    await page.getByRole('option', { name: `Create new candidate “${candidate}”` }).click();
    await page.getByLabel('Position', { exact: true }).selectOption('QA Engineer');
    await expect(page.getByLabel('Title', { exact: true })).toHaveValue(`Interview: ${candidate}`);
    await page.getByRole('button', { name: 'Book meeting' }).click();

    await expect(page.getByText('Meeting booked')).toBeVisible();
    await expect(page.getByRole('heading', { name: 'Upcoming Meetings', exact: true })).toBeVisible();
    await expect(page.getByText(candidate).first()).toBeVisible();
  });

  test('find it in the calendar, open its summary and cancel it', async ({ page }) => {
    await page.goto(`/?view=calendar&date=${tomorrow}`);
    await page.getByRole('button', { name: new RegExp(`^${candidate}, 10:00 AM`) }).click();
    await page.getByRole('dialog', { name: candidate }).getByRole('link', { name: 'View details' }).click();

    await expect(page.getByRole('heading', { name: candidate })).toBeVisible();
    await page.getByRole('button', { name: 'Cancel meeting' }).click();
    await page.getByRole('dialog', { name: 'Cancel this meeting?' }).getByRole('button', { name: 'Cancel meeting' }).click();
    await expect(page.getByText('Meeting cancelled')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Cancel meeting' })).toHaveCount(0);
  });
});
