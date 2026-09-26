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

# Usage example: /bin/sh ./scripts/git_changelog.sh

set -o errexit
set -o nounset
set -o pipefail

_exit() {
  (($# > 1)) && echo "${@:2}"
  exit "$1"
}

main() {
  FILE=$(mktemp)
  TAG_CURRENT=$(git describe --abbrev=0)
  {
    printf '# Release: '%s'\n' "$TAG_CURRENT"
    git log "$TAG_CURRENT"...HEAD --pretty=format:"* %s";
    printf "%s" "\n\n---\n";
    cat CHANGELOG.md

  } >> "$FILE"

  cp "$FILE" CHANGELOG.md
  rm "$FILE"
}

main "$@"
