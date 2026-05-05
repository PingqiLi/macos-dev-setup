#!/usr/bin/env zsh
set -euo pipefail

DOTFILES="${DOTFILES:-${HOME}/Projects/macos-dev-setup}"

info "🦀 Installing Node via fnm"

if ! command -v fnm &>/dev/null; then
  printf "\n🍺 Installing fnm via Homebrew...\n"
  brew install fnm
fi

# Ensure fnm is active in this shell session
if ! eval "$(fnm env --use-on-cd --shell zsh)"; then
  printf "\n❌ Failed to initialize fnm environment.\n"
  return_or_exit 1
fi

# Prefer stable LTS to avoid odd non-LTS latest picks and parsing failures.
if ! fnm list | grep -q '\*'; then
  printf "\n⬇️  Installing latest Node LTS...\n"
  fnm install --lts
fi

# Always set default to latest LTS to keep deterministic bootstrap behavior.
lts_version="$(fnm ls-remote --lts | tail -n 1 | tr -d '[:space:]')"
if [[ -z "${lts_version}" ]]; then
  printf "\n❌ Could not resolve latest LTS Node version from fnm ls-remote --lts\n"
  return_or_exit 1
fi

if ! fnm list | grep -q "${lts_version}"; then
  printf "\n⬇️  Installing Node %s (LTS)...\n" "${lts_version}"
  fnm install "${lts_version}"
fi

fnm default "${lts_version}"
fnm use "${lts_version}"

printf "\n🚀 Finished installing Node %s.\n" "${lts_version}"
