#!/usr/bin/env node
// Copyright (C) 2022 SensibleMetrics, Inc. (http://sensiblemetrics.io/)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Validates the commit message.
// Used by the commit-msg hook

/* eslint-env node, es6 */
/* eslint-disable func-style */
/* eslint-disable no-confusing-arrow */
/* eslint-disable no-console */
/* eslint-disable no-process-exit */

'use strict';

// Add validation functions here.
import fs from "fs";

const validators = [
  msg => msg.indexOf('Fixes') >= 0 ? 'Use past tense (Fixed, not Fixes)' : 0,
  msg => msg[0].toUpperCase() !== msg[0] ? 'First letter should be caps' : 0,
  msg => msg.split('\n')[0].length > 72 ?
    `First line of the commit message should not exceed 72 characters (currently ${msg.split('\n')[0].length})` :
    0
];

const args = process.argv;
if (args.length < 3) {
  // This is not ran correctly
  console.error('Expected commit message link, unable to validate');
  console.info('Received: ', args.join(', '));
  process.exit(1);
}

// Get the commit message
fs.readFile(args[2], 'utf8', (err, commitMessage) => {
  if (err) {
    return console.log(err.red) && process.exit(1);
  }

  // Do validation of commitMessage
  const errors = [];

  validators.forEach(fn => {
    const res = fn(commitMessage);
    if (res !== 0) {
      errors.push(res);
    }
  });

  if (errors.length) {
    console.log('Commit message does not follow spec:');
    errors.forEach(msg => console.log('  ' + msg.red));
    return process.exit(1);
  }

  console.log('Commit message is OK, proceeding.'.green);

  // All is a-ok
  return process.exit(0);
});
