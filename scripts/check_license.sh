#!/usr/bin/env bash

set -e

licRes=$(
# shellcheck disable=SC2044
for file in $(find ./scripts/ -type f -name "*.ts" -o -name "*.js"); do
	head -n3 "${file}" | grep -Eq "(Copyright|generated|GENERATED)" || echo -e "  ${file}"
done;)
if [ -n "${licRes}" ]; then
	echo -e "license header checking failed:\n${licRes}"
	exit 255
fi
