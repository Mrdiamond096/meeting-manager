import { expect, test as setup } from '@playwright/test';
import { OTP, user } from './user';

setup('register, verify the email with the OTP and land on the dashboard', async ({ page }) => {
  await page.goto('/register');
  await page.getByLabel('Email').fill(user.email);
  await page.getByLabel('Password', { exact: true }).fill(user.password);
  await page.getByLabel('Confirm password').fill(user.password);
  await page.getByRole('button', { name: 'Create account' }).click();

  await expect(page).toHaveURL(/\/verify\?/);
  // A full code typed into the first box fills all six (the autofill path).
  await page.getByLabel('Verification code digit 1').fill(OTP);
  await page.getByRole('button', { name: 'Verify' }).click();

  await expect(page.getByRole('heading', { name: 'Upcoming Meetings', exact: true })).toBeVisible();
  await page.context().storageState({ path: '.auth/user.json' });
});
