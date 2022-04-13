// For a detailed explanation regarding each configuration property, visit:
// https://jestjs.io/docs/en/configuration.html
module.exports = {
  globals: {
    __BROWSER__: false,
    "ts-jest": {
      diagnostics: false,
      isolatedModules: "true"
    }
  },
  roots: ["<rootDir>/tests/"],
  verbose: true,
  clearMocks: true,
  restoreMocks: true,
  globalSetup: "<rootDir>/jest/jest-global-setup.js",
  globalTeardown: "<rootDir>/jest/jest-global-teardown.js",
  setupFiles: [
    "<rootDir>/jest/jest-setup.js"
  ],
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
  testEnvironment: "node",
  testMatch: ["**/*.test.(ts|js)", "**/__tests__/**/?(*.)+(spec|test).(ts|js)"],
  testRunner: "jest-circus/runner",
  testPathIgnorePatterns: [
    "<rootDir>/src.*",
    "<rootDir>/node_modules.*",
    "<rootDir>/__fixtures__.*",
    "<rootDir>/spec.*"
  ],
  watchPathIgnorePatterns: [
    "<rootDir>/src.*",
    "<rootDir>/tsconfig.json"
  ],
  transform: {
    "^.+\\.(js|ts)$": "ts-jest"
  },
  snapshotSerializers: [
    "<rootDir>/node_modules/jest-html"
  ],
  collectCoverage: true,
  collectCoverageFrom: [
    "**/*.(ts|js)",
    "!**/*.d.ts",
    "!**/*.folio.ts",
    "!**/*.spec.ts",
    "!**/dist/**",
    "!**/node_modules/**",
    "!**/vendor/**",
    "!**/generated/**",
    "!**/__fixtures__/**",
    "!**/scenarios/**",
    "!**/redirects/**",
  ],
  coveragePathIgnorePatterns: [
    "<rootDir>/node_modules/"
  ],
  coverageThreshold: {
    global: {
      branches: 4,
      functions: 4,
      lines: 4,
      statements: 4,
    },
  },
  coverageDirectory: "<rootDir>/coverage",
  testResultsProcessor: "jest-sonar-reporter",
  coverageReporters: [
    "json",
    "lcov",
    "text",
    "clover",
    "html"
  ],
  "transformIgnorePatterns": [
    "<rootDir>/node_modules/"
  ],
  reporters: [
    "default",
    "<rootDir>/node_modules/jest-fail-on-console-reporter",
    "<rootDir>/jest/reporters/json-reporter",
    ["jest-junit", {
      usePathForSuiteName: true,
      suiteNameTemplate: "{filename}",
      outputName: "coverage/jest-junit/junit.xml",
      titleTemplate: "{classname} - {title}",
      ancestorSeparator: " - "
    }]
  ],
  setupFilesAfterEnv: [
    "<rootDir>/jest/jest-env-setup.js"
  ],
  moduleNameMapper: {
    '\\.(css|less|sass|scss)$': 'identity-obj-proxy',
    '\\.(gif|ttf|eot|svg|png)$': '<rootDir>/jest/mocks/jest-file-mock.js',
  },
  watchPlugins: [
    "jest-watch-select-projects",
    "jest-watch-typeahead/filename",
    "jest-watch-typeahead/testname"
  ]
}
