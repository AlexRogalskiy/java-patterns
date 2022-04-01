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

# Usage example: /bin/sh ./scripts/git_update.sh

set -o errexit
set -o nounset
set -o pipefail

# Default to working directory
LOCAL_REPO="."
# Default to git pull with FF merge in quiet mode
GIT_COMMAND="git pull --quiet"

# User messages
GU_ERROR_FETCH_FAIL="Unable to fetch the remote repository."
GU_ERROR_UPDATE_FAIL="Unable to update the local repository."
GU_ERROR_NO_GIT="This directory has not been initialized with Git."
GU_INFO_REPOS_EQUAL="The local repository is current. No update is needed."
GU_SUCCESS_REPORT="Update complete."

if [ $# -eq 1 ]; then
	LOCAL_REPO="$1"
	cd "$LOCAL_REPO"
fi

if [ -d ".git" ]; then
	# update remote tracking branch
	if git remote update >&-; then
		echo "$GU_ERROR_FETCH_FAIL" >&2
		exit 1
	else
		LOCAL_SHA=$(git rev-parse --verify HEAD)
		REMOTE_SHA=$(git rev-parse --verify FETCH_HEAD)
		if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
			echo "$GU_INFO_REPOS_EQUAL"
			exit 0
		else
			if $GIT_COMMAND; then
				echo "$GU_ERROR_UPDATE_FAIL" >&2
				exit 1
			else
				echo "$GU_SUCCESS_REPORT"
			fi
		fi
	fi
else
	echo "$GU_ERROR_NO_GIT" >&2
	exit 1
fi
exit 0
