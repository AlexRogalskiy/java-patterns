#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

CLUSTER_NAME="backend-java-patterns"
readonly CLUSTER_NAME

K8S_IMAGE="styled-java-patterns"
readonly K8S_IMAGE

K8S_VERSION="latest"
readonly K8S_VERSION

create_kind_cluster() {
  echo 'Creating k8s cluster...'

  kind create cluster --name "$CLUSTER_NAME" --image "$K8S_IMAGE:$K8S_VERSION" --wait 60s

  kubectl cluster-info || kubectl cluster-info dump
  echo

  kubectl get nodes
  echo

  echo 'Cluster ready!'
  echo
}

cleanup() {
    echo 'Removing k8s cluster...'

    kind delete cluster --name "$CLUSTER_NAME"
    echo 'Done!'
}

main() {
    trap cleanup EXIT

    create_kind_cluster
}

main "$@"
