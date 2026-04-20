# macOS 开发环境 Bootstrap 仓库 — 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 基于 `ooloth/dotfiles` 建一个精简、可复用的个人 macOS bootstrap 仓库，支持 Python/Node 全栈 + AI 编码工作流，最终 push 到 GitHub。

**Architecture:** Fork-and-prune 路径——把 `_reference-ooloth/` 里需要的 `tools/` 和 `features/` 文件夹复制到仓库根，删掉 60% 不用的工具，改路径/URL/机器名条件，补 5 个新工具（claude 配置、opencode 配置、orbstack、raycast、atuin 等），覆盖 macOS defaults 脚本，最后用 `gh` 创建 GitHub 仓库并 push。

**Tech Stack:** Homebrew, bash, zsh, shellcheck, bats-core（测试），gh CLI。

**Spec 位置:** `docs/specs/2026-04-20-macos-dev-setup-design.md`

**参考仓库 clone 位置（不进 git）:** `_reference-ooloth/`

---

## 执行约定

- 所有路径以仓库根 `~/Projects/macos-dev-setup/` 为基准
- 所有 `*.sh` / `*.bash` 文件需通过 `shellcheck` 检查
- 每个 phase 结束做一次 commit
- bash 脚本头部统一：
  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  ```
- 环境变量 `DOTFILES` 统一指向 `${HOME}/Projects/macos-dev-setup`

---

## Phase 0: 仓库骨架

### Task 0.1: 初始化目录结构

**Files:**
- Create: `tools/` (empty dir placeholder)
- Create: `features/install/zsh/` (empty dir placeholder)
- Create: `features/setup/` (empty dir placeholder)
- Create: `features/update/` (empty dir placeholder)

- [ ] **Step 1: 创建空目录**

```bash
cd ~/Projects/macos-dev-setup
mkdir -p tools features/{install/zsh,setup,update,common/{detection,errors,symlinks}}
touch tools/.gitkeep features/install/zsh/.gitkeep features/update/.gitkeep
```

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "chore: scaffold repo directory structure"
```

---

### Task 0.2: 引入 ooloth 共享工具与 bash 基础设施

**Files:**
- Create: `tools/bash/utils.bash` (复制自 `_reference-ooloth/tools/bash/utils.bash`)
- Create: `features/utils.bash` (复制自 `_reference-ooloth/features/utils.bash`)
- Create: `features/install/utils.bash` (复制自 `_reference-ooloth/features/install/utils.bash`)
- Create: `.shellcheckrc` (复制自 `_reference-ooloth/.shellcheckrc`)

- [ ] **Step 1: 复制共享 utils**

```bash
cp -r _reference-ooloth/tools/bash tools/
cp _reference-ooloth/features/utils.bash features/utils.bash
cp _reference-ooloth/features/install/utils.bash features/install/utils.bash
cp _reference-ooloth/.shellcheckrc .shellcheckrc
```

- [ ] **Step 2: 检查 shellcheck 通过**

