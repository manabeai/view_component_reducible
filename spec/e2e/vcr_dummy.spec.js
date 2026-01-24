const { test, expect } = require('@playwright/test');

const TIME_OPTIONS = [
  '09:00',
  '10:00',
  '11:00',
  '12:00',
  '13:00',
  '14:00',
  '15:00',
  '16:00',
  '17:00',
  '18:00'
];

const STAFF_OPTIONS = ['Aki', 'Mika', 'Sora'];

const expectedTimeCount = (day) => (day % 6) + 1;

const expectedStaffCount = (timeLabel) => {
  const minCount = Math.min(2, STAFF_OPTIONS.length);
  const range = STAFF_OPTIONS.length - minCount;
  const seed = Buffer.from(timeLabel, 'utf8').reduce((sum, b) => sum + b, 0);
  return minCount + (range === 0 ? 0 : seed % (range + 1));
};

test('counter increments, decrements, and resets', async ({ page }) => {
  // 初期表示を開く
  await page.goto('/');

  // 最初のカウンター領域と表示ラベルを取得
  const first = page.locator('section').first();
  const count = first.getByTestId('count');
  const updated = first.getByTestId('last-updated');

  // 初期値の確認
  await expect(updated).toHaveText('-');
  await expect(count).toHaveText('0');

  // インクリメント操作
  await first.getByRole('button', { name: '+' }).click();
  await expect(count).toHaveText('1');
  await expect(updated).not.toHaveText('-');

  // デクリメント操作
  await first.getByRole('button', { name: '-' }).click();
  await expect(count).toHaveText('0');
  await expect(updated).not.toHaveText('-');

  // リセット操作
  await first.getByRole('button', { name: 'reset' }).click();
  await expect(count).toHaveText('0');
  await expect(updated).not.toHaveText('-');
});

test('two counters update independently', async ({ page }) => {
  // 2つのカウンター画面へ遷移
  await page.goto('/two_counters');

  // それぞれのカウンターを取得
  const first = page.locator('section').nth(0);
  const second = page.locator('section').nth(1);
  const firstCount = first.getByTestId('count');
  const secondCount = second.getByTestId('count');

  // 初期値の確認
  await expect(firstCount).toHaveText('0');
  await expect(secondCount).toHaveText('0');

  // 片方だけを更新
  await second.getByRole('button', { name: '+' }).click();

  // 独立して更新されることを確認
  await expect(firstCount).toHaveText('0');
  await expect(secondCount).toHaveText('1');
});

test('booking flow reveals times and staff', async ({ page }) => {
  // 予約フロー画面へ遷移
  await page.goto('/effects');

  // 右側のサマリが初期表示で未選択になっていることを確認
  await expect(page.getByTestId('booking-summary')).toBeVisible();
  await expect(page.getByTestId('selected-day')).toHaveText('未選択');
  await expect(page.getByTestId('selected-time')).toHaveText('未選択');
  await expect(page.getByTestId('selected-staff')).toHaveText('未選択');

  // 日付を選択して時間一覧を出す
  const selectedDay = 15;
  await page.getByTestId(`day-${selectedDay}`).click();
  await expect(page.getByTestId('selected-day')).toHaveText('2024年3月15日');
  const timeButtons = page.locator('[data-testid^="time-"]');
  await expect(timeButtons.first()).toBeVisible();
  // 時間の件数がモック仕様通りであることを確認
  const timeCount = await timeButtons.count();
  expect(timeCount).toBe(expectedTimeCount(selectedDay));

  // 時間を選択してスタッフ一覧を出す
  const selectedTime = await timeButtons.first().innerText();
  await timeButtons.first().click();
  await expect(page.getByTestId('selected-time')).toHaveText(selectedTime);
  await expect(page.getByTestId('staff-list')).toBeVisible();
  // 初期状態では予約ボタンが出ないことを確認
  await expect(page.getByTestId('booking-button')).toHaveCount(0);
  // スタッフ候補を取得
  const staffButtons = page.locator('button[data-testid^="staff-"]');
  await expect(staffButtons.first()).toBeVisible();
  // スタッフ人数が複数であることを確認
  const staffCount = await staffButtons.count();
  expect(staffCount).toBe(expectedStaffCount(selectedTime));
  // スタッフを選択して予約ボタンを表示
  const selectedStaff = await staffButtons.first().innerText();
  await staffButtons.first().click();
  await expect(staffButtons.first()).toHaveAttribute('aria-pressed', 'true');
  await expect(page.getByTestId('selected-staff')).toHaveText(selectedStaff);
  await expect(page.getByTestId('booking-button')).toBeVisible();

  // 日付を選び直すとスタッフと時間がリセットされることを確認
  await page.getByTestId('day-16').click();
  await expect(page.getByTestId('selected-day')).toHaveText('2024年3月16日');
  await expect(page.getByTestId('selected-time')).toHaveText('未選択');
  await expect(page.getByTestId('selected-staff')).toHaveText('未選択');
  await expect(page.getByTestId('booking-button')).toHaveCount(0);
});
