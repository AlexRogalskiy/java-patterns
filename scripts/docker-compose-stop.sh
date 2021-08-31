#!/bin/sh

set -e

cd "$(dirname "$0")" || exit 1

docker-compose -f docker-compose.yml down -v --remove-orphans