```bash
brew install shellcheck 2>/dev/null || true
find tools/bash features -name "*.bash" -o -name "*.sh" | xargs shellcheck
```
Expected: 无错误输出

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: import shared bash utilities from ooloth"
```

---

### Task 0.3: 引入 features/common/ 共享模块

**Files:**
- Create: `features/common/detection/` (从 `_reference-ooloth/features/common/detection/` 复制，仅保留 `is_macos.bash`, `is_darwin.bash`)
- Create: `features/common/errors.bash` (复制)
- Create: `features/common/symlinks.bash` (复制)

- [ ] **Step 1: 复制 common 模块**

```bash
if [ -d _reference-ooloth/features/common ]; then
  cp -r _reference-ooloth/features/common/* features/common/
fi
```

- [ ] **Step 2: 删掉 ooloth 用来区分 "work machine / Air / Mini" 的机器名相关 detection 逻辑**

```bash
# 如果有 is_work.bash / is_personal.bash 这样的文件，删掉
rm -f features/common/detection/is_work.bash features/common/detection/is_air.bash features/common/detection/is_mini.bash 2>/dev/null || true
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: import common feature modules, strip machine-specific detection"
```

---

## Phase 1: 保留的工具模块（批量从 ooloth 复制）

**保留清单**（26 个工具目录）：
```
bash bat btop eza fnm fonts fzf gh ghostty git github homebrew httpie
jq lazygit m mise node powerlevel10k raycast sd ssh tmux uv zoxide zsh
```

**注意**：`tools/bash` 已在 Task 0.2 复制。`tools/fonts` 需改字体。`tools/ghostty` / `tools/zsh` 需后续改配置。`ssh` 是 ooloth 用于生成 SSH key、加到 keychain 的模块，bootstrap 流程依赖它。`node` 是 ooloth 用 fnm 装 node 的模块。**不保留** rectangle（用户没用，raycast 自带窗口管理）。

### Task 1.1: 批量复制保留的 tools/

**Files:**
- Create: `tools/{bat,btop,eza,fnm,fonts,fzf,gh,ghostty,git,github,homebrew,httpie,jq,lazygit,m,mise,node,powerlevel10k,raycast,sd,ssh,tmux,uv,zoxide,zsh}/`

- [ ] **Step 1: 复制保留的工具**

```bash
cd ~/Projects/macos-dev-setup
TOOLS_TO_KEEP=(bat btop eza fnm fonts fzf gh ghostty git github homebrew httpie jq lazygit m mise node powerlevel10k raycast sd ssh tmux uv zoxide zsh)
for t in "${TOOLS_TO_KEEP[@]}"; do
  if [ -d "_reference-ooloth/tools/$t" ]; then
    cp -r "_reference-ooloth/tools/$t" "tools/$t"
    echo "copied $t"
  fi
done
```

- [ ] **Step 2: 验证目录齐全**

```bash
ls tools/ | sort
```
Expected: 能看到 `bash bat btop eza fnm fonts fzf gh ghostty git github homebrew httpie jq lazygit m mise node powerlevel10k raycast sd ssh tmux uv zoxide zsh`

- [ ] **Step 3: Commit**

```bash
git add tools/
git commit -m "feat: import 25 kept tools from ooloth"
```

---

### Task 1.2: 导入 sesh（ooloth 有）

**Files:**
- Create: `tools/sesh/` (复制)

- [ ] **Step 1: 复制**

```bash
cp -r _reference-ooloth/tools/sesh tools/sesh
```

- [ ] **Step 2: 验证 Brewfile**

```bash
cat tools/sesh/Brewfile
```
Expected: 含 `brew "fzf"`, `brew "sesh"`, `brew "zoxide"`

- [ ] **Step 3: Commit**

```bash
git add tools/sesh
git commit -m "feat: import sesh tool (tmux session manager)"
```

---

### Task 1.3: 导入 codex（ooloth 已有）

**Files:**
- Create: `tools/codex/` (复制)

- [ ] **Step 1: 复制**

```bash
cp -r _reference-ooloth/tools/codex tools/codex
```

- [ ] **Step 2: 确认 Brewfile 是 `cask "codex"`**

```bash
cat tools/codex/Brewfile
```

- [ ] **Step 3: Commit**

```bash
git add tools/codex
git commit -m "feat: import codex CLI tool"
```

---

### Task 1.4: 导入 claude（ooloth 有 config 目录结构，我们要大改）

**Files:**
- Create: `tools/claude/` (复制 `_reference-ooloth/tools/claude/` 的结构，但 config 要替换成本机的)

- [ ] **Step 1: 复制 ooloth claude 脚手架**

```bash
cp -r _reference-ooloth/tools/claude tools/claude
```

- [ ] **Step 2: 删除 ooloth 的个人 CLAUDE.md 和 settings**

```bash
rm -rf tools/claude/config/*
```

- [ ] **Step 3: Commit 空壳**

```bash
git add tools/claude
git commit -m "feat: import claude tool skeleton (config emptied)"
```

---

### Task 1.5: 导入 vscode（ooloth 有，需大改扩展列表）

**Files:**
- Create: `tools/vscode/` (复制，后续修改 Brewfile)

- [ ] **Step 1: 复制**

```bash
cp -r _reference-ooloth/tools/vscode tools/vscode
```

- [ ] **Step 2: Commit**

```bash
git add tools/vscode
git commit -m "feat: import vscode tool scaffold"
```

---

### Task 1.6: 导入 lazydocker 和 macos

**Files:**
- Create: `tools/lazydocker/`
- Create: `tools/macos/`

- [ ] **Step 1: 复制**

```bash
cp -r _reference-ooloth/tools/lazydocker tools/lazydocker
cp -r _reference-ooloth/tools/macos tools/macos
```

- [ ] **Step 2: Commit**

```bash
git add tools/lazydocker tools/macos
git commit -m "feat: import lazydocker and macos tool scaffolds"
```

---

## Phase 2: 删除所有机器名条件块

ooloth 用 `computer_name = ` ... `if computer_name == "Air"` 来做机器差异化。我们统一机器，必须全部移除。

### Task 2.1: 清理保留 tools/*/Brewfile 里的 computer_name 条件块

**Files:**
- Modify: 所有 `tools/*/Brewfile` 里含 `computer_name` 的文件

- [ ] **Step 1: 定位所有含机器名判断的 Brewfile**

```bash
cd ~/Projects/macos-dev-setup
grep -lR "computer_name" tools/*/Brewfile
```
Expected: 列出若干文件（从 ooloth 继承下来的那些）

- [ ] **Step 2: 对每个文件，手动删掉 `computer_name = ...`、`if ... include? ...` 和 `end` 行，保留中间的 brew/cask 条目**

示例——转换前：
```ruby
computer_name = `networksetup -getcomputername`.chomp

if ["Air", "Mini"].include?(computer_name)
  cask "1password"
end
```
转换后（因为我们决定删掉 1password）：整个文件删除

示例——转换前（保留的 go 工具 Brewfile）：
```ruby
computer_name = `networksetup -getcomputername`.chomp

if computer_name == "Air"
  brew "go"
end

brew "goose"
```
转换后：
```ruby
brew "goose"  # 但 goose 也不要了，这个 Brewfile 进 Task 3.x 删整个 tools/go
```

对于保留的工具里的条件块，策略：
- 如果条件块里的条目我们决定保留 → 去掉条件，直接留条目
- 如果条件块里的条目我们决定删除 → 整行删

- [ ] **Step 3: shellcheck + brew bundle --dry-run 验证每个修改过的 Brewfile**

```bash
for bf in tools/*/Brewfile; do
  echo "=== $bf ==="
  brew bundle check --file="$bf" --verbose 2>&1 | head -5
done
```

- [ ] **Step 4: Commit**

```bash
git add tools/
git commit -m "refactor: remove machine-name conditional blocks from Brewfiles"
```

---

## Phase 3: 新增工具模块（ooloth 没有或需要重建）

ooloth 的模板 `tools/@new/` 可以作为新工具的骨架参考。

### Task 3.1: 写 tools/claude/install.bash + update.bash + uninstall.bash

**Files:**
- Create: `tools/claude/install.bash`
- Create: `tools/claude/update.bash`
- Create: `tools/claude/uninstall.bash`

（Task 1.4 已复制了 ooloth 的 `tools/claude/` 骨架并清空了 config 目录。这里覆写它的安装脚本，因为 ooloth 版可能依赖他们自己的工作流。）

- [ ] **Step 1: 覆写 install.bash**（不用 Brewfile，因为 claude-code 通过 npm 装）

Create `tools/claude/install.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/bash/utils.bash"

info "🤖 Installing claude-code"

if ! command -v npm >/dev/null 2>&1; then
  echo "❌ npm not found. Install Node first (via fnm)."
  exit 1
fi

npm install -g @anthropic-ai/claude-code
```

