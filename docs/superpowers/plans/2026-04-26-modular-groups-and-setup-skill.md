# Modular Groups + Setup Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize `tools/` into group-based subdirectories and write a Claude Code skill that guides users through selective, idempotent installation.

**Architecture:** All tool directories move from flat `tools/{tool}/` to nested `tools/{group}/{tool}/`. A `groups.toml` manifest stores group metadata (required, default, description). A `SKILL.md` at `.claude/skills/macos-setup/` drives agent-guided installation using the new structure.

**Tech Stack:** bash, zsh, TOML (plain text, no parser needed in scripts), Claude Code skill markdown format

---

## File Map

### Created
- `tools/_bootstrap/homebrew/install.bash` — extracted from `features/install/zsh/homebrew.zsh`
- `tools/_bootstrap/zsh-switch/install.bash` — extracted from `features/install/zsh/zsh.zsh`
- `tools/shell/{bat,eza,fzf,zoxide,vim,powerlevel10k,fonts,zsh,bash,atuin,btop,direnv,httpie,jq,sd,tree,yq}/` — moved from `tools/`
- `tools/git/{git,github,lazygit}/` — moved
- `tools/macos/{macos,m,raycast}/` — moved
- `tools/python/uv/` — moved
- `tools/node/{fnm,node,pnpm}/` — moved (pnpm extracted from cli-extras)
- `tools/ai/{claude,codex,opencode,mempalace}/` — moved
- `tools/terminal/ghostty/` — moved
- `tools/multiplexer/tmux/` — moved
- `tools/containers/{orbstack,lazydocker}/` — moved
- `tools/apps/{browsers,obsidian,vscode}/` — moved
- `groups.toml` — group metadata manifest
- `.claude/skills/macos-setup/SKILL.md` — project-level skill (symlink target)
- `tools/ai/claude/config/skills/macos-setup/SKILL.md` — skill source of truth

### Modified
- `features/install/zsh/tools.zsh` — glob `tools/*/` → `tools/*/*/`, skip `_bootstrap`
- `features/install/zsh/symlinks.zsh` — remove stale refs, update all tool paths
- All `*.bash` / `*.zsh` in tools: `tools/bash/utils.bash` → `tools/shell/bash/utils.bash`
- `tools/ai/claude/symlinks/link.bash` — add skills dir symlink
- `CLAUDE.md` — update path references
- `README.md` — update structure diagram

### Deleted
- `tools/mise/` — redundant with uv
- `tools/sesh/` — no longer used
- `tools/cli-extras/` — dissolved into shell/ and node/

---

## Task 1: Remove deprecated tools (mise, sesh, cli-extras)

**Files:**
- Delete: `tools/mise/`
- Delete: `tools/sesh/`
- Delete: `tools/cli-extras/` (after extracting pnpm)

- [ ] **Step 1: Create standalone dirs for tools that only existed in cli-extras Brewfile**

These tools had no individual directory — they'll lose their install source when cli-extras is deleted:

```bash
cd ~/Projects/macos-dev-setup

# Tools moving to shell/
for tool in atuin direnv yq tree; do
  mkdir -p "tools/shell-tmp-${tool}"
  echo "brew \"${tool}\"" > "tools/shell-tmp-${tool}/Brewfile"
done

# gnu-sed and coreutils go into shell/zsh Brewfile (already partially there)
# pnpm moves to node/
mkdir -p tools/node-pnpm-tmp
cat > tools/node-pnpm-tmp/Brewfile << 'EOF'
brew "pnpm"
EOF
cat > tools/node-pnpm-tmp/install.bash << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "📦 Installing pnpm"
brew bundle --file="${DOTFILES}/tools/node/pnpm/Brewfile"
EOF
```

- [ ] **Step 2: Remove deprecated dirs**

```bash
cd ~/Projects/macos-dev-setup
git rm -r tools/mise tools/sesh tools/cli-extras
```

Expected: git confirms removal of those files.

- [ ] **Step 3: Verify shellcheck passes on remaining scripts**

```bash
cd ~/Projects/macos-dev-setup
shellcheck tools/**/*.bash features/**/*.bash 2>&1 | head -30
```

