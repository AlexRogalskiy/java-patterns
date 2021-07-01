#!/usr/bin/env bash

set -e
set -o errexit
set -o pipefail
set -o nounset

## Change working directory
BASE_DIR=$(dirname $0)/..
cd $BASE_DIR

## Install pip module
wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py -O $TMPDIR/get-pip.py
python $TMPDIR/get-pip.py

## Install project dependencies
python -m pip install mkdocs --quiet
python -m pip install mkdocs-material --quiet
python -m pip install markdown-include --quiet

## Start server locally
python -m mkdocs serve --verbose --dirtyreload
