#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""')
PROJECT=$(basename "$CWD")

case "$EVENT" in
  SessionStart)
    SEQ=$(printf '\033]0;%s\007' "$PROJECT")
    ;;
  UserPromptSubmit)
    SEQ=$(printf '\033]0;\xF0\x9F\x94\x84 %s\007' "$PROJECT")
    ;;
  Stop)
    # title + bell (dock bounce) + OSC 9 (iTerm2/WezTerm) + OSC 777 (Ghostty/Warp)
    SEQ=$(printf '\033]0;\xE2\x9C\x85 %s\007\a\033]9;%s done\007\033]777;notify;Claude Code;%s done\007' \
      "$PROJECT" "$PROJECT" "$PROJECT")
    ;;
  Notification)
    MSG=$(echo "$INPUT" | jq -r '.message // "Needs attention"')
    SEQ=$(printf '\033]0;\xe2\x8f\xb3 %s\007\a\033]9;%s\007\033]777;notify;Claude Code;%s\007' \
      "$PROJECT" "$MSG" "$MSG")
    ;;
  *)
    SEQ=$(printf '\033]0;%s\007' "$PROJECT")
    ;;
esac

jq -nc --arg seq "$SEQ" '{terminalSequence: $seq}'
