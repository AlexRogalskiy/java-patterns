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

# Usage example: /bin/sh ./scripts/git_changelog_md.sh

set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")/.." || exit 1

VERSION=$(grep 'version:' package.json | sed -E "s/.*'([^']*)'/\1/")
RELEASE_DATE=$(date "+%Y-%m-%d")

# compile a list of already reported PRs
reported="$(mktemp)"
grep -E "#[0-9]{4}" -o CHANGELOG.md | sort >"$reported"

echo "[$VERSION] - $RELEASE_DATE"

echo "--------------------"
echo '##### Enhancements'
echo "--------------------"
git log stable..master --first-parent --format='%s %b' |
sed -E 's/.*#([0-9]+).*\[ENH\] *(.*)/\* \2 ([#\1](\.\.\/\.\.\/pull\/\1))/' |
grep -E '^\*' | grep -v -F -f "$reported"

echo "--------------------"
echo "##### Bugfixes"
echo "--------------------"
git log stable..master --first-parent --format='%s %b' |
sed -E 's/.*#([0-9]+).*\[FIX\] *(.*)/\* \2 ([#\1](\.\.\/\.\.\/pull\/\1))/' |
grep -E '^\*' | grep -v -F -f "$reported"
echo "--------------------"
