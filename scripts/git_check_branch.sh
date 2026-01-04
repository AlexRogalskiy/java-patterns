#!/usr/bin/env bash
# Copyright (C) 2022 SensibleMetrics, Inc. (http://sensiblemetrics.io/)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Usage example: /bin/sh ./scripts/git_check_branch.sh

set -o errexit
set -o nounset
set -o pipefail

# First fetch to ensure git is up to date. Fail-fast if this fails.
if  git fetch; then exit 1; fi;

# Extract useful information.
GIT_BRANCH=$(git branch -v 2> /dev/null | sed '/^[^*]/d');
# shellcheck disable=SC2001
GIT_BRANCH_NAME=$(echo "$GIT_BRANCH" | sed 's/* \([A-Za-z0-9_\-]*\).*/\1/');
# shellcheck disable=SC2001
GIT_BRANCH_SYNC=$(echo "$GIT_BRANCH" | sed 's/* [^[]*.\([^]]*\).*/\1/');

# Check if master is checked out
if [ "$GIT_BRANCH_NAME" != "master" ]; then
  read -pr "Git not on master but $GIT_BRANCH_NAME. Continue? (y|N) " yn;
  if [ "$yn" != "y" ]; then exit 1; fi;
fi;

# Check if branch is synced with remote
if [ "$GIT_BRANCH_SYNC" != "" ]; then
  read -pr "Git not up to date but $GIT_BRANCH_SYNC. Continue? (y|N) " yn;
  if [ "$yn" != "y" ]; then exit 1; fi;
fi;
