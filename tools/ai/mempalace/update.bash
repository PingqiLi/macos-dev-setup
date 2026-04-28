#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "🧠 Updating mempalace"
uv tool upgrade mempalace
