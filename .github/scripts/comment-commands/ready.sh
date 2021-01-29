#!/usr/bin/env bash

#doc: Dismiss all the blocking reviews by github-actions bot
MESSAGE="Blocking review request is removed."
URL="$(jq -r '.issue.pull_request.url' "$GITHUB_EVENT_PATH")/reviews"
set +x #GITHUB_TOKEN
curl -s "$URL" |
  jq -r '.[] | [.user.login, .id] | @tsv' |
  grep github-actions |
  awk '{print $2}' |
  xargs -n1 -IISSUE_ID curl -s -o /dev/null \
    -X PUT \
    --data "$(jq --arg message "$MESSAGE" -n '{message: $message}')" \
    --header "authorization: Bearer $GITHUB_TOKEN" \
    "$URL"/ISSUE_ID/dismissals

curl -s -o /dev/null \
  -X DELETE \
  --header "authorization: Bearer $GITHUB_TOKEN" \
  "$(jq -r '.issue.url' "$GITHUB_EVENT_PATH")/labels/pending"
