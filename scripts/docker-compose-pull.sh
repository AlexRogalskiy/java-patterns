#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")/.." || exit 1

main() {
  echo ">>> Pulling docker containers..."

  docker-compose -f docker-compose.yml pull --include-deps --quiet
}

main "$@"
