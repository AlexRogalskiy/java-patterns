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

set -o errexit
set -o nounset
set -o pipefail

## setup base directory
BASE_DIR=$(dirname "$0")

_exit() {
  (($# > 1)) && echo "${@:2}"
  exit "$1"
}

main() {
  echo ">>> Logging docker containers..."

  ## save current working directory
  pushd "$BASE_DIR" &> /dev/null || _exit 1 "Unable to save current working directory"

  docker-compose -f docker-compose.yml logs -t --follow

  ## restore previous working directory
  popd &> /dev/null || _exit 1 "Unable to restore current working directory"
}

main "$@"
