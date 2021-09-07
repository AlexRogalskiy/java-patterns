#!/bin/sh

set -e

cd "$(dirname "$0")" || exit 1

# Docker image params
GIT_SHA=$(git rev-parse HEAD)
IMAGE_TAG="styled-java-patterns"

# Build docker image
docker build -f Dockerfile -t "${IMAGE_TAG}" -t "${IMAGE_TAG}:${GIT_SHA}" .
