#!/usr/bin/env bash

set -e
set -o errexit
set -o pipefail
set -o nounset

## Upgrade pip module
pip install --upgrade pip

## Install project dependencies
pip install mkdocs
pip install mkdocs-material
pip install markdown-include

## Start server locally
mkdocs serve --verbose --dirtyreload
