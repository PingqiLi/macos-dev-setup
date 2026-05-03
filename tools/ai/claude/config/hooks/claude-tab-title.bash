#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""')
PROJECT=$(basename "$CWD")

case "$EVENT" in
  SessionStart)     TITLE="$PROJECT" ;;
  UserPromptSubmit) TITLE="🔄 $PROJECT" ;;
  Stop)             TITLE="✅ $PROJECT" ;;
  Notification)     TITLE="⏳ $PROJECT" ;;
  *)                TITLE="$PROJECT" ;;
esac

printf '\033]0;%s\007' "$TITLE" > /dev/tty
