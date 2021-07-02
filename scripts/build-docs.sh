#!/usr/bin/env bash

umask 0077

TRUE_REG='^([tT][rR][uU][eE]|[yY]|[yY][eE][sS]|1)$'
FALSE_REG='^([fF][aA][lL][sS][eE]|[nN]|[nN][oO]|0)$'

DEBUG_SCRIPT=${DEBUG_SCRIPT:-false}
if [[ $DEBUG_SCRIPT =~ $TRUE_REG ]]; then
  set -o xtrace
fi

STRICT_SCRIPT=${STRICT_SCRIPT:-false}
if [[ $STRICT_SCRIPT =~ $TRUE_REG ]]; then
  set -o errexit
  set -o nounset
  set -o pipefail
fi

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
