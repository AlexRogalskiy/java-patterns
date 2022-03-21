#!/bin/bash
# Scriptacular - gitupdate.sh
# Compare SHA-1 between local and remote repositories, git pull + FF merge in local if they differ
# Copyright 2013 Christopher Simpkins
# MIT License

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
	git remote update >&-
	if (( $? )); then
		echo $GU_ERROR_FETCH_FAIL >&2
		exit 1
	else
		LOCAL_SHA=$(git rev-parse --verify HEAD)
		REMOTE_SHA=$(git rev-parse --verify FETCH_HEAD)
		if [ $LOCAL_SHA = $REMOTE_SHA ]; then
			echo $GU_INFO_REPOS_EQUAL
			exit 0
		else
			$GIT_COMMAND
			if (( $? )); then
				echo $GU_ERROR_UPDATE_FAIL >&2
				exit 1
			else
				echo $GU_SUCCESS_REPORT
			fi
		fi
	fi
else
	echo $GU_ERROR_NO_GIT >&2
	exit 1
fi
exit 0
