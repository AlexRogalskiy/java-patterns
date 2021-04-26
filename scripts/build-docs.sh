#!/usr/bin/env bash

set -e
set -o errexit
set -o pipefail
set -o nounset

## Change working directory
base_dir=$(dirname $0)/..
cd $base_dir

## Install pip module
wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py -O $TMPDIR/get-pip.py
python $TMPDIR/get-pip.py

## Install project dependencies
python -m pip install mkdocs
python -m pip install mkdocs-material
python -m pip install markdown-include

## Start server locally
python -m mkdocs serve --verbose --dirtyreload
