#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")/.." || exit 1

main() {
  echo 'Stopping docker container...'

  docker-compose -f docker-compose.yml down -v --remove-orphans
}

main
