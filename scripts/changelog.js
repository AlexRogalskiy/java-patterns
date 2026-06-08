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

import tempy from "tempy";
import {EOL} from "os";
import shell from "shelljs";

shell.config.silent = true;
const F = 'docs/CHANGELOG.md';
const P = EOL + EOL;

const CURRENT_TAG = shell
  .exec('git tag --sort=v:refname')
  .tail({'-n': 1})
  .stdout.trim();

const PREVIOUS_TAG = shell
  .exec('git tag --sort=v:refname')
  .tail({'-n': 2})
  .head({'-n': 1})
  .stdout.trim();

/** This is a “major” release if the version is 0.x.0 or x.0.0 */
const IS_MAJOR = /^v?(0\.\d+\.0|\d+.0.0)$/.test(CURRENT_TAG);

const FILE = tempy.file();

/** Tests for a `feat` commit type. */
const isFeature = (s) => /feat(\([^)]+\))?:/.test(s);
/** Tests for commit types that don’t need adding to the CHANGELOG (like `docs` or `chore`). */
const isUninformative = (s) =>
  /(test|style|chore|docs|ci)(\([\w-]+\))?:/.test(s);
/** Tests if this commit just bumped the version (via `npm version`). */
const isVersionBump = (s) => /^\w+\s\d+\.\d+\.\d+$/.test(s);

const changes = shell
  .exec(`git log --oneline "${PREVIOUS_TAG}"..`)
  .split(EOL)
  .filter((line) => !isUninformative(line) && !isVersionBump(line));

/**
 * Format an array of commit details and concatenate into a string.
 * @param {string[]} changes
 */
const formatChanges = (changes) =>
  changes
    .map((line) =>
      line
        // Strip standalone commit types ('feat:', 'fix:', etc.)
        .replace(/[a-z]+: /, '')
        // Format scoped commit types ('feat(foo):' => 'foo:', etc.)
        .replace(/[a-z]+\(([^)]+)\)/, '$1')
        // Linkify commit refs.
        .replace(
          /^(\w+)/,
          '* [[$1](https://github.com/boardgameio/boardgame.io/commit/$1)]'
        )
        // Linkify PR references.
        .replace(
          /\(#(\d{3,})\)/,
          '([#$1](https://github.com/boardgameio/boardgame.io/pull/$1))'
        )
    )
    .join(EOL);

const features = formatChanges(changes.filter((line) => isFeature(line)));
const others = formatChanges(changes.filter((line) => !isFeature(line)));

let NOTES = (IS_MAJOR ? '## ' : '### ') + CURRENT_TAG + P;
if (features.length > 0) {
  NOTES += '#### Features' + P + features + P;
}
if (others.length > 0) {
  NOTES += '#### Bugfixes' + P + others + P;
}

shell.rm(F);

shell.ShellString(NOTES).toEnd(FILE);
shell.echo(NOTES);

shell.cat(F).toEnd(FILE);
shell.cp(FILE, F);
