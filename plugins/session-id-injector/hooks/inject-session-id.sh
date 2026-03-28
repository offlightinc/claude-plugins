#!/bin/bash
# Inject CLAUDE_CODE_SESSION_ID into the session environment.
# Reads session_id from hook JSON input and persists it via CLAUDE_ENV_FILE
# so that plugins (e.g. ralph-loop) can use it for session isolation.

HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""')

if [ -n "$SESSION_ID" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "export CLAUDE_CODE_SESSION_ID=$SESSION_ID" >> "$CLAUDE_ENV_FILE"
fi

exit 0
