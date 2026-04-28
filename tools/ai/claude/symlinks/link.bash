#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/claude/utils.bash"
source "${DOTFILES}/tools/bash/utils.bash"

mkdir -p "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/CLAUDE.md" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/settings.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/hooks" "${TOOL_CONFIG_DIR}"
