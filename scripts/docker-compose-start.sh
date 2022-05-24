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

# Usage example: /bin/sh ./scripts/docker-compose-start.sh

set -o errexit
set -o nounset
set -o pipefail

## setup base directory
BASE_DIR=$(dirname "$0")/..
## DOCKER_DIR stores docker directory
DOCKER_DIR="${BASE_DIR}"
# DOCKER_COMPOSE_CMD stores docker compose command
DOCKER_COMPOSE_CMD=${DOCKER_COMPOSE_CMD:-$(command -v docker-compose 2> /dev/null || command -v docker compose 2> /dev/null || type -p docker-compose)}
# DOCKER_COMPOSE_OPTS stores docker compose options
DOCKER_COMPOSE_OPTS=${DOCKER_COMPOSE_OPTS:-"--ansi=never"}

main() {
  echo ">>> Starting docker containers..."

  $DOCKER_COMPOSE_CMD \
    $DOCKER_COMPOSE_OPTS \
    --file "${DOCKER_DIR}/docker-compose.yml" up --detach --build --force-recreate --renew-anon-volumes "$@"
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
