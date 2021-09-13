#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Docker image params
readonly IMAGE_REPOSITORY="styled-java-patterns"
readonly IMAGE_TAG="latest"
readonly GIT_SHA=$(git rev-parse HEAD)

cd "$(dirname "$0")/.." || exit 1

main() {
  echo 'Building docker container...'

  # Build docker image
  docker build --rm=false -f Dockerfile -t "${IMAGE_REPOSITORY}:${IMAGE_TAG}" -t "${IMAGE_REPOSITORY}:${GIT_SHA}" .
}

main
