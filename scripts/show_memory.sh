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

# Usage example: /bin/sh ./scripts/show_memory.sh

set -o errexit
set -o nounset
set -o pipefail

ps aux |
awk '
{
    seen[$11]++
    mem[$11] += $6
    n += 1
    ram += $6
}
END {
    printf t
    for (p in seen) {
        printf "%-65s %8d %8d %8.1f%%\n", p, seen[p], mem[p]/1024, mem[p]/ram*100
    }
    printf "%-65s %8s %8d %8.1f%%\n","Total:",n,ram/1024,100
}' |
sort -k3n |
tail -20
