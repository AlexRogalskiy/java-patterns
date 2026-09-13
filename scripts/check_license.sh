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

# Usage example: /bin/sh ./scripts/check_license.sh

set -o errexit
set -o nounset
set -o pipefail

set -e

licRes=$(
  # shellcheck disable=SC2044
  for file in $(find ./scripts/* -type f -name "*.ts" -o -name "*.js" -o -name "*.sh"); do
    head -n3 "${file}" | grep -Eq "(Copyright|generated|GENERATED)" || echo " -> ${file}"
done;)
if [ -n "${licRes}" ]; then
  printf ">>> License header checking failed:\n%s" "${licRes}"
  exit 255
fi
