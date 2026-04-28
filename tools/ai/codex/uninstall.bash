#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🤖 Uninstalling codex"
brew uninstall --cask codex
