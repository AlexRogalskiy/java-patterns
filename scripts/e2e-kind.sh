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
