#!/usr/bin/env bash
# Copyright (C) 2022 SensibleMetrics, Inc. (http://sensiblemetrics.io/)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Usage example: /bin/sh ./scripts/git_view.sh

set -o nounset
set -o pipefail

HASH="%C(yellow)%h%Creset"
RELATIVE_TIME="%Cgreen(%ar)%Creset"
AUTHOR="%C(bold blue)<%an>%Creset"
REFS="%C(red)%d%Creset"
SUBJECT="%s"

FORMAT="$HASH}$RELATIVE_TIME}$AUTHOR}$REFS $SUBJECT"

usage() {
  read -r -d '' MESSAGE <<- EOM
    Usage: ${0} [operation]

    where [operation] is one of the following:
        [head]: to show git head commit
        [tree]: to show git commit tree
        [fat]: to show git fat files
        [branch]: to show git branches (ahead/behind)
EOM
  echo
  echo "$MESSAGE"
  echo
  exit 1
}

show_git_head() {
  show_git_tree -1
  git show -p --pretty="tformat:"
}

show_git_tree() {
  git log --graph --pretty="tformat:${FORMAT}" "$@" |
  # Replace (2 years ago) with (2 years)
  sed -Ee 's/(^[^<]*) ago)/\1)/' |
  # Replace (2 years, 5 months) with (2 years)
  sed -Ee 's/(^[^<]*), [[:digit:]]+ .*months?)/\1)/' |
  # Line columns up based on } delimiter
  column -s '}' -t |
  # Page only if we need to
  less -FXRS
}

show_git_branches() {
  git for-each-ref --format="%(refname:short) %(upstream:short)" refs/ | \
    while read -r local remote
  do
    if [ -x "$remote" ]; then
      branches=("$local")
    else
      branches=("$local" "$remote")
    fi;
    for branch in "${branches[@]}"; do
      if [ "$branch" != "origin/master" ]; then
        master="origin/master"
        git rev-list --left-right ${branch}...${master} -- 2>/dev/null >/tmp/git_upstream_status_delta || continue

        LEFT_AHEAD=$(grep -c '^<' /tmp/git_upstream_status_delta)
        RIGHT_AHEAD=$(grep -c '^>' /tmp/git_upstream_status_delta)

        if [[ $LEFT_AHEAD -gt 0 || $RIGHT_AHEAD -gt 0 ]]; then
          printf " - \033[1m%-50s\033[0m (" $branch
        else
          printf " - %-50s (" $branch
        fi;
        if [[ $LEFT_AHEAD -gt 0 ]]; then
          printf "\033[36mahead %3d\033[0m" $LEFT_AHEAD
        else
          printf "ahead %3d" $LEFT_AHEAD
        fi;
        echo -n ") | ("
        if [[ $RIGHT_AHEAD -gt 0 ]]; then
          printf "\033[31mbehind %3d\033[0m" $RIGHT_AHEAD
        else
          printf "behind %3d" $RIGHT_AHEAD
        fi;
        echo -e ") $master"
      fi;
    done
  done | sort -k5rn -k8n | uniq
}

show_git_fat_files() {
  git rev-list --all --objects | \
    sed -n $(git rev-list --objects --all | \
      cut -f1 -d' ' | \
      git cat-file --batch-check | \
      grep blob | \
      sort -n -k 3 | \
      tail -n40 | \
      while read -r hash type size; do
      echo -n "-e s/$hash/$size/p ";
  done) | \
    sort -n -k1
}

main() {
  [ ${#@} -gt 0 ] || usage

  cmd=$(echo "$1" | tr "[:upper:]" "[:lower:]"); shift;
  case "$cmd" in
    [hH]ead|-h)
      show_git_head "${@:1}"
      ;;
    [tT]ree|-t)
      show_git_tree "${@:1}"
      ;;
    [fF]at|-f)
      show_git_fat_files "${@:1}"
      ;;
    [bB]ranch|-b)
      show_git_branches "${@:1}"
      ;;
    *)
      echo "ERROR: unrecognized option: $cmd"
      usage
      ;;
  esac
}

main "$@"
