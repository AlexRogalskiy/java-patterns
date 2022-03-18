#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")/.." || exit 1

main() {
  echo ">>> Starting docker containers..."

  docker-compose -f docker-compose.yml up --detach --build --force-recreate --renew-anon-volumes
}

main "$@"
