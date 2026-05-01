#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"

info "⌨️  Updating fcitx5"

FCITX5_APP="/Library/Input Methods/Fcitx5.app"
current=$(defaults read "${FCITX5_APP}/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
echo "Current version: ${current}"
echo "Check for updates: https://github.com/fcitx-contrib/fcitx5-macos/releases"
