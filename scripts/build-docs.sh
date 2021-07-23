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
python3 $TMPDIR/get-pip.py

## Install project dependencies
python3 -m pip install mkdocs --quiet
python3 -m pip install mkdocs-material --quiet
python3 -m pip install markdown-include --quiet
python3 -m pip install fontawesome_markdown --quiet
python3 -m pip install mkdocs-redirects --quiet
python3 -m pip install mkdocs-techdocs-core --no-cache-dir --quiet
python3 -m pip install mkdocs-git-revision-date-localized-plugin --no-cache-dir --quiet
python3 -m pip install mkdocs-awesome-pages-plugin --no-cache-dir --quiet
python3 -m pip install mdx_truly_sane_lists --no-cache-dir --quiet
python3 -m pip install smarty --no-cache-dir --quiet
python3 -m pip install mkdocs-include-markdown-plugin --no-cache-dir --quiet
#python3 -m pip install mkdocs_pymdownx_material_extras --no-cache-dir --quiet
python3 -m pip install click-man --no-cache-dir --quiet
python3 -m pip install cookiecutter --no-cache-dir --quiet

## Start server locally
python3 -m mkdocs serve --verbose --dirtyreload
