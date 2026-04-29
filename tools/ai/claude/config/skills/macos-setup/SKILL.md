---
name: macos-setup
description: Interactively set up or update a macOS development environment from the macos-dev-setup dotfiles repo. Invoke when user wants to configure a new Mac, add tool groups, or update existing tools.
---

# macOS Development Environment Setup

## When to use this skill
- User says "set up my Mac", "configure my dev environment", "install dotfiles"
- User wants to add a specific tool group (e.g. "install the AI tools")
- User says "update all my tools"

## Prerequisites — Detect repo path first

**Always run this before anything else.** The repo can be cloned anywhere; never assume the path.

```sh
DOTFILES=$(git rev-parse --show-toplevel 2>/dev/null)
```

If that fails (not in a git repo), ask the user where they cloned the repo:
```sh
# Fallback: ask user, then set manually
# DOTFILES=/path/to/wherever/they/cloned
```

Verify it's the right repo:
```sh
ls "${DOTFILES}/groups.toml"
```

If `groups.toml` is missing, the user isn't inside the repo. Guide them to clone it first:
```sh
git clone https://github.com/PingqiLi/macos-dev-setup ~/Projects/macos-dev-setup
cd ~/Projects/macos-dev-setup
```
Then re-detect: `DOTFILES=$(git rev-parse --show-toplevel)`

**Keep `$DOTFILES` set for all subsequent steps in this session.**

## Workflow

### Step 1 — Detect System State

```sh
echo "Repo: ${DOTFILES}"
echo "Architecture: $(uname -m)"
echo "Homebrew: $(command -v brew >/dev/null && brew --version | head -1 || echo NOT INSTALLED)"
echo ""
echo "--- Tool groups present ---"
command -v zsh    >/dev/null && echo "✅ shell"       || echo "❌ shell"
command -v git    >/dev/null && echo "✅ git"         || echo "❌ git"
command -v uv     >/dev/null && echo "✅ python"      || echo "❌ python"
command -v node   >/dev/null && echo "✅ node"        || echo "❌ node"
command -v claude >/dev/null && echo "✅ ai"          || echo "❌ ai"
/Applications/Ghostty.app/Contents/MacOS/ghostty --version >/dev/null 2>&1 && echo "✅ terminal" || echo "❌ terminal"
command -v tmux   >/dev/null && echo "✅ multiplexer" || echo "— multiplexer (optional)"
command -v docker >/dev/null && echo "✅ containers"  || echo "— containers (optional)"
command -v code   >/dev/null && echo "✅ apps"        || echo "— apps (optional)"
```

### Step 2 — SSH / GitHub Setup (optional)

Ask user: "Do you want to set up SSH keys for GitHub? (y/n)"

If **yes**:
```sh
ssh-keygen -t ed25519 -C "$(git config --global user.email 2>/dev/null || echo 'your@email.com')"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo ""
echo "Add this public key at https://github.com/settings/keys :"
cat ~/.ssh/id_ed25519.pub
```
Wait for user to confirm key is added, then verify:
```sh
ssh -T git@github.com
```
Expected: `Hi username! You've successfully authenticated`

If **no**: skip.

### Step 3 — Confirm Installation Scope

Present this menu to the user:

```
Required groups (always installed):
  ✅ shell      — Shell 核心（zsh/补全/字体/CLI 增强）
  ✅ git        — Git 工具链（git/gh/lazygit）
  ✅ macos      — macOS 系统设置与工具

Optional groups — confirm each (default shown):
  [y] python      — Python 开发（uv）
  [y] node        — Node.js 开发（fnm + pnpm）
  [y] ai          — AI 编码工具（Claude Code / Codex / OpenCode / mempalace）
  [y] terminal    — 终端模拟器（Ghostty）
  [n] multiplexer — 终端复用（tmux）
  [n] containers  — 容器工具（OrbStack / lazydocker）
  [n] apps        — GUI 应用（VSCode / Obsidian / Chrome / Edge）
```

Ask user to confirm or change selections. Build a list of selected groups.

### Step 4 — Execute Installation

Run in this exact order. Use `$DOTFILES` (set in Prerequisites) for all paths.

**Bootstrap (always):**
```sh
bash "${DOTFILES}/tools/_bootstrap/homebrew/install.bash"
bash "${DOTFILES}/tools/_bootstrap/zsh-switch/install.bash"
```

**Required groups:**
```sh
for tool in "${DOTFILES}/tools/shell/"*/install.bash; do bash "$tool"; done
for tool in "${DOTFILES}/tools/git/"*/install.bash;   do bash "$tool"; done
for tool in "${DOTFILES}/tools/macos/"*/install.bash; do bash "$tool"; done
```

**Each selected optional group** (replace GROUP with actual names from Step 3):
```sh
for tool in "${DOTFILES}/tools/GROUP/"*/install.bash; do bash "$tool"; done
```

**Symlinks:**
```sh
DOTFILES="${DOTFILES}" bash "${DOTFILES}/features/install/zsh/symlinks.zsh"
```

For each install.bash: show progress, log errors but continue (non-fatal). Halt only if bootstrap fails.

### Step 5 — Verify

```sh
echo "=== Installation Verification ==="
command -v zsh    >/dev/null && echo "✅ shell:  $(zsh --version)"         || echo "❌ shell:  zsh missing"
command -v git    >/dev/null && echo "✅ git:    $(git --version)"          || echo "❌ git:    missing"
command -v gh     >/dev/null && echo "✅ gh:     $(gh --version | head -1)" || echo "❌ gh:     missing"
command -v uv     >/dev/null && echo "✅ python: $(uv --version)"           || echo "— python: not selected"
command -v node   >/dev/null && echo "✅ node:   $(node --version)"         || echo "— node:   not selected"
command -v claude >/dev/null && echo "✅ claude: installed"                  || echo "— claude: not selected"
/Applications/Ghostty.app/Contents/MacOS/ghostty --version >/dev/null 2>&1 \
  && echo "✅ ghostty: installed" || echo "— ghostty: not selected"
```

Report any ❌ failures to user with suggested fix.

### Step 6 — Next Steps

Tell user:

1. **Reload shell:** `exec zsh`
2. **Add API keys** to `~/.zshrc.local`:
   ```sh
   cp "${DOTFILES}/tools/shell/zsh/config/zshrc.local.example" ~/.zshrc.local
   $EDITOR ~/.zshrc.local
   # Add: ANTHROPIC_API_KEY, OPENROUTER_API_KEY, OPENAI_API_KEY
   ```
3. **Ghostty window size:** option-click the green button once — Ghostty remembers the size permanently.

---

## Update Mode

If user says "update all tools" or "upgrade everything":

```sh
DOTFILES=$(git rev-parse --show-toplevel)
for update_script in "${DOTFILES}/tools/"*/*/update.bash; do
  [[ -f "$update_script" ]] || continue
  group=$(basename "$(dirname "$(dirname "$update_script")")")
  tool=$(basename "$(dirname "$update_script")")
  printf "\n→ Updating [%s/%s]...\n" "$group" "$tool"
  bash "$update_script"
done
```

For mempalace specifically (installed from develop branch until v3.3.4):
```sh
uv tool upgrade mempalace
```