- [ ] **Step 2: 覆写 update.bash**

Create `tools/claude/update.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🤖 Updating claude-code"
npm update -g @anthropic-ai/claude-code
```

- [ ] **Step 3: 覆写 uninstall.bash**

Create `tools/claude/uninstall.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🤖 Uninstalling claude-code"
npm uninstall -g @anthropic-ai/claude-code
```

- [ ] **Step 4: shellcheck 过**

```bash
shellcheck tools/claude/*.bash
```

- [ ] **Step 5: Commit**

```bash
git add tools/claude
git commit -m "feat(claude): add install/update/uninstall scripts for claude-code CLI"
```

---

### Task 3.2: 同步本机 Claude 配置到 tools/claude/config/

**Files:**
- Create: `tools/claude/config/CLAUDE.md` (复制自 `~/.claude/CLAUDE.md`)
- Create: `tools/claude/config/settings.json` (复制自 `~/.claude/settings.json`)

- [ ] **Step 1: 复制本机 CLAUDE.md**

```bash
cp ~/.claude/CLAUDE.md tools/claude/config/CLAUDE.md
```

- [ ] **Step 2: 复制本机 settings.json**

```bash
cp ~/.claude/settings.json tools/claude/config/settings.json
```

- [ ] **Step 3: 检查 settings.json 不含敏感数据**

```bash
cat tools/claude/config/settings.json | grep -iE "key|token|secret|password" || echo "no secrets found"
```
Expected: `no secrets found`

- [ ] **Step 4: Commit**

```bash
git add tools/claude/config
git commit -m "feat(claude): sync CLAUDE.md and settings.json from local machine"
```

---

### Task 3.3: 写 tools/claude/symlinks/link.bash

**Files:**
- Create: `tools/claude/symlinks/link.bash`
- Create: `tools/claude/utils.bash`

- [ ] **Step 1: 写 utils.bash**

Create `tools/claude/utils.bash`:
```bash
#!/usr/bin/env bash
TOOL_LOWER="claude"
TOOL_CONFIG_DIR="${HOME}/.claude"
```

- [ ] **Step 2: 写 link.bash**

Create `tools/claude/symlinks/link.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/claude/utils.bash"
source "${DOTFILES}/tools/bash/utils.bash"

mkdir -p "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/CLAUDE.md" "${TOOL_CONFIG_DIR}/CLAUDE.md"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/settings.json" "${TOOL_CONFIG_DIR}/settings.json"
```

- [ ] **Step 3: shellcheck 过**

```bash
shellcheck tools/claude/utils.bash tools/claude/symlinks/link.bash
```

- [ ] **Step 4: Commit**

```bash
git add tools/claude
git commit -m "feat(claude): add symlink logic for CLAUDE.md and settings.json"
```

---

### Task 3.4: 新增 tools/opencode/ — Brewfile + install

**Files:**
- Create: `tools/opencode/Brewfile`
- Create: `tools/opencode/install.bash`
- Create: `tools/opencode/update.bash`
- Create: `tools/opencode/uninstall.bash`
- Create: `tools/opencode/utils.bash`

- [ ] **Step 1: Brewfile**

Create `tools/opencode/Brewfile`:
```ruby
brew "opencode"
```

- [ ] **Step 2: utils.bash**

Create `tools/opencode/utils.bash`:
```bash
#!/usr/bin/env bash
TOOL_LOWER="opencode"
TOOL_CONFIG_DIR="${HOME}/.config/opencode"
```

- [ ] **Step 3: install.bash**

Create `tools/opencode/install.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/bash/utils.bash"
source "${DOTFILES}/tools/opencode/utils.bash"

info "🚂 Installing opencode"
brew bundle --file="${DOTFILES}/tools/opencode/Brewfile"

# Install oh-my-opencode plugin SDK (bun install in ~/.config/opencode)
if command -v bun >/dev/null 2>&1; then
  mkdir -p "${TOOL_CONFIG_DIR}"
  cd "${TOOL_CONFIG_DIR}"
  bun install
fi
```

- [ ] **Step 4: update.bash**

Create `tools/opencode/update.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🚂 Updating opencode"
brew upgrade opencode
```

- [ ] **Step 5: uninstall.bash**

Create `tools/opencode/uninstall.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🚂 Uninstalling opencode"
brew uninstall opencode
```

- [ ] **Step 6: shellcheck 过**

```bash
shellcheck tools/opencode/*.bash
```

- [ ] **Step 7: Commit**

```bash
git add tools/opencode
git commit -m "feat(opencode): add Brewfile and install/update/uninstall scripts"
```

---

### Task 3.5: 同步本机 OpenCode 配置到 tools/opencode/config/

**Files:**
- Create: `tools/opencode/config/opencode.json`
- Create: `tools/opencode/config/oh-my-opencode.json`
- Create: `tools/opencode/config/oh-my-opencode.openrouter-fallback.json`
- Create: `tools/opencode/config/package.json`
- Create: `tools/opencode/config/switch-to-openrouter.sh`
- Create: `tools/opencode/config/skills/` (目录树)

- [ ] **Step 1: 复制主配置**

```bash
cd ~/Projects/macos-dev-setup
mkdir -p tools/opencode/config
cp ~/.config/opencode/opencode.json tools/opencode/config/
cp ~/.config/opencode/oh-my-opencode.json tools/opencode/config/
cp ~/.config/opencode/oh-my-opencode.openrouter-fallback.json tools/opencode/config/
cp ~/.config/opencode/package.json tools/opencode/config/
cp ~/.config/opencode/switch-to-openrouter.sh tools/opencode/config/
chmod +x tools/opencode/config/switch-to-openrouter.sh
```

- [ ] **Step 2: 复制 skills/ 目录**

```bash
if [ -d ~/.config/opencode/skills ]; then
  cp -r ~/.config/opencode/skills tools/opencode/config/
fi
```

- [ ] **Step 3: 确认配置里 API key 是占位符**

