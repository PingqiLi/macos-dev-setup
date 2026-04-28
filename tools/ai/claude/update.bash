#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🤖 Updating claude-code"
npm update -g @anthropic-ai/claude-code
