module.exports = {
  launch: {
    headless: process.env.HEADLESS !== 'false',
    slowMo: process.env.SLOWMO ? process.env.SLOWMO : 0,
    devtools: false
  },
  server: {
    command: 'npm run test:e2e',
    port: 8080,
    usedPortAction: 'kill',
    launchTimeout: 60000,
    waitOnScheme: {
      delay: 50000
    }
  }
};
