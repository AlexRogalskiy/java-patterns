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

/* eslint-disable import/no-commonjs */
const textlintMode = process.env.TEXTLINT_MODE;

const allRules = {
	'alex': {
		allow: ['color', 'hook', 'host-hostess', 'itch'],
	},
	'common-misspellings': true,
	'en-capitalization': false,
	'stop-words': {
		exclude: [
			'relative to', // We need to talk about links "relative to the root",
			'pick out', // Needed word, not to clumsy
			'encounter', // Needed word, not to clumsy
			'proceed',
			'therefore',
			'this command',
			'Failure to',
			'frequently',
			'ALL of',
			'in addition to',
			'in addition',
			'Take a look at',
			'In addition to',
			'In addition',
			'simply',
			'deem',
		],
	},
	'terminology': {
		defaultTerms: false,
		terms: `${__dirname}/.textlint.terms.json`,
	},
	'write-good': {
		passive: true,
		severity: 'warning',
	},
};

// Not all rules are automatically fixable, so when running `yarn run
// lint:md:fix`, we only run the one that can be fixed.
const fixableRules = {
	'common-misspellings': allRules['common-misspellings'],
	'en-capitalization': allRules['en-capitalization'],
	'terminology': allRules['terminology'],
};

module.exports = {
	rules: textlintMode === 'fix' ? fixableRules : allRules,
};
