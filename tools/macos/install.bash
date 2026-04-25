#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-${HOME}/Projects/macos-dev-setup}"

is_macos() { [[ "$(uname)" == "Darwin" ]]; }

configure_general_settings() {
    echo "🔧 Configuring general settings..."
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    defaults write NSGlobalDomain AppleFontSmoothing -int 1
    echo "✅ General settings configured"
}

configure_keyboard() {
    echo "⌨️  Configuring keyboard..."
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    echo "✅ Keyboard configured"
}

configure_finder_settings() {
    echo "🔍 Configuring Finder..."
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write com.apple.finder AppleShowAllFiles -bool false
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    chflags nohidden ~/Library
    echo "✅ Finder configured"
}

configure_dock() {
    echo "📌 Configuring Dock..."
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock show-recents -bool false
    killall Dock 2>/dev/null || true
    echo "✅ Dock configured"
}

configure_screenshots() {
    echo "📸 Configuring screenshots..."
    mkdir -p "${HOME}/Pictures/Screenshots"
    defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
    defaults write com.apple.screencapture type -string "png"
    echo "✅ Screenshots configured"
}

configure_trackpad() {
    echo "👆 Configuring trackpad..."
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write NSGlobalDomain "com.apple.mouse.tapBehavior" -int 1
    echo "✅ Trackpad configured"
}

main() {
    echo "💻 Configuring macOS system settings"
    if ! is_macos; then
        echo "⏭️  Skipping (not on macOS)"
        return 0
    fi
    configure_general_settings
    configure_keyboard
    configure_finder_settings
    configure_dock
    configure_screenshots
    configure_trackpad
    echo ""
    echo "🎉 macOS settings done!"
}

main "$@"
