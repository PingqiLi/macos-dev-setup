# CLAUDE.md

本仓库的 Claude 使用指引。

## 仓库性质

这是一个个人 macOS 开发环境 bootstrap 仓库。功能是：
- 在新机器上跑一条命令 → 装好所有软件 + 应用配置 + 设置 macOS 系统级 defaults
- 在已有机器上做 dotfiles 的版本管理（每个 tool 的 config 通过 symlink 到 `~/.config/...`、`~/.claude/`、VSCode user dir 等）

## 修改原则

**1. 新加一个工具**

在 `tools/{group}/{tool}/` 下建文件夹，模板参考任一现有工具（如 `tools/containers/orbstack/` 是个最小例子）：

```
tools/{group}/{tool}/
├── Brewfile             # brew/cask 条目
├── install.bash         # brew bundle + 可选后处理
├── update.bash          # brew upgrade
├── uninstall.bash       # brew uninstall
├── utils.bash           # TOOL_CONFIG_DIR 等（如有 config）
├── config/              # 配置文件（如有）
└── symlinks/link.bash   # 把 config/* 链到 TOOL_CONFIG_DIR
```

Group 对应关系见 `groups.toml`（shell / git / macos / python / node / ai / terminal / multiplexer / containers / apps）。

写完之后**不需要**手动加进 setup.zsh — `features/install/zsh/tools.zsh` 会自动遍历所有 `tools/*/*/install.bash`（跳过 `_bootstrap`）。

**2. 改 shell 脚本**

所有 `*.bash` 必须通过 `shellcheck`：

```sh
shellcheck tools/{tool}/*.bash features/**/*.bash
```

`.shellcheckrc` 已配置项目级规则，优先用它而非每文件 disable comment。

**3. 改 Claude Code / OpenCode 配置**

改仓库副本，不要直接改 `~/.claude/` 或 `~/.config/opencode/`（那是 symlink 指向仓库）：
- Claude：`tools/ai/claude/config/{CLAUDE.md, settings.json}`
- OpenCode：`tools/ai/opencode/config/{opencode.json, oh-my-opencode.json, ...}`

改完 commit 即可，symlink 会自动反映。

**4. 引入新的 API key / 密钥**

**绝不能 commit 密钥**。一律走 `~/.zshrc.local`（gitignored）：
- 用户复制 `tools/shell/zsh/config/zshrc.local.example` → `~/.zshrc.local`
- 在里面 `export FOO_API_KEY=...`
- 配置文件用 `{env:FOO_API_KEY}` 占位（OpenCode 已用此格式）

## 不要做的事

- 不要把 `_reference-ooloth/`（上游 ooloth/dotfiles 的本地 clone）的内容 commit 进仓库 — 它是 gitignored 的参考
- 不要直接改 `docs/specs/` 和 `docs/plans/` 里的设计/计划文档（除非是真的要修订设计）
- 不要在 `tools/{tool}/Brewfile` 里写明文 API key / token / 密码
- 不要 commit `~/.zshrc.local` 或任何 `*.local` 文件

## Symlinks 失效时

如果你改了 `tools/{tool}/config/` 但发现没生效，可能是 symlink 没更新：

```sh
DOTFILES=~/Projects/macos-dev-setup
bash "${DOTFILES}/features/install/zsh/symlinks.zsh"
```

## 关键路径

- `DOTFILES = ${HOME}/Projects/macos-dev-setup`（全部脚本基准路径）
- 用户 zsh 入口：`~/.zshrc` → 间接 source `tools/shell/zsh/config/core.zsh`
- 用户 Claude 入口：`~/.claude/{CLAUDE.md, settings.json}` → symlink 到 `tools/ai/claude/config/`
- 用户 OpenCode 入口：`~/.config/opencode/*` → symlink 到 `tools/ai/opencode/config/`
- Setup skill：`.claude/skills/macos-setup/SKILL.md` → symlink 到 `tools/ai/claude/config/skills/macos-setup/`
