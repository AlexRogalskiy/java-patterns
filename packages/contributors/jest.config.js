// For a detailed explanation regarding each configuration property, visit:
// https://jestjs.io/docs/en/configuration.html
module.exports = {
  globals: {
    __BROWSER__: false,
    "ts-jest": {
      diagnostics: false,
      isolatedModules: true
    }
  },
  roots: ["<rootDir>/tests/"],
  verbose: true,
  clearMocks: true,
  restoreMocks: true,
  testTimeout: 20000,
  testSequencer: "<rootDir>/jest/jest-test-sequencer.js",
  globalSetup: "<rootDir>/jest/jest-global-setup.js",
  globalTeardown: "<rootDir>/jest/jest-global-teardown.js",
  setupFiles: [
    "<rootDir>/jest/jest-setup.js"
  ],
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
  testEnvironment: "node",
  testMatch: [
    "**/*.test.[jt]s?(x)",
    "**/__tests__/**/?(*.)+(spec|test).[jt]s?(x)"
  ],
  testRunner: "jest-circus/runner",
  testPathIgnorePatterns: [
    "<rootDir>/src.*",
    "<rootDir>/dist/",
    "<rootDir>/node_modules.*",
    "<rootDir>/__fixtures__.*",
    "<rootDir>/spec.*",
    "<rootDir>/mock.*"
  ],
  watchPathIgnorePatterns: [
    "<rootDir>/src.*",
    "<rootDir>/tsconfig.json"
  ],
  transform: {
    "^.+\\.(js|ts)$": "ts-jest",
    "^.+\\.html$": "<rootDir>/jest/transformers/jest-html-transform.js",
    "^.+\\.css$": "<rootDir>/jest/transformers/jest-css-transform.js",
  },
  snapshotSerializers: [
    "<rootDir>/node_modules/jest-html"
  ],
  projects: [
    {
      displayName: "unit",
      testMatch: [
        "**/tests/unit/**/__tests__/**/*.[jt]s",
        "**/tests/unit/**/*.{spec,test}.[jt]s"
      ],
      testPathIgnorePatterns: [
        "<rootDir>/tests/unit/mock*"
      ],
      transform: {
        "^.+\\.(js|ts)$": "ts-jest",
        "^.+\\.css$": "<rootDir>/jest/transformers/jest-css-transform.js",
      },
      collectCoverage: true,
      collectCoverageFrom: [
        "**/*.[jt]s?(x)",
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
      ]
    },
    {
      displayName: "e2e",
      testMatch: [
        "**/tests/e2e/**/__tests__/**/*.[jt]s",
        "**/tests/e2e/**/*.{spec,test}.[jt]s"
      ],
      testPathIgnorePatterns: [
        "<rootDir>/tests/e2e/mock*"
      ],
      transform: {
        "^.+\\.(js|ts)$": "ts-jest",
        "^.+\\.css$": "<rootDir>/jest/transformers/jest-css-transform.js",
      },
      collectCoverage: true,
      collectCoverageFrom: [
        "**/*.[jt]s?(x)",
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
      ]
    }
  ],
  transformIgnorePatterns: [
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
