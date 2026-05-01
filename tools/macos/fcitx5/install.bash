#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"

info "⌨️  Installing fcitx5"

FCITX5_APP="/Library/Input Methods/Fcitx5.app"

if [[ -d "${FCITX5_APP}" ]]; then
  version=$(defaults read "${FCITX5_APP}/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  echo "✅ fcitx5 ${version} already installed at ${FCITX5_APP}"
  exit 0
fi

echo "⚠️  fcitx5 not found. Install manually from GitHub releases:"
echo "   https://github.com/fcitx-contrib/fcitx5-macos/releases"
echo "   Download the .pkg, double-click to install, then re-run this script."
exit 1
