#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/bash/utils.bash"

info "🧠 Installing mempalace (verbatim AI memory CLI)"

if ! command -v uv >/dev/null 2>&1; then
  echo "❌ uv not found. Install uv first (tools/uv)."
  exit 1
fi

uv tool install mempalace
