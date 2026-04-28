#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/zsh/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/shell/zsh/config/.hushlogin" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/shell/zsh/config/.zshenv" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/shell/zsh/config/.zshrc" "${TOOL_CONFIG_DIR}"
