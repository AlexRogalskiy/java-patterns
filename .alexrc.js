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

exports.allow = [
	// We frequently refer to form props by their name "disabled".
	// Ideally we would alex-ignore only the valid uses (PRs accepted).
	'invalid',

	// Unfortunately "watchman" is a library name that we depend on.
	'watchman-watchwoman',

	// ignore rehab rule, Detox is an e2e testing library
	'rehab',
];

// Use a "maybe" level of profanity instead of the default "unlikely".
exports.profanitySureness = 1;
