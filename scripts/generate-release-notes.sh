#!/usr/bin/env bash

VERSION=$(git describe --tags)
LAST=$(git describe --abbrev=0 --tags ${VERSION}^)
CHANGELOG=$(git log --pretty=format:%s ${LAST}..HEAD | grep ':' | sed -re 's/(.*)\:/- \`\1\`\:/' | sort)

cat <<NOTES
# Release [${VERSION}]

Provide short description.

## What's New in release [${VERSION}]?

Describe the release here.

## Changelog

${CHANGELOG}
NOTES
