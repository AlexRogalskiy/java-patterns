#!/usr/bin/env bash

set +x #don't show GITHUB_TOKEN

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
BODY=$(jq -r .comment.body "$GITHUB_EVENT_PATH")
LINES=$(printf "%s" "$BODY" | wc -l)
if [ "$LINES" == "0" ]; then
  if [[ "$BODY" == /* ]]; then
    echo "Command $BODY is received"
    COMMAND=$(echo "$BODY" | awk '{print $1}' | sed 's/\///')
    ARGS=$(echo "$BODY" | cut -d ' ' -f2-)
    if [ -f "$SCRIPT_DIR/comment-commands/$COMMAND.sh" ]; then
      RESPONSE=$("$SCRIPT_DIR/comment-commands/$COMMAND.sh" "${ARGS[@]}")
      EXIT_CODE=$?
      if [[ $EXIT_CODE != 0 ]]; then
        # shellcheck disable=SC2124
        RESPONSE="> $BODY

Script execution has been failed with exit code $EXIT_CODE. Please check the output of the github action run to get more information.
\`\`\`
$RESPONSE
\`\`\`
"
      fi
    else
      RESPONSE="No such command. \`$COMMAND\` $("$SCRIPT_DIR/comment-commands/help.sh")"
    fi
    if [ "$GITHUB_TOKEN" ]; then
      set +x #do not display the GITHUB_TOKEN
      COMMENTS_URL=$(jq -r .issue.comments_url "$GITHUB_EVENT_PATH")
      curl -s \
        --data "$(jq --arg body "$RESPONSE" -n '{body: $body}')" \
        --header "authorization: Bearer $GITHUB_TOKEN" \
        --header 'content-type: application/json' \
        "$COMMENTS_URL"
    else
      echo "$RESPONSE"
    fi
  fi
fi
