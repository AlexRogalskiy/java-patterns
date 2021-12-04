#!/usr/bin/env bash

## setup base directory
BASE_DIR=$(dirname "$0")

## common functions setup
cd "$BASE_DIR/.." || exit 1

{
	cat <<-'EOH'
	# This file lists all individuals having contributed content to the repository.
	# For how it is generated, see `scripts/generate-authors.sh`.
	EOH
	echo
	git log --format='%aN <%aE>' | LC_ALL=C.UTF-8 sort -uf
} > AUTHORS