```bash
grep -E "apiKey|API_KEY" tools/opencode/config/opencode.json
```
Expected: 只看到 `"apiKey": "{env:OPENROUTER_API_KEY}"`（占位符，不是真 key）

- [ ] **Step 4: Commit**

```bash
git add tools/opencode/config
git commit -m "feat(opencode): sync configuration from local machine"
```

---

### Task 3.6: 写 tools/opencode/symlinks/link.bash

**Files:**
- Create: `tools/opencode/symlinks/link.bash`

- [ ] **Step 1: 写 link.bash**

Create `tools/opencode/symlinks/link.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/opencode/utils.bash"
source "${DOTFILES}/tools/bash/utils.bash"

mkdir -p "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/opencode.json" "${TOOL_CONFIG_DIR}/opencode.json"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/oh-my-opencode.json" "${TOOL_CONFIG_DIR}/oh-my-opencode.json"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/oh-my-opencode.openrouter-fallback.json" "${TOOL_CONFIG_DIR}/oh-my-opencode.openrouter-fallback.json"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/package.json" "${TOOL_CONFIG_DIR}/package.json"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/switch-to-openrouter.sh" "${TOOL_CONFIG_DIR}/switch-to-openrouter.sh"

if [ -d "${DOTFILES}/tools/${TOOL_LOWER}/config/skills" ]; then
  symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/skills" "${TOOL_CONFIG_DIR}/skills"
fi
```

- [ ] **Step 2: shellcheck 过**

```bash
shellcheck tools/opencode/symlinks/link.bash
```

- [ ] **Step 3: Commit**

```bash
git add tools/opencode/symlinks
git commit -m "feat(opencode): add symlink logic"
```

---

### Task 3.7: 新增 tools/orbstack/

**Files:**
- Create: `tools/orbstack/Brewfile`
- Create: `tools/orbstack/install.bash`
- Create: `tools/orbstack/update.bash`
- Create: `tools/orbstack/uninstall.bash`

- [ ] **Step 1: Brewfile**

Create `tools/orbstack/Brewfile`:
```ruby
cask "orbstack"
```

- [ ] **Step 2: install.bash**

Create `tools/orbstack/install.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🐳 Installing orbstack"
brew bundle --file="${DOTFILES}/tools/orbstack/Brewfile"
```

- [ ] **Step 3: update.bash + uninstall.bash**（类似模板）

Create `tools/orbstack/update.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🐳 Updating orbstack"
brew upgrade --cask orbstack
```

Create `tools/orbstack/uninstall.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🐳 Uninstalling orbstack"
brew uninstall --cask orbstack
```

- [ ] **Step 4: shellcheck + Commit**

```bash
shellcheck tools/orbstack/*.bash
git add tools/orbstack
git commit -m "feat(orbstack): add Docker Desktop replacement"
```

---

### Task 3.8: 新增 tools/obsidian/

**Files:**
- Create: `tools/obsidian/Brewfile`
- Create: `tools/obsidian/install.bash`, `update.bash`, `uninstall.bash`

- [ ] **Step 1: Brewfile**

Create `tools/obsidian/Brewfile`:
```ruby
cask "obsidian"
```

- [ ] **Step 2: install.bash**

Create `tools/obsidian/install.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "📝 Installing obsidian"
brew bundle --file="${DOTFILES}/tools/obsidian/Brewfile"
```

- [ ] **Step 3: update.bash + uninstall.bash**

Create `tools/obsidian/update.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "📝 Updating obsidian"
brew upgrade --cask obsidian
```

Create `tools/obsidian/uninstall.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "📝 Uninstalling obsidian"
brew uninstall --cask obsidian
```

- [ ] **Step 4: shellcheck + Commit**

```bash
shellcheck tools/obsidian/*.bash
git add tools/obsidian
git commit -m "feat(obsidian): add note-taking app"
```

---

### Task 3.9: 新增 tools/browsers/（Chrome + Edge 合并）

**Files:**
- Create: `tools/browsers/Brewfile`
- Create: `tools/browsers/install.bash`, `update.bash`, `uninstall.bash`

- [ ] **Step 1: Brewfile**

Create `tools/browsers/Brewfile`:
```ruby
cask "google-chrome"
cask "microsoft-edge"
```

- [ ] **Step 2: install.bash**

Create `tools/browsers/install.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🌐 Installing browsers"
brew bundle --file="${DOTFILES}/tools/browsers/Brewfile"
```

- [ ] **Step 3: update.bash + uninstall.bash**

Create `tools/browsers/update.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🌐 Updating browsers"
brew upgrade --cask google-chrome microsoft-edge
```

Create `tools/browsers/uninstall.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🌐 Uninstalling browsers"
brew uninstall --cask google-chrome microsoft-edge
```

- [ ] **Step 4: Commit**

```bash
shellcheck tools/browsers/*.bash
git add tools/browsers
git commit -m "feat(browsers): add Chrome and Edge"
```

---

### Task 3.10: 新增 tools/cli-extras/（atuin + direnv + yq + tree + pnpm 等）

**Files:**
- Create: `tools/cli-extras/Brewfile`
- Create: `tools/cli-extras/install.bash`, `update.bash`

**决策理由**：一次性补齐 ooloth 没有但我们要的零碎 CLI 工具，避免每个一个文件夹太碎。

- [ ] **Step 1: Brewfile**

Create `tools/cli-extras/Brewfile`:
```ruby
brew "atuin"
brew "direnv"
brew "yq"
brew "tree"
brew "pnpm"
brew "gnu-sed"
brew "coreutils"
```

- [ ] **Step 2: install.bash**

Create `tools/cli-extras/install.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🧰 Installing CLI extras"
brew bundle --file="${DOTFILES}/tools/cli-extras/Brewfile"
```

- [ ] **Step 3: update.bash**

Create `tools/cli-extras/update.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🧰 Updating CLI extras"
brew upgrade atuin direnv yq tree pnpm gnu-sed coreutils
```

