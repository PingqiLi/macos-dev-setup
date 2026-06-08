#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-${HOME}/Projects/macos-dev-setup}"
HOMECONFIG="${HOME}/.config"

symlink() {
  local source_file="$1"
  local target_dir="$2"
  local file_name
  file_name="$(basename "$source_file")"
  local target_path="${target_dir}/${file_name}"

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_file" ]; then
    return 0
  fi

  if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
    echo "⚠️  Backing up existing file: ${target_path} → ${target_path}.bak"
    mv "$target_path" "${target_path}.bak"
  fi

  mkdir -p "$target_dir"
  ln -sfv "$source_file" "$target_dir"
}

echo "🔗 Updating symlinks"

# Claude
symlink "${DOTFILES}/tools/ai/claude/config/CLAUDE.md"       "${HOME}/.claude"
symlink "${DOTFILES}/tools/ai/claude/config/settings.json"    "${HOME}/.claude"
symlink "${DOTFILES}/tools/ai/claude/config/hooks"            "${HOME}/.claude"
symlink "${DOTFILES}/tools/ai/claude/config/skills"           "${HOME}/.claude"

# Shell
symlink "${DOTFILES}/tools/shell/zsh/config/.hushlogin"  "${HOME}"
symlink "${DOTFILES}/tools/shell/zsh/config/.zprofile"   "${HOME}"
symlink "${DOTFILES}/tools/shell/zsh/config/.zshenv"     "${HOME}"
symlink "${DOTFILES}/tools/shell/zsh/config/.zshrc"      "${HOME}"

# Git
symlink "${DOTFILES}/tools/git/github/config/config.yml" "${HOMECONFIG}/gh"
symlink "${DOTFILES}/tools/git/git/config/config"        "${HOMECONFIG}/git"
symlink "${DOTFILES}/tools/git/git/config/config.work"   "${HOMECONFIG}/git"

# Terminal
symlink "${DOTFILES}/tools/terminal/ghostty/config/config" "${HOMECONFIG}/ghostty"

# Shell tools with config
symlink "${DOTFILES}/tools/shell/powerlevel10k/config/p10k.zsh" "${HOMECONFIG}/powerlevel10k"

# Multiplexer
symlink "${DOTFILES}/tools/multiplexer/tmux/config/gitmux.conf" "${HOMECONFIG}/tmux"
symlink "${DOTFILES}/tools/multiplexer/tmux/config/tmux.conf"   "${HOMECONFIG}/tmux"

# Node
symlink "${DOTFILES}/tools/node/node/config/.npmrc" "${HOMECONFIG}/npm"

# Containers
symlink "${DOTFILES}/tools/containers/lazydocker/config/config.yml" "${HOMECONFIG}/lazydocker"

# Btop
symlink "${DOTFILES}/tools/shell/btop/config/btop.conf" "${HOMECONFIG}/btop"

# Lazygit
symlink "${DOTFILES}/tools/git/lazygit/config/config.yml" "${HOMECONFIG}/lazygit"

# OpenCode
symlink "${DOTFILES}/tools/ai/opencode/config/opencode.json"       "${HOMECONFIG}/opencode"
symlink "${DOTFILES}/tools/ai/opencode/config/oh-my-opencode.json" "${HOMECONFIG}/opencode"

# fcitx5
mkdir -p "${HOMECONFIG}/fcitx5/conf"
mkdir -p "${HOME}/.local/share/fcitx5/rime"
symlink "${DOTFILES}/tools/macos/fcitx5/config/fcitx5/config"                        "${HOMECONFIG}/fcitx5"
symlink "${DOTFILES}/tools/macos/fcitx5/config/fcitx5/profile"                       "${HOMECONFIG}/fcitx5"
symlink "${DOTFILES}/tools/macos/fcitx5/config/fcitx5/conf/rime.conf"                "${HOMECONFIG}/fcitx5/conf"
symlink "${DOTFILES}/tools/macos/fcitx5/config/fcitx5/conf/macosfrontend.conf"       "${HOMECONFIG}/fcitx5/conf"
symlink "${DOTFILES}/tools/macos/fcitx5/config/fcitx5/conf/macosnotifications.conf"  "${HOMECONFIG}/fcitx5/conf"
symlink "${DOTFILES}/tools/macos/fcitx5/config/rime/default.custom.yaml"             "${HOME}/.local/share/fcitx5/rime"

# VSCode
VSCODEUSER="${HOME}/Library/Application Support/Code/User"
symlink "${DOTFILES}/tools/apps/vscode/config/keybindings.json" "${VSCODEUSER}"
symlink "${DOTFILES}/tools/apps/vscode/config/settings.json"    "${VSCODEUSER}"
symlink "${DOTFILES}/tools/apps/vscode/config/snippets"         "${VSCODEUSER}"

# Project-level skill symlink (source of truth lives in tools/ai/claude/config/skills/)
mkdir -p "${DOTFILES}/.claude/skills"
ln -sf "${DOTFILES}/tools/ai/claude/config/skills/macos-setup" \
       "${DOTFILES}/.claude/skills/macos-setup" 2>/dev/null || true

echo "🎉 All symlinks up to date"