Expected: no errors (only warnings for missing DOTFILES env var which is expected at lint time).

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove mise, sesh, cli-extras (deprecated)"
```

---

## Task 2: Create group directory structure and move tools

**Files:** All `tools/{tool}/` → `tools/{group}/{tool}/`

- [ ] **Step 1: Create group directories**

```bash
cd ~/Projects/macos-dev-setup
mkdir -p tools/_bootstrap/homebrew tools/_bootstrap/zsh-switch
mkdir -p tools/shell tools/git tools/macos tools/python tools/node
mkdir -p tools/ai tools/terminal tools/multiplexer tools/containers tools/apps
```

- [ ] **Step 2: Move shell group tools**

```bash
cd ~/Projects/macos-dev-setup
for tool in bash bat eza fzf zoxide vim powerlevel10k fonts zsh atuin btop direnv httpie jq sd tree yq; do
  [[ -d "tools/$tool" ]] && git mv "tools/$tool" "tools/shell/$tool"
done
```

- [ ] **Step 3: Move git group tools**

```bash
cd ~/Projects/macos-dev-setup
git mv tools/git tools/git-tmp   # avoid name collision with group dir
git mv tools/git-tmp tools/git/git
git mv tools/github tools/git/github
git mv tools/lazygit tools/git/lazygit
```

- [ ] **Step 4: Move macos group tools**

```bash
cd ~/Projects/macos-dev-setup
git mv tools/macos tools/macos-tmp
git mv tools/macos-tmp tools/macos/macos
git mv tools/m tools/macos/m
git mv tools/raycast tools/macos/raycast
```

- [ ] **Step 5: Move python, node, ai, terminal, multiplexer, containers, apps**

```bash
cd ~/Projects/macos-dev-setup
git mv tools/uv tools/python/uv
git mv tools/fnm tools/node/fnm
git mv tools/node tools/node-tmp && git mv tools/node-tmp tools/node/node
mv tools/node-pnpm-tmp tools/node/pnpm && git add tools/node/pnpm
git mv tools/claude tools/ai/claude
git mv tools/codex tools/ai/codex
git mv tools/opencode tools/ai/opencode
git mv tools/mempalace tools/ai/mempalace
git mv tools/ghostty tools/terminal/ghostty
git mv tools/tmux tools/multiplexer/tmux
git mv tools/orbstack tools/containers/orbstack
git mv tools/lazydocker tools/containers/lazydocker
git mv tools/browsers tools/apps/browsers
git mv tools/obsidian tools/apps/obsidian
git mv tools/vscode tools/apps/vscode
```

- [ ] **Step 6: Create _bootstrap scripts**

```bash
cat > ~/Projects/macos-dev-setup/tools/_bootstrap/homebrew/install.bash << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

if command -v brew >/dev/null 2>&1; then
  echo "🍺 Homebrew already installed: $(brew --version | head -1)"
  exit 0
fi

echo "🍺 Installing Homebrew..."
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | arch -arm64 /bin/bash --login
eval "$(/opt/homebrew/bin/brew shellenv)"
echo "✅ Homebrew installed: $(brew --version | head -1)"
EOF

cat > ~/Projects/macos-dev-setup/tools/_bootstrap/zsh-switch/install.bash << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

shell_path="/opt/homebrew/bin/zsh"

if [[ ! -x "$shell_path" ]]; then
  echo "❌ brew zsh not found. Install Homebrew first."
  exit 1
fi

if ! grep -q "$shell_path" /etc/shells; then
  echo "📄 Adding $shell_path to /etc/shells"
  sudo sh -c "echo ${shell_path} >> /etc/shells"
fi

if [[ "$SHELL" == "$shell_path" ]]; then
  echo "🐚 Already using brew zsh"
  exit 0
fi

echo "🐚 Switching default shell to $shell_path"
sudo chsh -s "$shell_path" "$USER"
echo "✅ Shell changed. Restart terminal to take effect."
EOF

chmod +x tools/_bootstrap/homebrew/install.bash
chmod +x tools/_bootstrap/zsh-switch/install.bash
git add tools/_bootstrap/
```

- [ ] **Step 7: Verify structure**

```bash
find ~/Projects/macos-dev-setup/tools -maxdepth 2 -type d | sort
```

Expected: directories like `tools/_bootstrap/homebrew`, `tools/shell/zsh`, `tools/ai/claude`, etc.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "refactor: reorganize tools/ into group-based subdirectories"
```

---

## Task 3: Update all internal `tools/bash/utils.bash` path references

