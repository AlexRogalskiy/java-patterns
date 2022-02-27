#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

main() {
	git ls-remote --tags --quiet | \
	grep -E 'refs/tags/v[0-9A-Z]*.[0-9A-Z]*$' | \
	sed -e 's,.*/,,' | \
	tail -n1
}

main "$@"
