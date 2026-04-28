#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "🤖 Uninstalling claude-code"
npm uninstall -g @anthropic-ai/claude-code
