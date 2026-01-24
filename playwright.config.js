const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './spec/e2e',
  timeout: 60_000,
  use: {
    baseURL: 'http://localhost:3001',
    headless: true
  },
  webServer: {
    command: 'sh -c "redis-server --daemonize yes || true; RAILS_ENV=test bin/rails server -b 127.0.0.1 -p 3001"',
    cwd: 'spec/dummy',
    url: 'http://127.0.0.1:3001',
    reuseExistingServer: true
  }
});
