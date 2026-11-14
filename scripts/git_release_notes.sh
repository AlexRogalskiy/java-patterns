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

# Usage example: /bin/sh ./scripts/git_release_notes.sh

set -o errexit
set -o nounset
set -o pipefail

VERSION=$(git describe --tags)
LAST=$(git describe --abbrev=0 --tags ${VERSION}^)
CHANGELOG=$(git log --pretty=format:%s ${LAST}..HEAD | grep ':' | sed -re 's/(.*)\:/- \`\1\`\:/' | sort)

cat <<NOTES
# Release [${VERSION}]

Provide short description.

## What's New in release [${VERSION}]?

Describe the release here.

## Changelog

${CHANGELOG}
NOTES
