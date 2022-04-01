#!/usr/bin/env bash
# Copyright (C) 2022 SensibleMetrics, Inc. (http://sensiblemetrics.io/)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