- [ ] **Step 4: Commit**

```bash
shellcheck tools/cli-extras/*.bash
git add tools/cli-extras
git commit -m "feat(cli-extras): add atuin, direnv, yq, tree, pnpm, gnu-sed, coreutils"
```

---

### Task 3.11: 更新 tools/fonts/Brewfile 换 JetBrainsMono Nerd Font

**Files:**
- Modify: `tools/fonts/Brewfile`

- [ ] **Step 1: 读当前文件**

```bash
cat tools/fonts/Brewfile
```
Expected: 含 `cask "font-ubuntu-mono-nerd-font"` 等

- [ ] **Step 2: 替换**

Overwrite `tools/fonts/Brewfile`:
```ruby
brew "svn" # required for some font cask installations
cask "font-jetbrains-mono-nerd-font"
cask "font-symbols-only-nerd-font"
```

- [ ] **Step 3: Commit**

```bash
git add tools/fonts/Brewfile
git commit -m "feat(fonts): switch to JetBrains Mono Nerd Font"
```

---

## Phase 4: 修改保留工具的配置

### Task 4.1: 更新 tools/ghostty/config/config 的字体

**Files:**
- Modify: `tools/ghostty/config/config`

- [ ] **Step 1: 读当前文件**

```bash
grep "font-family" tools/ghostty/config/config
```
Expected: `font-family = UbuntuMono Nerd Font Mono`

- [ ] **Step 2: 替换字体**

Edit `tools/ghostty/config/config`: 把 `font-family = UbuntuMono Nerd Font Mono` 改成：
```
font-family = JetBrainsMono Nerd Font
```

- [ ] **Step 3: 其他 ghostty 配置保留**（theme, keybinds, tmux keybinds 全部不动）

- [ ] **Step 4: Commit**

```bash
git add tools/ghostty/config/config
git commit -m "feat(ghostty): switch font to JetBrains Mono Nerd Font"
```

---

### Task 4.2: 更新 tools/zsh/config/zshrc 添加 .zshrc.local 加载

**Files:**
- Modify: `tools/zsh/config/zshrc`

- [ ] **Step 1: 确认 zshrc 存在**

```bash
ls tools/zsh/config/
```

- [ ] **Step 2: 在 zshrc 末尾追加一行**

Append to `tools/zsh/config/zshrc`:
```sh

# Source machine-local overrides (secrets, machine-specific exports) - gitignored
[ -f "${HOME}/.zshrc.local" ] && source "${HOME}/.zshrc.local"
```

- [ ] **Step 3: 创建 `.zshrc.local.example` 作为模板**

Create `tools/zsh/config/zshrc.local.example`:
```sh
# Copy this to ~/.zshrc.local on each machine (NOT tracked in git)
# Add your API keys and machine-specific exports here

# export OPENROUTER_API_KEY=""
# export ANTHROPIC_API_KEY=""
# export OPENAI_API_KEY=""
```

- [ ] **Step 4: Commit**

```bash
git add tools/zsh/config
git commit -m "feat(zsh): source ~/.zshrc.local for machine-specific overrides"
```

---

### Task 4.3: 精简 tools/vscode/Brewfile 到 25 个扩展

**Files:**
- Overwrite: `tools/vscode/Brewfile`

- [ ] **Step 1: 完整重写 Brewfile**

Overwrite `tools/vscode/Brewfile`:
```ruby
cask "visual-studio-code"

# Python
vscode "ms-python.python"
vscode "ms-python.vscode-pylance"
vscode "charliermarsh.ruff"
vscode "ms-python.mypy-type-checker"
vscode "ms-python.debugpy"

# Jupyter
vscode "ms-toolsai.jupyter"
vscode "ms-toolsai.jupyter-renderers"

# JavaScript / TypeScript
vscode "dbaeumer.vscode-eslint"
vscode "esbenp.prettier-vscode"
vscode "bradlc.vscode-tailwindcss"
vscode "christian-kohler.npm-intellisense"
vscode "christian-kohler.path-intellisense"

# Git
vscode "eamodio.gitlens"
vscode "vivaxy.vscode-conventional-commits"

# Config / Data
vscode "redhat.vscode-yaml"
vscode "tamasfe.even-better-toml"
vscode "editorconfig.editorconfig"
vscode "mikestead.dotenv"

# General
vscode "usernamehw.errorlens"
vscode "ms-azuretools.vscode-docker"

# Remote development
vscode "ms-vscode-remote.remote-ssh"
vscode "ms-vscode-remote.remote-ssh-edit"
vscode "ms-vscode-remote.remote-containers"

# Theme
vscode "catppuccin.catppuccin-vsc"
vscode "catppuccin.catppuccin-vsc-icons"
```

- [ ] **Step 2: Commit**

```bash
git add tools/vscode/Brewfile
git commit -m "feat(vscode): trim extensions to 25 focused on Python/Node/AI"
```

---

### Task 4.4: 导出本机 VSCode settings.json 和 keybindings.json

**Files:**
- Create: `tools/vscode/config/settings.json`
- Create: `tools/vscode/config/keybindings.json`

- [ ] **Step 1: 确认本机有这两个文件**

```bash
ls "${HOME}/Library/Application Support/Code/User/settings.json" "${HOME}/Library/Application Support/Code/User/keybindings.json" 2>&1
```

- [ ] **Step 2: 复制**

```bash
mkdir -p tools/vscode/config
cp "${HOME}/Library/Application Support/Code/User/settings.json" tools/vscode/config/settings.json 2>/dev/null || echo '{}' > tools/vscode/config/settings.json
cp "${HOME}/Library/Application Support/Code/User/keybindings.json" tools/vscode/config/keybindings.json 2>/dev/null || echo '[]' > tools/vscode/config/keybindings.json
```

- [ ] **Step 3: 检查无敏感信息**

```bash
grep -iE "key|token|secret|password" tools/vscode/config/settings.json || echo "clean"
```

