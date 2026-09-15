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

# Usage example: /bin/sh ./scripts/build-docs.sh

TRUE_REG='^([tT][rR][uU][eE]|[yY]|[yY][eE][sS]|1)$'
FALSE_REG='^([fF][aA][lL][sS][eE]|[nN]|[nN][oO]|0)$'

DEBUG_SCRIPT=${DEBUG_SCRIPT:-false}
if [[ $DEBUG_SCRIPT =~ $TRUE_REG ]]; then
  set -o xtrace
fi

STRICT_SCRIPT=${STRICT_SCRIPT:-false}
if [[ $STRICT_SCRIPT =~ $TRUE_REG ]]; then
  set -o errexit
  set -o nounset
  set -o pipefail
fi

main() {
  echo ">>> Running mkdocs server..."

  ## Install pip module
  wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py -O "$TMPDIR"/get-pip.py
  python3 "$TMPDIR"/get-pip.py

  ## Install project dependencies
  python3 -m pip install -r ./docs/requirements.txt --no-cache-dir --disable-pip-version-check

  ## Start server locally
  python3 -m mkdocs serve --verbose --dirtyreload
}

main "$@"
