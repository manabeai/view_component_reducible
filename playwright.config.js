const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './spec/e2e',
  timeout: 60_000,
  use: {
    baseURL: 'http://localhost:3000',
    headless: true
  },
  webServer: {
    command: 'RAILS_ENV=test bin/rails server -p 3000',
    cwd: 'spec/dummy',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI
  }
});
