#!/usr/bin/env bash

set -e

test_shell()
{
  mkdir -p .shellcheck
  find ./scripts -path ./.git -prune -o -type f -exec grep -Eq '^#!(.*/|.*env +)(sh|bash|ksh)' {} \; -print |
    while IFS="" read -r file
    do
      # collect all warnings
      shellcheck --format=checkstyle "$file" > ".shellcheck/$(basename "${file}")".log || true
      # fail on >=error
      shellcheck --severity error "$file"
    done
}

# fails on error and ignores other levels
test_shell_error()
{
  # Shellcheck
  find ./scripts -path ./.git -prune -o -type f -exec grep -Eq '^#!(.*/|.*env +)(sh|bash|ksh)' {} \; -print |
    while IFS="" read -r file
    do
      # with recent shellcheck, "-S error" replaces this hack
      # kept as this runs on machines running rudder-dev
      (shellcheck --format gcc "$file" | grep " error: " && exit 1) || true
    done
}

if [ "$1" = "--shell" ]; then
  test_shell
  exit 0
else
  # quick tests to be launched during merge
  test_shell_error
fi
