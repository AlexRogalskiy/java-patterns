#!/usr/bin/env bash

#doc: Close pending pull request temporary
# shellcheck disable=SC2124
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
MESSAGE=$(cat $SCRIPT_DIR/../closing-message.txt)

set +x #GITHUB_TOKEN
curl -s -o /dev/null \
  -X POST \
  --data "$(jq --arg body "$MESSAGE" -n '{body: $body}')" \
  --header "authorization: Bearer $GITHUB_TOKEN" \
  --header 'content-type: application/json' \
  "$(jq -r '.issue.comments_url' "$GITHUB_EVENT_PATH")"

curl -s -o /dev/null \
  -X PATCH \
  --data '{"state": "close"}' \
  --header "authorization: Bearer $GITHUB_TOKEN" \
  --header 'content-type: application/json' \
  "$(jq -r '.issue.pull_request.url' "$GITHUB_EVENT_PATH")"
