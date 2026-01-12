const { test, expect } = require('@playwright/test');

test('counter increments, decrements, and resets', async ({ page }) => {
  await page.goto('/');

  const count = page.getByTestId('count');
  const updated = page.getByTestId('last-updated');

  await expect(updated).toHaveText('-');
  await expect(count).toHaveText('0');

  await page.getByRole('button', { name: '+' }).click();
  await expect(count).toHaveText('1');
  await expect(updated).not.toHaveText('-');

  await page.getByRole('button', { name: '-' }).click();
  await expect(count).toHaveText('0');
  await expect(updated).not.toHaveText('-');

  await page.getByRole('button', { name: 'reset' }).click();
  await expect(count).toHaveText('0');
  await expect(updated).not.toHaveText('-');
});