**Files:** All `*.bash` and `*.zsh` under `tools/` and `features/`

- [ ] **Step 1: Bulk replace with sed**

```bash
cd ~/Projects/macos-dev-setup
find . \( -name "*.bash" -o -name "*.zsh" \) \
  ! -path "./.git/*" \
  ! -path "./_reference-ooloth/*" \
  -exec sed -i '' 's|tools/bash/utils\.bash|tools/shell/bash/utils.bash|g' {} +
```

- [ ] **Step 2: Verify no old path remains**

```bash
grep -r 'tools/bash/utils\.bash' ~/Projects/macos-dev-setup \
  --include="*.bash" --include="*.zsh" \
  --exclude-dir=".git" --exclude-dir="_reference-ooloth"
```

Expected: no output.

- [ ] **Step 3: Verify new path is correct**

```bash
grep -r 'tools/shell/bash/utils\.bash' ~/Projects/macos-dev-setup \
  --include="*.bash" --include="*.zsh" \
  --exclude-dir=".git" | wc -l
```

Expected: same count as before (~70).

- [ ] **Step 4: Test utils.bash loads correctly**

```bash
DOTFILES=~/Projects/macos-dev-setup bash -c 'source "${DOTFILES}/tools/shell/bash/utils.bash" && info "utils.bash OK"'
```

Expected: `utils.bash OK` printed without errors.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor: update tools/bash/ → tools/shell/bash/ path references"
```

---

## Task 4: Update feature discovery scripts

**Files:**
- Modify: `features/install/zsh/tools.zsh`
- Modify: `features/install/zsh/symlinks.zsh`

- [ ] **Step 1: Update tools.zsh glob pattern**

```bash
cat > ~/Projects/macos-dev-setup/features/install/zsh/tools.zsh << 'EOF'
#!/usr/bin/env zsh
# Run install.bash for every tool that has one, skipping _bootstrap (handled separately).

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🧩 Installing all tool modules"

for install_script in "${DOTFILES}"/tools/*/*/install.bash; do
  group=$(basename "$(dirname "$(dirname "${install_script}")")")
  tool_name=$(basename "$(dirname "${install_script}")")
  [[ "$group" == "_bootstrap" ]] && continue
  printf "\n→ [%s] Installing %s...\n" "${group}" "${tool_name}"
  bash "${install_script}"
done
EOF
```

- [ ] **Step 2: Rewrite symlinks.zsh to remove stale refs and update paths**

```bash
cat > ~/Projects/macos-dev-setup/features/install/zsh/symlinks.zsh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${HOME}/Projects/macos-dev-setup"
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
symlink "${DOTFILES}/tools/ai/opencode/config/opencode.json"          "${HOMECONFIG}/opencode"
symlink "${DOTFILES}/tools/ai/opencode/config/oh-my-opencode.json"    "${HOMECONFIG}/opencode"

# VSCode
VSCODEUSER="${HOME}/Library/Application Support/Code/User"
symlink "${DOTFILES}/tools/apps/vscode/config/keybindings.json" "${VSCODEUSER}"
symlink "${DOTFILES}/tools/apps/vscode/config/settings.json"    "${VSCODEUSER}"
symlink "${DOTFILES}/tools/apps/vscode/config/snippets"         "${VSCODEUSER}"

# Project-level skill (symlink to source of truth)
mkdir -p "${DOTFILES}/.claude/skills"
ln -sf "${DOTFILES}/tools/ai/claude/config/skills/macos-setup" \
       "${DOTFILES}/.claude/skills/macos-setup" 2>/dev/null || true

echo "🎉 All symlinks up to date"
EOF
```

- [ ] **Step 3: Run shellcheck on updated scripts**

```bash
shellcheck ~/Projects/macos-dev-setup/features/install/zsh/tools.zsh
shellcheck ~/Projects/macos-dev-setup/features/install/zsh/symlinks.zsh
```

Expected: no errors.

- [ ] **Step 4: Dry-run symlinks script (no sudo needed)**

```bash
DOTFILES=~/Projects/macos-dev-setup bash -n ~/Projects/macos-dev-setup/features/install/zsh/symlinks.zsh && echo "syntax OK"
```

Expected: `syntax OK`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor: update discovery globs and symlinks for new group structure"
```

---

## Task 5: Update tools.zsh (shell config) source paths

