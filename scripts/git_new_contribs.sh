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

# Usage example: /bin/sh ./scripts/git_new_contribs.sh

set -o errexit
set -o nounset
set -o pipefail

INITIAL_COMMIT=c01efc6
START_COMMIT=$(git log --before="$1" --author=bors --pretty=format:%H | head -n1)
ALL_NAMES=$(git log $INITIAL_COMMIT.. --pretty=format:%an | sort | uniq)
OLD_NAMES=$(git log $INITIAL_COMMIT..$START_COMMIT --pretty=format:%an | sort | uniq)
echo "$OLD_NAMES" >names_old.txt
echo "$ALL_NAMES" >names_all.txt
names=$(diff names_old.txt names_all.txt)
rm names_old.txt names_all.txt
names=$(echo "$names" | grep \> | sed 's/^>/*/')
echo "$names"
