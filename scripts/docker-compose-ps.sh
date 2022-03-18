#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")/.." || exit 1

main() {
  echo ">>> Processing status of docker containers..."

  docker-compose -f docker-compose.yml ps
}

main "$@"
