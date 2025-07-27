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

/*
 |--------------------------------------------------------------------------
 | Browser-sync config file
 |--------------------------------------------------------------------------
 |
 | For up-to-date information about the options:
 |   http://www.browsersync.io/docs/options/
 |
 | There are more options than you see here, these are just the ones that are
 | set internally. See the website for more info.
 |
 |
 */
module.exports = {
	ui: {
		port: 3001,
	},
	files: true,
	watchEvents: ['change'],
	watch: true,
	ignore: [],
	single: false,
	watchOptions: {
		ignoreInitial: true,
	},
	server: true,
	proxy: false,
	port: 3000,
	middleware: false,
	serveStatic: [],
	ghostMode: {
		clicks: true,
		scroll: true,
		location: true,
		forms: {
			submit: true,
			inputs: true,
			toggles: true,
		},
	},
	logLevel: 'info',
	logPrefix: 'Browsersync',
	logConnections: false,
	logFileChanges: true,
	logSnippet: true,
	rewriteRules: [],
	open: 'local',
	browser: 'default',
	cors: false,
	xip: false,
	hostnameSuffix: false,
	reloadOnRestart: false,
	notify: true,
	scrollProportionally: true,
	scrollThrottle: 0,
	scrollRestoreTechnique: 'window.name',
	scrollElements: [],
	scrollElementMapping: [],
	reloadDelay: 0,
	reloadDebounce: 500,
	reloadThrottle: 0,
	plugins: [],
	injectChanges: true,
	startPath: null,
	minify: true,
	host: null,
	localOnly: false,
	codeSync: true,
	timestamps: true,
	clientEvents: [
		'scroll',
		'scroll:element',
		'input:text',
		'input:toggles',
		'form:submit',
		'form:reset',
		'click',
	],
	socket: {
		socketIoOptions: {
			log: false,
		},
		socketIoClientConfig: {
			reconnectionAttempts: 50,
		},
		path: '/browser-sync/socket.io',
		clientPath: '/browser-sync',
		namespace: '/browser-sync',
		clients: {
			heartbeatTimeout: 5000,
		},
	},
	tagNames: {
		less: 'link',
		scss: 'link',
		css: 'link',
		jpg: 'img',
		jpeg: 'img',
		png: 'img',
		svg: 'img',
		gif: 'img',
		js: 'script',
	},
	injectNotification: false,
};
