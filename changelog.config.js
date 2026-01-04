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

module.exports = {
	disableEmoji: false,
	list: ['test', 'feat', 'fix', 'chore', 'docs', 'refactor', 'style', 'ci', 'perf'],
	maxMessageLength: 64,
	minMessageLength: 3,
	questions: ['type', 'scope', 'subject', 'body', 'breaking', 'issues', 'lerna'],
	scopes: [],
	types: {
		chore: {
			description: 'Build process or auxiliary tool changes',
			emoji: '🤖',
			value: 'chore',
		},
		ci: {
			description: 'CI related changes',
			emoji: '🎡',
			value: 'ci',
		},
		docs: {
			description: 'Documentation only changes',
			emoji: '✏️',
			value: 'docs',
		},
		feat: {
			description: 'A new feature',
			emoji: '🎸',
			value: 'feat',
		},
		fix: {
			description: 'A bug fix',
			emoji: '🐛',
			value: 'fix',
		},
		perf: {
			description: 'A code change that improves performance',
			emoji: '⚡️',
			value: 'perf',
		},
		refactor: {
			description: 'A code change that neither fixes a bug or adds a feature',
			emoji: '💡',
			value: 'refactor',
		},
		release: {
			description: 'Create a release commit',
			emoji: '🏹',
			value: 'release',
		},
		style: {
			description: 'Markup, white-space, formatting, missing semi-colons...',
			emoji: '💄',
			value: 'style',
		},
		test: {
			description: 'Adding missing tests',
			emoji: '💍',
			value: 'test',
		},
	},
};