**Files:** `tools/shell/zsh/config/tools.zsh`

- [ ] **Step 1: Verify find-based discovery already handles nested dirs**

```bash
find ~/Projects/macos-dev-setup/tools -name "shell.zsh" | sort | head -10
```

Expected: paths like `tools/shell/bat/shell.zsh`, `tools/ai/claude/shell.zsh`, etc. The existing `find "${DOTFILES}/tools"` call in `tools/shell/zsh/config/tools.zsh` already works recursively — no change needed to the discovery logic.

- [ ] **Step 2: Reload shell config and verify no errors**

```bash
DOTFILES=~/Projects/macos-dev-setup zsh -c 'source ~/Projects/macos-dev-setup/tools/shell/zsh/config/tools.zsh && echo "tools.zsh OK"' 2>&1
```

Expected: `tools.zsh OK` (some warnings about missing tools are acceptable).

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: verify shell config tools.zsh works with new nested structure"
```

---

## Task 6: Update claude symlinks to include skills dir

**Files:** `tools/ai/claude/symlinks/link.bash`

- [ ] **Step 1: Read current link.bash**

```bash
cat ~/Projects/macos-dev-setup/tools/ai/claude/symlinks/link.bash
```

- [ ] **Step 2: Add skills symlink line**

Open `tools/ai/claude/symlinks/link.bash` and add after the existing symlink calls:

```bash
symlink "${DOTFILES}/tools/ai/claude/config/hooks"  "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/ai/claude/config/skills" "${TOOL_CONFIG_DIR}"
```

- [ ] **Step 3: Create the skills dir and placeholder**

```bash
mkdir -p ~/Projects/macos-dev-setup/tools/ai/claude/config/skills/macos-setup
touch ~/Projects/macos-dev-setup/tools/ai/claude/config/skills/macos-setup/.gitkeep
git add tools/ai/claude/config/skills/
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: add skills dir to claude symlinks"
```

---

## Task 7: Write groups.toml

**Files:** Create `groups.toml`

- [ ] **Step 1: Write groups.toml**

```bash
cat > ~/Projects/macos-dev-setup/groups.toml << 'EOF'
[shell]
description = "Shell 核心（zsh/补全/字体/CLI 增强）"
required = true
default = true

[git]
description = "Git 工具链（git/gh/lazygit）"
required = true
default = true

[macos]
description = "macOS 系统设置与工具（defaults/m-cli/Raycast）"
required = true
default = true

[python]
description = "Python 开发（uv）"
required = false
default = true

[node]
description = "Node.js 开发（fnm + pnpm）"
required = false
default = true

[ai]
description = "AI 编码工具（Claude Code / Codex / OpenCode / mempalace）"
required = false
default = true

[terminal]
description = "终端模拟器（Ghostty）"
required = false
default = true

[multiplexer]
description = "终端复用（tmux + gitmux）"
required = false
default = false

[containers]
description = "容器工具（OrbStack / lazydocker）"
required = false
default = false

[apps]
description = "GUI 应用（VSCode / Obsidian / Chrome / Edge）"
required = false
default = false
EOF
```

- [ ] **Step 2: Verify it parses as valid TOML**

```bash
python3 -c "
import re
with open('groups.toml') as f:
    content = f.read()
groups = re.findall(r'^\[(\w+)\]', content, re.MULTILINE)
print('Groups found:', groups)
assert len(groups) == 10, f'Expected 10 groups, got {len(groups)}'
print('OK')
"
```

Expected:
```
Groups found: ['shell', 'git', 'macos', 'python', 'node', 'ai', 'terminal', 'multiplexer', 'containers', 'apps']
OK
```

- [ ] **Step 3: Commit**

```bash
git add groups.toml
git commit -m "feat: add groups.toml manifest"
```

---

## Task 8: Write SKILL.md

**Files:**
- Create: `tools/ai/claude/config/skills/macos-setup/SKILL.md`
- Create: `.claude/skills/macos-setup/` → symlink to above

- [ ] **Step 1: Write SKILL.md**

```bash
cat > ~/Projects/macos-dev-setup/tools/ai/claude/config/skills/macos-setup/SKILL.md << 'SKILLEOF'
---
name: macos-setup
description: Interactively set up or update a macOS development environment from the macos-dev-setup dotfiles repo. Invoke when user wants to configure a new Mac, add tool groups, or update existing tools.
---

