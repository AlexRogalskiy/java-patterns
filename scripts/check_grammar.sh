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

# Usage example: /bin/sh ./scripts/check_license.sh

set -o errexit
set -o nounset
set -o pipefail

set -e

if ! command -v aspell > /dev/null; then
    echo "Missing aspell utility"
elif ! aspell dump dicts | grep -qw "en$" > /dev/null ; then
    echo "Missing aspell English dictionary (aspell-en)"
fi

DATAFILE=$(mktemp /tmp/aspell-strings.XXXXXXXXXX)
DATAFILE_SORTED=$(mktemp /tmp/aspell-strings-sorted.XXXXXXXXXX)

echo "Temporary file: ${DATAFILE}"
#strings ./docs > "${DATAFILE}"
find ./docs -type f -exec strings {} \; | tr ' ' '\n' >> "${DATAFILE}"


# tr    delete quotes (disabled) #    tr -d "'" | \
# tr    split key/value pairs
# tr    split words or paths
# grep  get all words 4 characters or more
# sed   strip out unwanted characters
# grep  ignore uppercase words (2 or more capitals)
# grep  ignore words with underscores (most likely variables)
# grep  ignore words with dots
# awk   count number of capitals by doing a replacement and showing word + count
# awk   only show items that have one capital max
# grep  another run to get rid of very short words
# tr    turn all words into lowercase before sorting
# sort  sort and only store unique words
{
    tr '=' ' ' | \
    tr '/' ' ' | \
    grep -E "^[a-zA-Z]{4,}" | \
    sed -e 's/[|?#,:"\{\}\$=\(\)\;\/]//g' | \
    tr ' ' '\n' | \
    grep -E -v "^[A-Z]{2,}" | \
    grep -v "_" | \
    grep -v "\." | \
    awk '{print $1,gsub("[A-Z]","")}' | \
    awk '{if ($2 <= 1) { print $1 }}' | \
    grep -E "^[a-zA-Z]{4,}" | \
    tr '[:upper:]' '[:lower:]' | \
    sort --unique > "${DATAFILE_SORTED}"
} < "${DATAFILE}"

aspell --lang=en --ignore-case --personal=./scripts/template/words-to-ignore.en.pws check "${DATAFILE_SORTED}"

if [ -f "${DATAFILE}" ]; then rm "${DATAFILE}"; fi
if [ -f "${DATAFILE_SORTED}" ]; then rm "${DATAFILE_SORTED}"; fi
