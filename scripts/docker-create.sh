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

# Usage example: /bin/sh ./scripts/docker-create.sh

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# DOCKER_CMD stores docker command
DOCKER_CMD=${DOCKER_CMD:-$(command -v docker 2>/dev/null || command -v podman 2>/dev/null || type -p docker)}

main() {
  echo ">>> Saving docker container..."

  # docker container name
  local containerName
  containerName="$1"
  shift

  local tarGzFileName
  tarGzFileName="${2:-$containerName.tar.gz}"
  shift

  # Save docker image
  $DOCKER_CMD save "${containerName}" | gzip > "$tarGzFileName"
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
