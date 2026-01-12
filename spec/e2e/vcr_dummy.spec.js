const { test, expect } = require('@playwright/test');

test('counter increments, decrements, and resets', async ({ page }) => {
  await page.goto('/');

  const first = page.locator('section').first();
  const count = first.getByTestId('count');
  const updated = first.getByTestId('last-updated');

  await expect(updated).toHaveText('-');
  await expect(count).toHaveText('0');

  await first.getByRole('button', { name: '+' }).click();
  await expect(count).toHaveText('1');
  await expect(updated).not.toHaveText('-');

  await first.getByRole('button', { name: '-' }).click();
  await expect(count).toHaveText('0');
  await expect(updated).not.toHaveText('-');

  await first.getByRole('button', { name: 'reset' }).click();
  await expect(count).toHaveText('0');
  await expect(updated).not.toHaveText('-');
});

test('two counters update independently', async ({ page }) => {
  await page.goto('/two_counters');

  const first = page.locator('section').nth(0);
  const second = page.locator('section').nth(1);
  const firstCount = first.getByTestId('count');
  const secondCount = second.getByTestId('count');

  await expect(firstCount).toHaveText('0');
  await expect(secondCount).toHaveText('0');

  await second.getByRole('button', { name: '+' }).click();

  await expect(firstCount).toHaveText('0');
  await expect(secondCount).toHaveText('1');
});
