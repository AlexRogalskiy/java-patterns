#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
MESSAGE=$(cat $SCRIPT_DIR/closing-message.txt)

while IFS= read -r number &&
  IFS= read -r title; do
  echo "Closing PR ($number): $title"
  curl -s -o /dev/null \
    -X POST \
    --data "$(jq --arg body "$MESSAGE" -n '{body: $body}')" \
    --header "authorization: Bearer $GITHUB_TOKEN" \
    --header 'content-type: application/json' \
    "https://api.github.com/repos/AlexRogalskiy/object-mappers-playground/issues/$number/comments"

  curl -s -o /dev/null \
    -X PATCH \
    --data '{"state": "close"}' \
    --header "authorization: Bearer $GITHUB_TOKEN" \
    --header 'content-type: application/json' \
    "https://api.github.com/repos/AlexRogalskiy/object-mappers-playground/pulls/$number"
done < <(curl -H "Content-Type: application/json" \
  --header "authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/search/issues?q=repo:AlexRogalskiy/object-mappers-playground+type:pr+updated:<$(date -d "-21 days" +%Y-%m-%d)+label:pending+is:open" |
  jq -r '.items[] | (.number,.title)')
