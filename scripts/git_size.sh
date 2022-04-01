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

# Usage example: /bin/sh ./scripts/git_size.sh

set -o errexit
set -o nounset

IFS=$'\n';

# list all objects including their size, sort by size, take top 10
objects=$(git verify-pack -v .git/objects/pack/pack-*.idx | grep -v chain | sort -k3nr | head)

echo "All sizes are in kB's. The pack column is the size of the object, compressed, inside the pack file."

output="size,pack,SHA,location"
allObjects=$(git rev-list --all --objects)
for y in $objects
do
	    # extract the size in bytes
	        size=$(($(echo "$y" | cut -f 5 -d ' ')/1024))
		    # extract the compressed size in bytes
		        compressedSize=$(($(echo "$y" | cut -f 6 -d ' ')/1024))
			    # extract the SHA
			        sha=$(echo "$y" | cut -f 1 -d ' ')
				    # find the objects location in the repository tree
				        other=$(echo "${allObjects}" | grep "$sha")
					    #lineBreak=`echo -e "\n"`
					        output="${output}\n${size},${compressedSize},${other}"
					done

					echo "$output" | column -t -s ', '
