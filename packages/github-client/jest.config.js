/*
 * Copyright (C) 2022 SensibleMetrics, Inc. (http://sensiblemetrics.io/)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

// For a detailed explanation regarding each configuration property, visit:
// https://jestjs.io/docs/en/configuration.html
module.exports = {
  globals: {
    '__BROWSER__': false,
    'ts-jest': {
      diagnostics: false,
      isolatedModules: true,
    },
  },
  roots: ['<rootDir>/tests/'],
  verbose: true,
  errorOnDeprecated: true,
  clearMocks: true,
  restoreMocks: true,
  testTimeout: 20000,
  slowTestThreshold: 40,
  testSequencer: '<rootDir>/jest/jest-test-sequencer.js',
  globalSetup: '<rootDir>/jest/jest-global-setup.js',
  globalTeardown: '<rootDir>/jest/jest-global-teardown.js',
  setupFiles: ['<rootDir>/jest/jest-setup.js'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  testEnvironment: 'node',
  testMatch: ['**/*.test.[jt]s?(x)', '**/__tests__/**/?(*.)+(spec|test).[jt]s?(x)'],
  testRunner: 'jest-circus/runner',
  testPathIgnorePatterns: [
    '<rootDir>/src.*',
    '<rootDir>/dist/',
    '<rootDir>/.cache/',
    '<rootDir>/node_modules.*',
    '<rootDir>/__fixtures__.*',
    '<rootDir>/spec.*',
    '<rootDir>/mock.*',
  ],
  watchPathIgnorePatterns: ['<rootDir>/src.*', '<rootDir>/tsconfig.json'],
  transform: {
    '^.+\\.(js|ts)$': 'ts-jest',
    '^.+\\.html$': '<rootDir>/jest/transformers/jest-html-transform.js',
    '^.+\\.css$': '<rootDir>/jest/transformers/jest-css-transform.js',
  },
  testEnvironmentOptions: {
    url: 'http://localhost',
  },
  projects: [
    {
      displayName: 'unit',
      testMatch: ['**/tests/unit/**/__tests__/**/*.[jt]s', '**/tests/unit/**/*.{spec,test}.[jt]s'],
      testPathIgnorePatterns: ['<rootDir>/tests/unit/mock*'],
      transform: {
        '^.+\\.(js|ts)$': 'ts-jest',
        '^.+\\.css$': '<rootDir>/jest/transformers/jest-css-transform.js',
      },
      collectCoverage: true,
      collectCoverageFrom: [
        '**/*.[jt]s?(x)',
        '!**/*.d.ts',
        '!**/*.folio.ts',
        '!**/*.spec.ts',
        '!**/dist/**',
        '!**/node_modules/**',
        '!**/vendor/**',
        '!**/generated/**',
        '!**/__fixtures__/**',
        '!**/scenarios/**',
        '!**/redirects/**',
      ],
      coveragePathIgnorePatterns: ['<rootDir>/node_modules/'],
      coverageThreshold: {
        global: {
          branches: 4,
          functions: 4,
          lines: 4,
          statements: 4,
        },
      },
      coverageDirectory: '<rootDir>/coverage',
      testResultsProcessor: 'jest-sonar-reporter',
      coverageReporters: ['json', 'lcov', 'text', 'clover', 'html'],
    },
    {
      displayName: 'e2e',
      testMatch: ['**/tests/e2e/**/__tests__/**/*.[jt]s', '**/tests/e2e/**/*.{spec,test}.[jt]s'],
      testPathIgnorePatterns: ['<rootDir>/tests/e2e/mock*'],
      transform: {
        '^.+\\.(js|ts)$': 'ts-jest',
        '^.+\\.css$': '<rootDir>/jest/transformers/jest-css-transform.js',
      },
      collectCoverage: true,
      collectCoverageFrom: [
        '**/*.[jt]s?(x)',
        '!**/*.d.ts',
        '!**/*.folio.ts',
        '!**/*.spec.ts',
        '!**/dist/**',
        '!**/node_modules/**',
        '!**/vendor/**',
        '!**/generated/**',
        '!**/__fixtures__/**',
        '!**/scenarios/**',
        '!**/redirects/**',
      ],
      coveragePathIgnorePatterns: ['<rootDir>/node_modules/'],
      coverageThreshold: {
        global: {
          branches: 4,
          functions: 4,
          lines: 4,
          statements: 4,
        },
      },
      coverageDirectory: '<rootDir>/coverage',
      testResultsProcessor: 'jest-sonar-reporter',
      coverageReporters: ['json', 'lcov', 'text', 'clover', 'html'],
    },
  ],
  transformIgnorePatterns: ['<rootDir>/node_modules/'],
  reporters: [
    'default',
    '<rootDir>/jest/reporters/json-reporter',
    [
      'jest-junit',
      {
        usePathForSuiteName: true,
        suiteName: 'jest tests',
        suiteNameTemplate: '{filename}',
        outputName: 'coverage/jest-junit/junit.xml',
        classNameTemplate: '{classname}-{title}',
        titleTemplate: '{classname} - {title}',
        ancestorSeparator: ' › ',
      },
    ],
  ],
  setupFilesAfterEnv: ['<rootDir>/jest/jest-env-setup.js', 'jest-extended-snapshot', 'jest-expect-message'],
  moduleNameMapper: {
    '.+\\.(css|styl|less|sass|scss)$': 'identity-obj-proxy',
    '.+\\.(ico|jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$':
      '<rootDir>/jest/mocks/jest-file-mock.js',
  },
  watchPlugins: [
    'jest-watch-select-projects',
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname',
  ],
};