# macOS Development Environment Setup

## When to use this skill
- User says "set up my Mac", "configure my dev environment", "install dotfiles"
- User wants to add a specific tool group (e.g. "install the AI tools")
- User says "update all my tools"

## Prerequisites
You must be running from inside the cloned macos-dev-setup repo:
```sh
ls ~/Projects/macos-dev-setup/groups.toml
```
If the file doesn't exist, clone first:
```sh
git clone https://github.com/PingqiLi/macos-dev-setup ~/Projects/macos-dev-setup
cd ~/Projects/macos-dev-setup
```

## Workflow

### Step 1 — Detect System State

Run and report findings:
```sh
echo "Architecture: $(uname -m)"
echo "Homebrew: $(command -v brew >/dev/null && brew --version | head -1 || echo NOT INSTALLED)"
echo ""
echo "--- Tool groups present ---"
command -v zsh  >/dev/null && echo "✅ shell"  || echo "❌ shell"
command -v git  >/dev/null && echo "✅ git"    || echo "❌ git"
command -v uv   >/dev/null && echo "✅ python" || echo "❌ python"
command -v node >/dev/null && echo "✅ node"   || echo "❌ node"
command -v claude >/dev/null && echo "✅ ai"   || echo "❌ ai"
/Applications/Ghostty.app/Contents/MacOS/ghostty --version >/dev/null 2>&1 && echo "✅ terminal" || echo "❌ terminal"
command -v tmux >/dev/null && echo "✅ multiplexer" || echo "— multiplexer (optional)"
command -v docker >/dev/null && echo "✅ containers" || echo "— containers (optional)"
command -v code >/dev/null && echo "✅ apps" || echo "— apps (optional)"
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

If **no**: skip. User can set up SSH keys manually later:
```sh
ssh-keygen -t ed25519 -C "your@email.com"
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub  # paste at https://github.com/settings/keys
```

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

Run in this exact order:

**Bootstrap (always):**
```sh
bash ~/Projects/macos-dev-setup/tools/_bootstrap/homebrew/install.bash
bash ~/Projects/macos-dev-setup/tools/_bootstrap/zsh-switch/install.bash
```

**Required groups:**
```sh
for tool in ~/Projects/macos-dev-setup/tools/shell/*/install.bash; do bash "$tool"; done
for tool in ~/Projects/macos-dev-setup/tools/git/*/install.bash; do bash "$tool"; done
for tool in ~/Projects/macos-dev-setup/tools/macos/*/install.bash; do bash "$tool"; done
```

**Each selected optional group** (substitute actual group names from Step 3):
```sh
for tool in ~/Projects/macos-dev-setup/tools/{GROUP}/*/install.bash; do bash "$tool"; done
```

**Symlinks and macOS defaults:**
```sh
bash ~/Projects/macos-dev-setup/features/install/zsh/symlinks.zsh
```

For each install.bash: show progress, log errors but continue (non-fatal). Halt only if bootstrap fails.

### Step 5 — Verify

```sh
echo "=== Installation Verification ==="
command -v zsh    >/dev/null && echo "✅ shell:  $(zsh --version)"      || echo "❌ shell:  zsh missing"
command -v git    >/dev/null && echo "✅ git:    $(git --version)"       || echo "❌ git:    missing"
command -v gh     >/dev/null && echo "✅ gh:     $(gh --version | head -1)" || echo "❌ gh:  missing"
command -v uv     >/dev/null && echo "✅ python: $(uv --version)"        || echo "— python: not selected"
command -v node   >/dev/null && echo "✅ node:   $(node --version)"      || echo "— node:   not selected"
command -v claude >/dev/null && echo "✅ claude: installed"               || echo "— claude: not selected"
/Applications/Ghostty.app/Contents/MacOS/ghostty --version >/dev/null 2>&1 \
  && echo "✅ ghostty: installed" || echo "— ghostty: not selected"
