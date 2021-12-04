#!/usr/bin/env bash

## setup base directory
BASE_DIR=$(dirname "$0")

## common functions setup
cd "$BASE_DIR/.." || exit 1

{
	cat <<-'EOH'
	# This file lists all contributors having contributed to pouch.
	# For how it is generated, see `scripts/generate-contributors.sh`.
	EOH
	echo
	git log --format='%aN <%aE>' | LC_ALL=C.UTF-8 sort -uf
} > CONTRIBUTORS
