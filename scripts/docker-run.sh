#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Docker image params
readonly IMAGE_REPOSITORY="styled-java-patterns"
readonly IMAGE_TAG="latest"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

cd "$(dirname "$0")/.." || exit 1

main() {
  echo 'Running docker container...'

  # Run docker image
  config_container_id=$(create_docker_container)

  # shellcheck disable=SC2064
  trap "cleanup ${config_container_id}" EXIT

#  configure_kubectl "${config_container_id}"
}

cleanup() {
  echo 'Removing docker container...'

  config_container_id=$1
  docker container rm --force $config_container_id > /dev/null
  #docker kill ct > /dev/null 2>&1

  echo 'Done!'
}

configure_kubectl() {
  container_id="$1"

  apiserver_id=$(lookup_apiserver_container_id)
  if [[ -z "$apiserver_id" ]]; then
      echo "ERROR: API-Server container not found. Make sure 'Show system containers' is enabled in Docker4Mac 'Preferences'!" >&2
      exit 1
  fi

  ip=$(get_docker_args "$apiserver_id" --advertise-address)
  port=$(get_docker_args "$apiserver_id" --secure-port)
}

lookup_apiserver_container_id() {
    docker container list --filter name=k8s_kube-apiserver --format '{{ .ID }}'
}

get_docker_args() {
  container_id="$1"
  arg="$2"

  docker container inspect "$container_id" | jq -r ".[].Args[] | capture(\"$arg=(?<arg>.*)\") | .arg"
}

create_docker_container() {
  docker run -ti --rm \
            -v "$REPO_ROOT:/usr/src/app" \
            -e CI=1 \
            "${IMAGE_REPOSITORY}:${IMAGE_TAG}" build --strict
}

main
