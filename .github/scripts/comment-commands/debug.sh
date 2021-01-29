#!/usr/bin/env bash

#doc: Show current event json to debug problems

echo "\`\`\`"
cat "$GITHUB_EVENT_PATH"
echo "\`\`\`"
