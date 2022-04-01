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

# Usage example: /bin/sh ./scripts/read_cpus_available.sh

set -o errexit
set -o nounset
set -o pipefail

CPUS_AVAILABLE=1

case "$(uname -s)" in
Darwin)
    CPUS_AVAILABLE=$(sysctl -n machdep.cpu.core_count)
    ;;
Linux)
    CFS_QUOTA=$(cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us)
    if [ "$CFS_QUOTA" -ge 100000 ]; then
    CPUS_AVAILABLE=$(("${CFS_QUOTA}" / 100 / 1000))
    fi
    ;;
*)
    # Unsupported host OS. Must be Linux or Mac OS X.
    ;;
esac

echo ${CPUS_AVAILABLE}
