#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Docker image params
DEFAULT_IMAGE_REPOSITORY="styled-java-patterns"
DEFAULT_IMAGE_TAG="latest"

readonly IMAGE_REPOSITORY="${IMAGE_REPOSITORY:-$DEFAULT_IMAGE_REPOSITORY}"
readonly IMAGE_TAG="${IMAGE_TAG:-$DEFAULT_IMAGE_TAG}"
readonly GIT_SHA=$(git rev-parse HEAD)

cd "$(dirname "$0")/.." || exit 1

main() {
  echo 'Building docker container...'

  # docker file tag
  local tag
  tag="$1"

  # docker file path
  local file
  file="./distribution/docker-images/${tag}.Dockerfile"

  # Build docker image
  docker build --rm -f "$file" -t "${IMAGE_REPOSITORY}:${IMAGE_TAG}" -t "${IMAGE_REPOSITORY}:${GIT_SHA}" .
}

main "$@"
