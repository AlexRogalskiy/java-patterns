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

# Usage example: /bin/sh ./scripts/show_changelog.sh CHANGELOG.md

set -o errexit
set -o nounset
set -o pipefail

throw() {
  echo "$@" 1>&2
  exit 1
}

get_changelog() {
  changelog=""
  has_start_line=0
  while read -r line; do
    if [[ $has_start_line -eq 0 ]]; then
      # If we do not have a starting line, look for one.
      if [[ "$line" =~ \#\ \[?[[:digit:]] ]]; then
        has_start_line=1
      fi
    elif [[ $has_start_line -eq 1 ]]; then
      # If we do have a starting line, look for a closing line. Either exit the loop or append to the changelog.
      if [[ "$line" =~ \#\ \[?[[:digit:]] ]]; then
        break
      else
        changelog=$"$changelog\n$line"
      fi
    fi
  done <"$1" || throw "Unable to parse input file"

  # Ignore rule `SC2059` as we do *not* want newlines/etc escaped here.
  # shellcheck disable=SC2059
  printf "$changelog"
}

get_changelog "$@"
