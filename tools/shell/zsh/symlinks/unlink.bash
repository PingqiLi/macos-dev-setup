#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/zsh/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

debug "🔗 Removing symlinked config files"

trash "${TOOL_CONFIG_DIR}/.hushlogin"
trash "${TOOL_CONFIG_DIR}/.zprofile"
trash "${TOOL_CONFIG_DIR}/.zshenv"
trash "${TOOL_CONFIG_DIR}/.zshrc"
