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

import '@testing-library/jest-dom';
import 'jest-extended';
import * as jest from 'jest';
import * as matchers from 'jest-extended/dist/matchers';
import * as superMatchers from 'jest-supertest-matchers';
import * as MockDate from 'mockdate';

beforeAll(() => {
	jest.setTimeout(60000);
	jest.expect.extend(matchers);
	jest.expect.extend(superMatchers);
});

beforeEach(() => {
	jest.clearAllMocks();

	global.fetch.resetMocks();

	// mock for resize-observer
	global.ResizeObserver = jest.fn().mockImplementation(() => {
		return {
			observe: jest.fn(),
			unobserve: jest.fn(),
		};
	});

	global.console.error = error => {
		throw new Error(error);
	};

	MockDate.set('2007-09-02');
});

afterEach(() => {
	MockDate.reset();
});

module.exports = async () => {
	process.env.TZ = 'UTC';
};
