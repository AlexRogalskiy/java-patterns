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

# Usage example: /bin/sh ./scripts/git_blame.sh $FILE

set -o errexit
set -o nounset
set -o pipefail

repo_root=$(git rev-parse --show-toplevel)
if [[ -e $repo_root/.git-blame-ignore-revs ]]; then
  git blame --ignore-revs-file="$repo_root/.git-blame-ignore-revs" "$@"
else
  git blame "$@"
fi
