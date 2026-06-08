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

# Usage example: /bin/sh ./scripts/hook.sh

set -o errexit
set -o nounset
set -o pipefail

cat << EOF
Build specification:
    DefaultRepo:    $SKAFFOLD_DEFAULT_REPO
    MultiLevelRepo: $SKAFFOLD_MULTI_LEVEL_REPO
    RPCPort:        $SKAFFOLD_RPC_PORT
    HTTPPort:       $SKAFFOLD_HTTP_PORT
    WorkDir:        $SKAFFOLD_WORK_DIR
    Image:          $SKAFFOLD_IMAGE
    PushImage:      $SKAFFOLD_PUSH_IMAGE
    ImageRepo:      $SKAFFOLD_IMAGE_REPO
    ImageTag:       $SKAFFOLD_IMAGE_TAG
    BuildContext:   $SKAFFOLD_BUILD_CONTEXT
EOF
