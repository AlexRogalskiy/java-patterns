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

# Usage example: /bin/sh ./scripts/docker-compose.sh

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob
# Append to the Bash history file, rather than overwriting it
shopt -s histappend
# Autocorrect typos in path names when using `cd`
shopt -s cdspell
### Check the window size after each command ($LINES, $COLUMNS)
shopt -s checkwinsize

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null
done

set -o errexit
set -o nounset
set -o pipefail

## BASE_DIR stores base directory
BASE_DIR=$(dirname "$0")/..
# DOCKER_COMPOSE_CMD stores docker compose command
DOCKER_COMPOSE_CMD=${DOCKER_COMPOSE_CMD:-$(command -v docker-compose 2> /dev/null || command -v docker compose 2> /dev/null || type -p docker-compose)}
# DOCKER_COMPOSE_OPTS stores docker compose options
DOCKER_COMPOSE_OPTS=${DOCKER_COMPOSE_OPTS:-"--ansi=never"}

_exit() {
  (($# > 1)) && echo "${@:2}"
  exit "$1"
}

usage() {
  read -r -d '' MESSAGE <<- EOM

    Usage: ${0} [operation]
    Run docker compose command with an operation subcommand.

    where [operation] is one of the following:
        * [up|start]: to start docker containers
        * [down|stop]: to stop docker containers
        * [logs|-l]: to view docker containers logs
        * [ps|-p]: to view docker processes
        * [help|-h]: to view docker processes

    LICENSE GPL-3.0

    Copyright (c) 2020-2022 SensibleMetrics, Inc. All rights reserved.

EOM
  echo
  echo "$MESSAGE"
  echo
  _exit 1
}

cleanup_sig() {
  local ret=$?
  echo ">>> Starting cleanup"
  stop

  return $ret
}

cleanup_err() {
  local ret=$?
  local fn=$0 ret=$? lineno=${BASH_LINENO:-$LINENO}
  echo ">>> ERROR $fn exit with $ret at line $lineno: $(sed -n ${lineno}p "$0")."
  stop

  return $ret
}

trap cleanup_sig SIGTERM SIGINT
trap cleanup_err ERR

docker_ps() {
  echo ">>> Processing status of docker containers..."

  $DOCKER_COMPOSE_CMD \
    $DOCKER_COMPOSE_OPTS \
    --file "${BASE_DIR}/docker-compose.yml" \
    ps "$@"
}

docker_logs() {
  echo ">>> Logging docker containers..."

  $DOCKER_COMPOSE_CMD \
    $DOCKER_COMPOSE_OPTS \
    --file "${BASE_DIR}/docker-compose.yml" \
    logs -t --follow "$@"
}

docker_pull() {
  echo ">>> Pulling docker containers..."

  $DOCKER_COMPOSE_CMD \
    $DOCKER_COMPOSE_OPTS \
    --file "${BASE_DIR}/docker-compose.yml" \
    pull --include-deps --quiet "$@"
}

docker_start() {
  echo ">>> Starting docker containers..."

  $DOCKER_COMPOSE_CMD \
    $DOCKER_COMPOSE_OPTS \
    --file "${BASE_DIR}/docker-compose.yml" \
    up --detach --build --force-recreate --renew-anon-volumes "$@"
}

docker_stop() {
  echo ">>> Stopping docker containers..."

  $DOCKER_COMPOSE_CMD \
    $DOCKER_COMPOSE_OPTS \
    --file "${BASE_DIR}/docker-compose.yml" \
    down --remove-orphans --volumes "$@"
}

main() {
  [ ${#@} -gt 0 ] || usage

  cmd=$(echo "$1" | tr "[:upper:]" "[:lower:]"); shift;
  case "$cmd" in
    [sS]tart|[uU]p)
      docker_start "${@:1}"
      ;;
    [sS]top|[dD]own)
      docker_stop "${@:1}"
      ;;
    [lL]ogs|-l)
      docker_logs "${@:1}"
      ;;
    [pP]ull|-pl)
      docker_pull "${@:1}"
      ;;
    [pP]s|-p)
      docker_ps "${@:1}"
      ;;
    [hH]elp|-h)
      usage
      ;;
    *)
      _error "Unrecognized option: $cmd"
      usage
      ;;
  esac
}

main "$@"