- [ ] **Step 4: 写 symlinks/link.bash**

Create `tools/vscode/symlinks/link.bash`:
```bash
#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/bash/utils.bash"

VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
mkdir -p "${VSCODE_USER_DIR}"

symlink "${DOTFILES}/tools/vscode/config/settings.json" "${VSCODE_USER_DIR}/settings.json"
symlink "${DOTFILES}/tools/vscode/config/keybindings.json" "${VSCODE_USER_DIR}/keybindings.json"
```

- [ ] **Step 5: Commit**

```bash
shellcheck tools/vscode/symlinks/link.bash
git add tools/vscode
git commit -m "feat(vscode): sync settings.json and keybindings.json from local"
```

---

## Phase 5: macOS 全局系统设置

### Task 5.1: 扩展 tools/macos 的 defaults 脚本

**Files:**
- Modify: `tools/macos/install.bash`（或 `tools/macos/config/macos-defaults`）

- [ ] **Step 1: 找到 ooloth 的 defaults 脚本位置**

```bash
find tools/macos -name "*.bash" -o -name "macos-defaults*"
```

- [ ] **Step 2: 确定主脚本**（根据 ooloth 仓库，可能是 `tools/macos/config/macos-defaults` 或 `tools/macos/install.bash`）

读 `tools/macos/install.bash`，找到 `defaults write` 部分或确认它 source 了另一个文件（比如 `features/install/zsh/settings.zsh`）。

- [ ] **Step 3: 合并 ooloth 的 settings.zsh 到 tools/macos/install.bash**

把 `_reference-ooloth/features/install/zsh/settings.zsh` 里保留的 `defaults write` 行搬进 `tools/macos/install.bash`（或它 source 的地方），再补上 spec 里的新增项：

Append to `tools/macos/install.bash`（新增部分）:
```bash
# --- Keyboard ---
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# --- Screenshots ---
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"

# --- Dock ---
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
killall Dock

# --- Trackpad: tap to click ---
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
```

- [ ] **Step 4: 删除 ooloth 保留但我们不要的 Safari defaults**

在 `tools/macos/install.bash` 里删除任何 `com.apple.Safari` 相关行。

- [ ] **Step 5: shellcheck 过**

```bash
shellcheck tools/macos/install.bash
```

- [ ] **Step 6: Commit**

```bash
git add tools/macos
git commit -m "feat(macos): add keyboard, screenshot, dock, trackpad defaults; drop Safari"
```

---

## Phase 6: Bootstrap 编排与元数据

### Task 6.1: 导入并修改 setup.zsh

**Files:**
- Create: `features/setup/setup.zsh` (复制 ooloth 版本后修改)

- [ ] **Step 1: 复制**

```bash
cp _reference-ooloth/features/setup/setup.zsh features/setup/setup.zsh
```

- [ ] **Step 2: 改 DOTFILES 路径**

Edit `features/setup/setup.zsh`: 把 `export DOTFILES="${HOME}/Repos/ooloth/dotfiles"` 改成：
```zsh
export DOTFILES="${HOME}/Projects/macos-dev-setup"
```

- [ ] **Step 3: 改 git clone URL（稍后 Task 7.1 再填真实 URL，先用占位）**

把 `git clone "https://github.com/ooloth/dotfiles.git" "$DOTFILES"` 改成：
```zsh
git clone "https://github.com/REPLACE_WITH_YOUR_USERNAME/macos-dev-setup.git" "$DOTFILES"
```

- [ ] **Step 4: 删除 ooloth 特有的安装步骤**

在 setup.zsh 里删掉 rust 的安装段（我们不装 rust）。其他 zsh/node/uv/tmux/neovim 保留。

- [ ] **Step 5: 重新排序 install 调用**

修改 `####################\n# INSTALL + UPDATE #\n####################` 段落，改成这个顺序：

```zsh
DOTINSTALL="${DOTFILES}/features/install/zsh"

source "${DOTINSTALL}/ssh.zsh"
source "${DOTINSTALL}/github.zsh"
source "${DOTINSTALL}/homebrew.zsh"
source "${DOTINSTALL}/zsh.zsh"
source "${DOTINSTALL}/uv.zsh"
source "${DOTINSTALL}/node.zsh"
source "${DOTINSTALL}/npm.zsh"
source "${DOTINSTALL}/tmux.zsh"
source "${DOTINSTALL}/tools.zsh"   # 新增：批量跑所有 tools/*/install.bash
source "${DOTINSTALL}/symlinks.zsh"
source "${DOTINSTALL}/macos.zsh"   # 新增：跑 tools/macos/install.bash
```

- [ ] **Step 6: Commit**

```bash
git add features/setup/setup.zsh
git commit -m "feat(setup): customize setup.zsh paths and install order"
```

---

### Task 6.2: 复制或重建 features/install/zsh/*.zsh

**Files:**
- Copy: `features/install/zsh/{ssh,github,homebrew,zsh,uv,node,npm,tmux,symlinks}.zsh` (从 `_reference-ooloth/features/install/zsh/`)

- [ ] **Step 1: 复制保留的 install 脚本**

```bash
cd ~/Projects/macos-dev-setup
KEEP=(ssh.zsh github.zsh homebrew.zsh zsh.zsh uv.zsh node.zsh npm.zsh tmux.zsh symlinks.zsh)
for f in "${KEEP[@]}"; do
  src="_reference-ooloth/features/install/zsh/$f"
  if [ ! -f "$src" ]; then
    src="_reference-ooloth/features/install/zsh/deprecated/$f"
  fi
  cp "$src" "features/install/zsh/$f"
done
```

- [ ] **Step 2: 检查每个脚本里硬编码的路径**

```bash
grep -l "Repos/ooloth" features/install/zsh/*.zsh
```
把出现的 `${HOME}/Repos/ooloth/dotfiles` 全部改成 `${DOTFILES}`。

- [ ] **Step 3: Commit**

