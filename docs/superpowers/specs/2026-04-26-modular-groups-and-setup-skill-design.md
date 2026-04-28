# Modular Groups + Setup Skill Design

**Date:** 2026-04-26  
**Status:** Approved

---

## Overview

Two parallel changes:

1. **Directory reorganization** — flatten `tools/` into group-based subdirectories so structure reflects intent
2. **Setup skill** — a Claude Code skill that drives interactive, group-selective installation for both fresh machines and existing setups

---

## 1. Directory Reorganization

### New Structure

```
tools/
├── _bootstrap/      # pre-group: always run first, not selectable
│   ├── homebrew/    # hard dependency — installs the package manager
│   └── zsh-switch/  # switch default shell to brew zsh before any tool installs
├── shell/           # required — always installed
│   ├── bash/        # utility lib for scripts
│   ├── bat/
│   ├── atuin/
│   ├── btop/
│   ├── direnv/
│   ├── eza/
│   ├── fonts/
│   ├── fzf/
│   ├── httpie/
│   ├── jq/
│   ├── powerlevel10k/
│   ├── sd/
│   ├── tree/
│   ├── vim/
│   ├── yq/
│   ├── zoxide/
│   └── zsh/
├── git/             # required
│   ├── git/
│   ├── github/
│   └── lazygit/
├── macos/           # required
│   ├── macos/
│   ├── m/
│   └── raycast/
├── python/          # optional, default on
│   └── uv/
├── node/            # optional, default on
│   ├── fnm/
│   ├── node/
│   └── pnpm/
├── ai/              # optional, default on
│   ├── claude/
│   ├── codex/
│   ├── mempalace/
│   └── opencode/
├── terminal/        # optional, default on
│   └── ghostty/
├── multiplexer/     # optional, default off
│   └── tmux/
├── containers/      # optional, default off
│   ├── lazydocker/
│   └── orbstack/
└── apps/            # optional, default off
    ├── browsers/
    ├── obsidian/
    └── vscode/
```

### Removed Tools

- `mise` — redundant with `uv` for Python version management
- `sesh` — removed after decision to not use tmux as default workflow
- `cli-extras` — dissolved; contents redistributed to `shell/` individual dirs
- `sd`, `btop`, `httpie`, `jq`, `yq`, `tree`, `atuin` — moved into `shell/` as individual tool dirs

### Auto-Discovery Path Update

`features/install/zsh/tools.zsh` and `features/install/zsh/symlinks.zsh` change glob pattern:

```bash
# before
for install_script in "${DOTFILES}"/tools/*/install.bash; do

# after
for install_script in "${DOTFILES}"/tools/*/*/install.bash; do
```

All internal `source "${DOTFILES}/tools/bash/utils.bash"` references in tool scripts update to `"${DOTFILES}/tools/shell/bash/utils.bash"`.

---

## 2. Groups Manifest

`groups.toml` at repo root defines group metadata. Directory structure defines membership — the manifest only stores description and install policy.

```toml
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
```

---

## 3. Install Behavior (Idempotency)

### Tools

| State | Action |
|---|---|
| Not installed | Install normally |
| Installed via Homebrew | Skip, log `already installed` |
| Installed outside Homebrew | Skip + warn, user decides |

Updates are a separate explicit action (`update.bash` per tool, or `--update` flag on skill). Setup never upgrades — it only ensures presence.

### Config / Symlinks

| State | Action |
|---|---|
| Symlink absent | Create |
| Symlink exists, correct target | Skip |
| Symlink exists, wrong target | Warn + skip |
| Regular file at target path | Backup as `.bak`, then create symlink |

---

## 4. Setup Skill

### Placement

```
.claude/skills/macos-setup/SKILL.md              ← project-level, fork users: clone → cd → claude → works immediately
tools/ai/claude/config/skills/macos-setup/       ← symlinked to ~/.claude/skills/macos-setup/, owner's global access
```

`.claude/skills/macos-setup/SKILL.md` is a symlink pointing to `tools/ai/claude/config/skills/macos-setup/SKILL.md` — single source of truth, two access paths.

The project-level skill requires no prior setup — available the moment any user runs `claude` inside the cloned repo.

### Invocation

```
/macos-setup
```

Or naturally: user says "help me set up my dev environment" and Claude invokes the skill.

### Workflow

```
Step 1 — Detect state
  - Homebrew installed?
  - Apple Silicon or Intel?
  - Which groups already have tools present? (check key binaries)
  - Existing dotfiles repo? (update vs fresh)

Step 2 — SSH / GitHub auth (optional prompt)
  - Ask: "Set up SSH key for GitHub? (recommended)" y/n
  - If yes: generate key, add to agent, open browser to add public key
  - If no: skip, user can run manually later

Step 3 — Confirm scope
  - Show required groups (no prompt, always included)
  - Show optional groups with default selection
  - User toggles groups, confirms

Step 4 — Execute installation
  Order: _bootstrap (Homebrew → zsh-switch) → [SSH if chosen] → selected groups (shell first, then rest) → symlinks → macOS defaults
  - Real-time progress per tool
  - Non-fatal errors logged, installation continues
  - Fatal errors (e.g. Homebrew install failed) halt with clear message

Step 5 — Verify
  - Check key binary per group (zsh, git, uv, node, claude, ghostty…)
  - Print summary table: ✅ installed / ⚠️ skipped / ❌ failed
  - Suggest next steps (reload shell, add API keys to ~/.zshrc.local)
```

### Update Mode

User says "update all tools" or runs `/macos-setup --update`:

```
- Run tools/*/*/update.bash for all installed groups
- Skip groups whose tools are not present
- Report versions before/after
```

---

## 5. Scenario Flows

### Fresh Machine (no Claude Code)

```sh
xcode-select --install
curl -s https://raw.githubusercontent.com/PingqiLi/macos-dev-setup/main/features/setup/setup.zsh | zsh
```

`setup.zsh` shows a text-based group selection menu, installs selected groups, outputs next steps.

### Existing Machine (has Claude Code)

```sh
git clone https://github.com/PingqiLi/macos-dev-setup ~/Projects/macos-dev-setup
cd ~/Projects/macos-dev-setup
claude
# then: /macos-setup
```

Agent detects existing state, skips already-installed tools, runs only missing ones.

---

## 6. Migration Checklist

- [ ] Remove `tools/mise/`, `tools/sesh/`
- [ ] Dissolve `tools/cli-extras/` → individual dirs under `tools/shell/`
- [ ] Move all remaining `tools/{tool}/` → `tools/{group}/{tool}/`
- [ ] Update glob in `features/install/zsh/tools.zsh`
- [ ] Update glob in `features/install/zsh/symlinks.zsh`
- [ ] Update all `source "${DOTFILES}/tools/bash/utils.bash"` paths in tool scripts
- [ ] Update `tools/claude/config/skills/macos-setup/` symlinks config
- [ ] Write `groups.toml`
- [ ] Write `.claude/skills/macos-setup/SKILL.md`
- [ ] Write `tools/claude/config/skills/macos-setup/SKILL.md`
- [ ] Update `README.md` structure diagram
- [ ] Update `CLAUDE.md` path references
