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

# Usage example: /bin/sh ./scripts/git_history.sh

set -o errexit
set -o nounset
set -o pipefail

CSV_FILE=$(PWD)/datas.csv

echo 'date,commits,filePath' > "$CSV_FILE"

if [ $# = 1 ]
then
  cd "$1" || exit 1
fi

tree=$(git ls-tree -r --name-only HEAD)
nbFiles=$(echo "$tree" | wc -l)
echo "Number of files: $nbFiles"

i=0
for filename in $tree ; do
  i=$((i + 1))
  log=$(git log --format="%ad" -- "$filename")
  echo "$(echo "$log" | head -n 1),$(echo "$log" | wc -l),$filename" >> "$CSV_FILE"
  percent=$((i*100/nbFiles))
  echo -en "\r>$percent%"
done
