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

# Usage example: /bin/sh ./scripts/show_swap.sh

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC2044
for DIR in $(find /proc/ -maxdepth 1 -type d -regex "^/proc/[0-9]+")
do
    PID=$(echo "$DIR" | cut -d / -f 3)
    PROGNAME=$(ps -p "$PID" -o comm --no-headers)
    # shellcheck disable=SC2013
    for SWAP in $(grep VmSwap $DIR/status 2>/dev/null | awk '{ print $2 }')
    do
        # shellcheck disable=SC2219
        let SUM=$SUM+$SWAP
    done
    # shellcheck disable=SC2004
    if (( $SUM > 0 ))
    then
        echo "PID=$PID swapped $SUM KB ($PROGNAME)"
    fi
    # shellcheck disable=SC2219
    let OVERALL=$OVERALL+$SUM
    SUM=0
done | sort -nk3