```

Report any ❌ failures to user with suggested fix.

### Step 6 — Next Steps

Tell user:

1. **Reload shell:** `exec zsh`
2. **Add API keys** to `~/.zshrc.local`:
   ```sh
   cp ~/Projects/macos-dev-setup/tools/shell/zsh/config/zshrc.local.example ~/.zshrc.local
   $EDITOR ~/.zshrc.local
   # Add: ANTHROPIC_API_KEY, OPENROUTER_API_KEY, OPENAI_API_KEY
   ```
3. **Ghostty window size:** option-click the green button once — Ghostty remembers the size permanently.

---

## Update Mode

If user says "update all tools" or "upgrade everything":

```sh
cd ~/Projects/macos-dev-setup
for update_script in tools/*/*/update.bash; do
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
SKILLEOF
```

- [ ] **Step 2: Create project-level skill symlink**

```bash
mkdir -p ~/Projects/macos-dev-setup/.claude/skills
ln -sf ~/Projects/macos-dev-setup/tools/ai/claude/config/skills/macos-setup \
       ~/Projects/macos-dev-setup/.claude/skills/macos-setup
git add tools/ai/claude/config/skills/macos-setup/SKILL.md
git add .claude/skills/
```

- [ ] **Step 3: Verify symlink**

```bash
ls -la ~/Projects/macos-dev-setup/.claude/skills/macos-setup/SKILL.md
```

Expected: file accessible via the symlink path.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: add macos-setup skill with agent-driven installation workflow"
```

---

## Task 9: Update CLAUDE.md and README.md

**Files:**
- Modify: `CLAUDE.md`
- Modify: `README.md`

- [ ] **Step 1: Update CLAUDE.md path references**

In `CLAUDE.md`, update:
- All `tools/{tool}/` paths → `tools/{group}/{tool}/` using the group mapping
- Example: `tools/claude/` → `tools/ai/claude/`
- Example: `tools/zsh/` → `tools/shell/zsh/`
- Update "关键路径" section to reflect new structure
- Update the "新加一个工具" section to show new path convention with group prefix

- [ ] **Step 2: Update README.md structure diagram**

Replace the `tools/` section in the repo structure diagram with:
```
tools/
├── _bootstrap/          # Homebrew + zsh-switch (always runs first)
├── shell/               # Required: zsh, bat, eza, fzf, vim, ...
├── git/                 # Required: git, gh, lazygit
├── macos/               # Required: system defaults, m-cli, Raycast
├── python/              # Optional (default on): uv
├── node/                # Optional (default on): fnm, node, pnpm
├── ai/                  # Optional (default on): claude, codex, opencode, mempalace
├── terminal/            # Optional (default on): ghostty
├── multiplexer/         # Optional (default off): tmux
├── containers/          # Optional (default off): orbstack, lazydocker
└── apps/                # Optional (default off): vscode, obsidian, browsers
```

Update "装一个新软件 / 更新" section commands from `tools/<tool>/` to `tools/<group>/<tool>/`.

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md README.md
git commit -m "docs: update CLAUDE.md and README for new group-based structure"
```

---

## Task 10: End-to-end verification

- [ ] **Step 1: Verify all install scripts have correct utils path**

```bash
grep -r 'tools/bash/utils' ~/Projects/macos-dev-setup \
  --include="*.bash" --include="*.zsh" \
  --exclude-dir=".git" --exclude-dir="_reference-ooloth"
```

Expected: no output (zero matches for old path).

- [ ] **Step 2: Verify shellcheck passes on all scripts**

```bash
find ~/Projects/macos-dev-setup/tools ~/Projects/macos-dev-setup/features \
  -name "*.bash" ! -path "*/_reference-ooloth/*" | xargs shellcheck 2>&1 | grep -E "^/.+error" | head -20
```

Expected: no error lines (SC warnings for dynamic `source` are acceptable).

- [ ] **Step 3: Verify skill is accessible**

```bash
ls ~/Projects/macos-dev-setup/.claude/skills/macos-setup/SKILL.md
cat ~/Projects/macos-dev-setup/.claude/skills/macos-setup/SKILL.md | head -5
```

Expected: frontmatter with `name: macos-setup`.

- [ ] **Step 4: Test install of one tool via new path**

```bash
DOTFILES=~/Projects/macos-dev-setup bash ~/Projects/macos-dev-setup/tools/shell/bat/install.bash
```

Expected: either "bat already installed" or installation proceeds without error.

- [ ] **Step 5: Final commit and tag**

```bash
cd ~/Projects/macos-dev-setup
git add -A
git commit -m "chore: final verification pass — modular groups + skill complete"
git tag v2.0.0 -m "Modular group structure + macos-setup skill"
git push && git push --tags
```
