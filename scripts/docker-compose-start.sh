#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")/.." || exit 1

main() {
  echo 'Starting docker container...'

  docker-compose -f docker-compose.yml build
  docker-compose -f docker-compose.yml up -d
}

main "$@"
