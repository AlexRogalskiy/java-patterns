#!/usr/bin/env bash

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
BASE_DIR=$(dirname "$0")
# DOCKER_COMPOSE_CMD stores docker compose command
DOCKER_COMPOSE_CMD=${DOCKER_COMPOSE_CMD:-$(command -v docker-compose || command -v docker compose)}

_exit() {
  (($# > 1)) && echo "${@:2}"
  exit "$1"
}

usage() {
  read -r -d '' MESSAGE <<- EOM
    Usage: ${0} [operation]

    where [operation] is one of the following:
        [up|start]: to start docker containers
        [down|stop]: to stop docker containers
        [logs|-l]: to view docker containers logs
        [ps|-p]: to view docker processes
        [help|-h]: to view docker processes
EOM
  echo
  echo "$MESSAGE"
  echo
  _exit 1
}

cleanup_sig() {
  local ret=$?
  echo "Starting cleanup"
  stop

  return $ret
}

cleanup_err() {
  local ret=$?
  local fn=$0 ret=$? lineno=${BASH_LINENO:-$LINENO}
  echo "ERROR $fn exit with $ret at line $lineno: $(sed -n ${lineno}p "$0")."
  stop

  return $ret
}

trap cleanup_sig SIGTERM SIGINT
trap cleanup_err ERR

docker_ps() {
  echo ">>> Processing status of docker containers..."

  ## save current working directory
  pushd "$BASE_DIR" &> /dev/null || _exit 1 "Unable to save current working directory"

  $(DOCKER_COMPOSE_CMD) -f docker-compose.yml ps "$@"

  ## restore previous working directory
  popd &> /dev/null || _exit 1 "Unable to restore current working directory"
}

docker_logs() {
  echo ">>> Logging docker containers..."

  ## save current working directory
  pushd "$BASE_DIR" &> /dev/null || _exit 1 "Unable to save current working directory"

  $(DOCKER_COMPOSE_CMD) -f docker-compose.yml logs -t --follow "$@"

  ## restore previous working directory
  popd &> /dev/null || _exit 1 "Unable to restore current working directory"
}

docker_pull() {
  echo ">>> Pulling docker containers..."

  ## save current working directory
  pushd "$BASE_DIR" &> /dev/null || _exit 1 "Unable to save current working directory"

  $(DOCKER_COMPOSE_CMD) -f docker-compose.yml pull --include-deps --quiet "$@"

  ## restore previous working directory
  popd &> /dev/null || _exit 1 "Unable to restore current working directory"
}

docker_start() {
  echo ">>> Starting docker containers..."

  ## save current working directory
  pushd "$BASE_DIR" &> /dev/null || _exit 1 "Unable to save current working directory"

  $(DOCKER_COMPOSE_CMD) -f docker-compose.yml up --detach --build --force-recreate --renew-anon-volumes "$@"

  ## restore previous working directory
  popd &> /dev/null || _exit 1 "Unable to restore current working directory"
}

docker_stop() {
  echo ">>> Stopping docker containers..."

  ## save current working directory
  pushd "$BASE_DIR" &> /dev/null || _exit 1 "Unable to save current working directory"

  $(DOCKER_COMPOSE_CMD) -f docker-compose.yml down --remove-orphans --volumes "$@"

  ## restore previous working directory
  popd &> /dev/null || _exit 1 "Unable to restore current working directory"
}

main() {
  [ ${#@} -gt 0 ] || usage

  cmd="$1"; shift;
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
