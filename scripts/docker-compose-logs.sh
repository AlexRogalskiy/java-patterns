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
