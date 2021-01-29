#!/usr/bin/env bash

#doc: Show all the available comment commands
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
echo "Available commands:"
DOCTAG="#"
DOCTAG="${DOCTAG}doc"
for command in "$DIR"/*.sh; do
  COMMAND_NAME="$(basename "$command" | sed 's/\.sh$//')"
  if [ "$COMMAND_NAME" != "debug" ]; then
    printf " * /**%s** %s\n" "$COMMAND_NAME" "$(grep $DOCTAG "$command" | sed "s/$DOCTAG//g")"
  fi
done