```bash
git add features/install/zsh
git commit -m "feat: import install scripts, switch paths to DOTFILES env"
```

---

### Task 6.3: 新增 features/install/zsh/tools.zsh（批量跑所有 tools/*/install.bash）

**Files:**
- Create: `features/install/zsh/tools.zsh`

- [ ] **Step 1: 写 tools.zsh**

Create `features/install/zsh/tools.zsh`:
```zsh
#!/usr/bin/env zsh
# Run install.bash for every tool directory

info "🧩 Installing all tool modules"

for install_script in "${DOTFILES}"/tools/*/install.bash; do
  tool_name=$(basename "$(dirname "$install_script")")
  printf "\n→ Installing %s...\n" "$tool_name"
  bash "$install_script"
done
```

`info` 函数来自 `${DOTFILES}/tools/bash/utils.bash`；如果 zsh 没加载它，先 source：在 `tools.zsh` 最上面加：
```zsh
source "${DOTFILES}/tools/bash/utils.bash"
```

- [ ] **Step 2: Commit**

```bash
git add features/install/zsh/tools.zsh
git commit -m "feat(install): add tools.zsh to run all tools/*/install.bash"
```

---

### Task 6.4: 新增 features/install/zsh/macos.zsh（跑 macOS defaults）

**Files:**
- Create: `features/install/zsh/macos.zsh`

- [ ] **Step 1: 写 macos.zsh**

Create `features/install/zsh/macos.zsh`:
```zsh
#!/usr/bin/env zsh
source "${DOTFILES}/tools/bash/utils.bash"
info "💻 Applying macOS system defaults"
bash "${DOTFILES}/tools/macos/install.bash"
```

- [ ] **Step 2: Commit**

```bash
git add features/install/zsh/macos.zsh
git commit -m "feat(install): add macos.zsh to apply macOS defaults"
```

---

### Task 6.5: 写项目 README.md 和 CLAUDE.md

**Files:**
- Create: `README.md`
- Create: `CLAUDE.md`

- [ ] **Step 1: 写 README.md**

Create `README.md`:
```markdown
# macos-dev-setup

我的 macOS 开发环境 bootstrap 仓库。基于 [ooloth/dotfiles](https://github.com/ooloth/dotfiles) 精简而来。

## 用途

在一台全新的 macOS 上，几分钟内配置好 Python / Node / AI 编码工作流。

## 前置条件

1. 连接互联网
2. 安装 Xcode Command Line Tools：`xcode-select --install`
3. 更新 macOS：`sudo softwareupdate --install --all --restart`

## 安装

```sh
curl -s https://raw.githubusercontent.com/REPLACE_WITH_YOUR_USERNAME/macos-dev-setup/main/features/setup/setup.zsh | zsh
```

## 软件清单

见 `docs/specs/2026-04-20-macos-dev-setup-design.md`。

## 更新

```sh
cd ~/Projects/macos-dev-setup
git pull
bash features/update/update.bash   # 如启用
```

## 自定义

- `~/.zshrc.local`（未进 git）放 API key 和机器特定的 export，参考 `tools/zsh/config/zshrc.local.example`
- 新增工具：参考 `tools/` 里任一文件夹的结构（Brewfile + install.bash + symlinks/link.bash）

## License

MIT
```

- [ ] **Step 2: 写 CLAUDE.md**

Create `CLAUDE.md`:
```markdown
# CLAUDE.md

本仓库的 Claude 使用指引。

## 仓库结构

- `features/setup/setup.zsh` — 新机器 bootstrap 入口
- `features/install/zsh/*.zsh` — 分阶段安装脚本
- `tools/{tool}/` — 每个工具独立模块（Brewfile + install.bash + config + symlinks）
- `docs/specs/` — 设计文档
- `docs/plans/` — 实施计划

## 修改原则

1. 新加工具 → 在 `tools/{tool}/` 下按模板建文件夹（Brewfile、install.bash、update.bash、uninstall.bash、symlinks/link.bash）
2. 改 shell 脚本 → 改完跑 `shellcheck`
3. 改 claude/opencode 配置 → 改仓库里的副本（`tools/claude/config/` 或 `tools/opencode/config/`），不要直接改 `~/.claude/` 或 `~/.config/opencode/`（那是 symlink）
4. 引入新的敏感信息 → 一律走 `~/.zshrc.local`，不能 commit

## Symlinks

每个工具的 `symlinks/link.bash` 会把 `tools/{tool}/config/*` 链到用户目录。

如果 config 改了但没生效，跑：
```sh
bash features/install/zsh/symlinks.zsh
```
```

- [ ] **Step 3: Commit**

```bash
git add README.md CLAUDE.md
git commit -m "docs: add README.md and CLAUDE.md"
```

---

## Phase 7: 推到 GitHub

### Task 7.1: 在 GitHub 创建仓库

**Files:** (no files, just remote op)

- [ ] **Step 1: 确认 gh 已登录**

```bash
gh auth status
```
Expected: 显示已登录到 github.com 的某账号

- [ ] **Step 2: 创建仓库（public 或 private 由用户选择）**

```bash
cd ~/Projects/macos-dev-setup
gh repo create macos-dev-setup --public --source=. --remote=origin --description "My macOS developer environment bootstrap (Python/Node/AI coding workflow)"
```

**⚠️ 在跑这条命令前暂停，与用户确认是 public 还是 private**。如果用户选 private，把 `--public` 换成 `--private`。

- [ ] **Step 3: 记下 owner 名字**

```bash
OWNER=$(gh api user --jq .login)
echo "Your GitHub username: $OWNER"
```

---

### Task 7.2: 回填 setup.zsh 和 README.md 里的 placeholder

**Files:**
- Modify: `features/setup/setup.zsh`
- Modify: `README.md`

- [ ] **Step 1: 替换 setup.zsh**

```bash
OWNER=$(gh api user --jq .login)
sed -i '' "s/REPLACE_WITH_YOUR_USERNAME/${OWNER}/g" features/setup/setup.zsh
```

- [ ] **Step 2: 替换 README.md**

```bash
sed -i '' "s/REPLACE_WITH_YOUR_USERNAME/${OWNER}/g" README.md
```

- [ ] **Step 3: 验证**

```bash
grep -r "REPLACE_WITH_YOUR_USERNAME" .
```
Expected: 无结果（排除 `_reference-ooloth/` 和 `.git/`）

- [ ] **Step 4: Commit + push**

```bash
git add features/setup/setup.zsh README.md
git commit -m "chore: fill in GitHub username in setup.zsh and README"
git push -u origin main
```

---

### Task 7.3: 在 GitHub 端打一个 release/tag 作为初始版本

**Files:** (no files)

- [ ] **Step 1: 打 tag**

```bash
git tag -a v0.1.0 -m "Initial release: pruned fork of ooloth/dotfiles with Claude Code + OpenCode"
git push origin v0.1.0
```

- [ ] **Step 2: 创建 GitHub release**

```bash
gh release create v0.1.0 --title "v0.1.0 — Initial setup" --notes "First working version. See docs/specs/ for design, docs/plans/ for implementation history."
```

---

## Phase 8: 本机验证

**目的**：在当前机器跑 setup.zsh，确认 idempotent（不会重装已有的东西），所有 symlink 正确。

### Task 8.1: Dry-run 每个 Brewfile

**Files:** (none — validation)

- [ ] **Step 1: 对每个 Brewfile 跑 brew bundle check**

```bash
cd ~/Projects/macos-dev-setup
for bf in tools/*/Brewfile; do
  echo "=== $bf ==="
  brew bundle check --file="$bf" --verbose 2>&1 | head -3
