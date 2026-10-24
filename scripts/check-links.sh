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

# Usage example: /bin/sh ./scripts/check_links.sh

cd "$(dirname "${BASH_SOURCE[0]}")/.." \
  || exit 1

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare exitCode=0
declare markdownFiles=$( \
    find . \
    -name "*.md" \
    -not -path "./node_modules/*" \
  );

for file in $markdownFiles; do
  markdown-link-check \
    --config scripts/markdown-link-check.json \
    --progress \
    --retry \
    --verbose \
    "$file" \
    || exitCode=1
done

exit $exitCode
