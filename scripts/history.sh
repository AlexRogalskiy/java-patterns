#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

CSVFILE=$(PWD)/datas.csv

echo 'date,commits,filePath' > "$CSVFILE"

if [ $# = 1 ]
then
    cd "$1" || exit 1
fi

tree=$(git ls-tree -r --name-only HEAD)
nbFiles=$(echo "$tree" | wc -l)
echo "Number of files: $nbFiles"

i=0
for filename in $tree ; do
    i=$((i + 1))
    log=$(git log --format="%ad" -- "$filename")
    echo "$(echo "$log" | head -n 1),$(echo "$log" | wc -l),$filename" >> "$CSVFILE"
    percent=$((i*100/nbFiles))
    echo -en "\r>$percent%"
done
