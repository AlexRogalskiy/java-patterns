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

# Usage example: /bin/sh ./scripts/docker-run.sh

set -o errexit
set -o nounset
set -o pipefail

# Docker image params
readonly IMAGE_REPOSITORY="styled-java-patterns"
readonly IMAGE_TAG="latest"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

cd "$(dirname "$0")/.." || exit 1

# DOCKER_CMD stores docker command
DOCKER_CMD=${DOCKER_CMD:-$(command -v docker 2> /dev/null || command -v podman 2> /dev/null || type -p docker)}
# DOCKER_OPTS stores docker options
DOCKER_OPTS=${DOCKER_OPTS:-"--shm-size=1G"}

main() {
  echo "Running docker container..."

  # Run docker image
  config_container_id=$(create_docker_container)

  # shellcheck disable=SC2064
  trap "cleanup ${config_container_id}" EXIT

  #  configure_kubectl "${config_container_id}"
}

cleanup() {
  echo "Removing docker container..."

  config_container_id=$1
  $DOCKER_CMD container rm --force "$config_container_id" > /dev/null
  #docker kill ct > /dev/null 2>&1

  echo "Done!"
}

configure_kubectl() {
  container_id="$1"

  apiserver_id=$(lookup_apiserver_container_id)
  if [[ -z "$apiserver_id" ]]; then
    echo "ERROR: API-Server container not found. Make sure "Show system containers" is enabled in Docker4Mac \"Preferences\"!" >&2
    exit 1
  fi

  ip=$(get_docker_args "$apiserver_id" --advertise-address)
  port=$(get_docker_args "$apiserver_id" --secure-port)

  echo "${ip}:${port}"
}

lookup_apiserver_container_id() {
  $DOCKER_CMD container list --filter name=k8s_kube-apiserver --format "{{ .ID }}"
}

get_docker_args() {
  container_id="$1"
  arg="$2"

  $DOCKER_CMD container inspect "$container_id" | jq -r ".[].Args[] | capture(\"$arg=(?<arg>.*)\") | .arg"
}

create_docker_container() {
  $DOCKER_CMD run \
    --interactive \
    --tty \
    --rm \
    --privileged \
    $DOCKER_OPTS \
    --volume "$REPO_ROOT:/usr/src/app" \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --env CI=1 \
    "${IMAGE_REPOSITORY}:${IMAGE_TAG}" build --strict
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
