#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/ai/claude/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

mkdir -p "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/ai/claude/config/CLAUDE.md"      "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/ai/claude/config/settings.json"  "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/ai/claude/config/hooks"          "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/ai/claude/config/skills"         "${TOOL_CONFIG_DIR}"
