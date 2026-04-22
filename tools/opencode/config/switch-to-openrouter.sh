#!/bin/bash
# Switch oh-my-opencode from Gemini to OpenRouter models
# Triggered automatically when Gemini subscription expires

CONFIG_DIR="$HOME/.config/opencode"
LOG_FILE="$CONFIG_DIR/switch-to-openrouter.log"

echo "$(date): Starting Gemini -> OpenRouter switch" >> "$LOG_FILE"

# 1. Replace oh-my-opencode.json with OpenRouter fallback version
cp "$CONFIG_DIR/oh-my-opencode.openrouter-fallback.json" "$CONFIG_DIR/oh-my-opencode.json"
echo "$(date): oh-my-opencode.json replaced with OpenRouter config" >> "$LOG_FILE"

# 2. Remove opencode-antigravity-auth plugin from opencode.json
if command -v python3 &> /dev/null; then
  python3 -c "
import json
cfg_path = '$CONFIG_DIR/opencode.json'
with open(cfg_path) as f:
    cfg = json.load(f)
cfg['plugin'] = [p for p in cfg.get('plugin', []) if 'antigravity' not in p]
with open(cfg_path, 'w') as f:
    json.dump(cfg, f, indent=2)
print('Removed antigravity plugin from opencode.json')
" >> "$LOG_FILE" 2>&1
fi

# 3. Send macOS notification
osascript -e 'display notification "Gemini models switched to OpenRouter (Qwen/MiniMax/GLM). Run: opencode auth logout to remove Google credential." with title "OpenCode Config Updated"' 2>/dev/null

echo "$(date): Switch complete" >> "$LOG_FILE"

# 4. Self-cleanup: unload and remove the launchd plist
launchctl bootout gui/$(id -u) "$HOME/Library/LaunchAgents/com.opencode.switch-to-openrouter.plist" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/com.opencode.switch-to-openrouter.plist"
echo "$(date): Scheduled task self-removed" >> "$LOG_FILE"
