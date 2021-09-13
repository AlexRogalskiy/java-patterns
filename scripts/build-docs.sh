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
cd "$(dirname "$0")/.." || exit 1

main() {
  echo 'Running mkdocs server...'

  ## Install pip module
  wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py -O "$TMPDIR"/get-pip.py
  python3 "$TMPDIR"/get-pip.py

  ## Install project dependencies
  python3 -m pip install -r ./docs/requirements.txt --no-cache-dir --disable-pip-version-check

  ## Start server locally
  python3 -m mkdocs serve --verbose --dirtyreload
}

main "$@"
