#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

cwd=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "")
event=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('hook_event_name',''))" 2>/dev/null || echo "")

if [ "$event" = "Stop" ]; then
    msg="Task complete"
else
    msg="Claude needs your input"
fi

# Focus the Ghostty terminal whose working directory matches cwd
if [ -n "$cwd" ]; then
    osascript <<APPLESCRIPT 2>/dev/null || true
tell application "Ghostty"
    set needle to "$cwd"
    set matches to every terminal whose working directory contains needle
    if (count of matches) > 0 then
        set t to item 1 of matches
        focus t
        activate
    end if
end tell
APPLESCRIPT
fi

terminal-notifier \
    -title "Claude Code" \
    -message "$msg" \
    -sound Glass \
    -activate com.mitchellh.ghostty