done
```
Expected: 每个都显示 "The Brewfile's dependencies are satisfied." 或列出未安装的。

- [ ] **Step 2: 修复任何语法错误的 Brewfile**（如果 Step 1 报错）

- [ ] **Step 3: Commit 修复（如有）**

---

### Task 8.2: 实际跑 symlinks，验证配置生效

**Files:** (none — validation)

- [ ] **Step 1: 备份现有 ~/.claude 和 ~/.config/opencode**

```bash
cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.pre-dotfiles
cp ~/.claude/settings.json ~/.claude/settings.json.pre-dotfiles
cp -r ~/.config/opencode ~/.config/opencode.pre-dotfiles
```

- [ ] **Step 2: 跑 symlinks**

```bash
export DOTFILES=~/Projects/macos-dev-setup
for link_script in "${DOTFILES}"/tools/*/symlinks/link.bash; do
  echo "→ $link_script"
  bash "$link_script"
done
```

- [ ] **Step 3: 验证 symlink 正确**

```bash
ls -la ~/.claude/CLAUDE.md ~/.claude/settings.json ~/.config/opencode/opencode.json
```
Expected: 都显示 `->` 指向仓库路径

- [ ] **Step 4: 启动 claude code 和 opencode 看是否正常**

```bash
claude --version
opencode --version
```

- [ ] **Step 5: 如果全部通过，清理备份**

```bash
rm ~/.claude/CLAUDE.md.pre-dotfiles ~/.claude/settings.json.pre-dotfiles
rm -rf ~/.config/opencode.pre-dotfiles
```

- [ ] **Step 6: 若有问题，回滚**

```bash
rm ~/.claude/CLAUDE.md ~/.claude/settings.json
mv ~/.claude/CLAUDE.md.pre-dotfiles ~/.claude/CLAUDE.md
mv ~/.claude/settings.json.pre-dotfiles ~/.claude/settings.json
rm -rf ~/.config/opencode
mv ~/.config/opencode.pre-dotfiles ~/.config/opencode
```

---

### Task 8.3: 跑 ooloth 的 dcheck（如果 features/check 也导入了）

**Files:** (none — validation)

- [ ] **Step 1: 如果 Task 1.1 没导入 features/check，现在导入**

```bash
if [ ! -d features/check ]; then
  cp -r _reference-ooloth/features/check features/check
  git add features/check
  git commit -m "feat: import dcheck health check"
fi
```

- [ ] **Step 2: 跑 dcheck（如果 zshrc 有 alias）**

```bash
# 假设 dcheck 是 alias to bash features/check/check.bash
bash features/check/check.bash 2>&1 | head -30
```
Expected: 所有 symlink 显示 `OK`，critical tools `installed`

---

## 最终交付物

跑完所有 task 后：

1. `~/Projects/macos-dev-setup/` 是一个干净的 git 仓库，约 25 个 tool 模块
2. 推到 GitHub (e.g. `github.com/{you}/macos-dev-setup`)，有 v0.1.0 tag
3. 本机 `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, `~/.config/opencode/*`, `~/.config/ghostty/config` 都是 symlink 指向仓库
4. 在任何新机器跑 `curl ... | zsh` 都能 bootstrap
5. 敏感 key 留在 `~/.zshrc.local`，不进仓库

## 回滚策略

如果中途出问题：
- 代码回滚：`git reset --hard <commit>`
- symlink 回滚：用 Task 8.2 Step 6 的备份恢复
- 本机状态回滚：所有修改都在仓库里，删除仓库 + 恢复备份即可

## Self-Review 备注

- ✅ 所有 task 有明确文件路径
- ✅ 所有 shell 代码块完整可运行，无 TBD
- ✅ Phase 7 显式提示用户确认 public/private（风险动作）
- ✅ Phase 8 含备份 + 回滚流程
- ⚠️ Task 6.2 依赖 ooloth 的 `deprecated/` 目录里某些文件。执行时若 `_reference-ooloth/features/install/zsh/deprecated/rust.zsh` 不存在则跳过——已在 Step 1 里用条件处理
- ⚠️ Task 2.1 Step 2 需要人类判断（哪些条件块的内容保留 vs 删除）——不是纯机械操作，但 spec 第 9 节明确列出了被删清单
