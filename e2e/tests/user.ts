/** One user per run, shared by the setup and the login test. */
export const user = {
  email: `e2e-${process.env.E2E_RUN_ID ?? Date.now()}@example.com`,
  password: 'e2e-password-123',
};
export const OTP = process.env.E2E_OTP ?? '112233';
