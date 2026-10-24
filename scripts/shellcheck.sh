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

# Usage example: /bin/sh ./scripts/shellcheck.sh [--shell|--no-shell]

set -o errexit
set -o nounset
set -o pipefail

test_shell()
{
  mkdir -p .shellcheck
  find ./scripts -path ./.git -prune -o -type f -exec grep -Eq '^#!(.*/|.*env +)(sh|bash|ksh)' {} \; -print |
  while IFS="" read -r file
  do
    # collect all warnings
    shellcheck --format=checkstyle --check-sourced --shell=sh "$file" > ".shellcheck/$(basename "${file}")".log || true
    # fail on >=error
    shellcheck --severity error "$file"
  done
}

# fails on error and ignores other levels
test_shell_error()
{
  # Shellcheck
  find ./scripts -path ./.git -prune -o -type f -exec grep -Eq '^#!(.*/|.*env +)(sh|bash|ksh)' {} \; -print |
  while IFS="" read -r file
  do
    # with recent shellcheck, "-S error" replaces this hack
    # kept as this runs on machines running rudder-dev
    (shellcheck --format gcc "$file" | grep " error: " && exit 1) || true
  done
}

if [ "${1:-'--shell'}" = "--shell" ]; then
  test_shell
  exit 0
else
  # quick tests to be launched during merge
  test_shell_error
fi
