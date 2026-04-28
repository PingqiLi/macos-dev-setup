#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🧠 Updating mempalace"
uv tool upgrade mempalace
