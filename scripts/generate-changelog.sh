#!/usr/bin/env bash

set -e

## setup base directory
BASE_DIR=$(dirname "$0")

_exit() {
  (($# > 1)) && echo "${@:2}"
  exit "$1"
}

main() {
  ## save current working directory
  pushd "$BASE_DIR" &> /dev/null || _exit 1 "Unable to save current working directory"

  ## setup directory with docker configurations
  cd "$BASE_DIR/.." || _exit 1 "Unable to change working directory"

  FILE=$(mktemp)
  TAG_CURRENT=$(git describe --abbrev=0)
  {
      printf '# Release: '%s'\n' "$TAG_CURRENT"
      git log "$TAG_CURRENT"...HEAD --pretty=format:"* %s";
      printf "%s" "\n\n---\n";
      cat CHANGELOG.md

  } >> "$FILE"

  cp "$FILE" CHANGELOG.md
  rm "$FILE"

  ## restore previous working directory
  popd &> /dev/null || _exit 1 "Unable to restore current working directory"
}

main "$@"
