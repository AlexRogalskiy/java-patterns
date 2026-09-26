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

const TestSequencer = require('@jest/test-sequencer').default;

class CustomSequencer extends TestSequencer {
	sort(tests) {
		const orderPath = ['unit', 'e2e'];
		return tests.sort((testA, testB) => {
			let indexA = -1;
			let indexB = -1;
			const reg = '.*/tests/([^/]*).*';

			let matchA = new RegExp(reg, 'g').exec(testA.path);
			if (matchA.length > 0) {
				indexA = orderPath.indexOf(matchA[1]);
			}

			let matchB = new RegExp(reg, 'g').exec(testB.path);
			if (matchB.length > 0) {
				indexB = orderPath.indexOf(matchB[1]);
			}

			if (indexA === indexB) {
				return 0;
			}

			if (indexA === -1) {
				return 1;
			}
			if (indexB === -1) {
				return -1;
			}

			return indexA < indexB ? -1 : 1;
		});
	}
}

module.exports = CustomSequencer;
