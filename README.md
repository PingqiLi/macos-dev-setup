# macos-dev-setup

我的 macOS 开发环境 bootstrap 仓库。基于 [ooloth/dotfiles](https://github.com/ooloth/dotfiles) 精简改造而来，专注 Python / Node.js 全栈 + AI 编码工作流。

## 用途

在一台全新的 macOS 上，几分钟内配置好开发环境：终端、编辑器、Git、运行时、CLI 工具、容器、Claude Code / Codex / OpenCode 等 AI 工具，以及全局 macOS 系统设置。

## 前置条件

1. 连接互联网
2. 安装 Xcode Command Line Tools：
   ```sh
   xcode-select --install
   ```
3. （可选）更新 macOS：
   ```sh
   sudo softwareupdate --install --all --restart
   ```

## 安装

```sh
curl -s https://raw.githubusercontent.com/PingqiLi/macos-dev-setup/main/features/setup/setup.zsh | zsh
```

会做的事情（约 15 步，详见 `features/setup/setup.zsh`）：

1. 验证 macOS 环境，请求 sudo
2. clone 本仓库到 `~/Projects/macos-dev-setup`
3. 生成 SSH key + GitHub 认证
4. 安装 Homebrew、zsh、uv、Node、tmux
5. 跑 `tools/*/install.bash`（每个工具自带的 Brewfile + 后处理）
6. 创建符号链接：`tools/*/config/*` → `~/.config/...`、`~/.claude/`、VSCode user dir 等
7. 应用 macOS `defaults`（键盘加速、Dock 自动隐藏、截图位置等）
8. 提示重启

## 仓库结构

```
features/
├── setup/setup.zsh              # 入口 bootstrap
├── install/zsh/                 # 阶段安装脚本
│   ├── ssh.zsh / github.zsh     # SSH key + GitHub 认证
│   ├── homebrew.zsh / zsh.zsh   # Homebrew + 切到 Homebrew zsh
│   ├── uv.zsh / node.zsh / npm.zsh / tmux.zsh
│   ├── tools.zsh                # 跑所有 tools/*/install.bash
│   ├── symlinks.zsh             # 跑所有 tools/*/symlinks/link.bash
│   └── macos.zsh                # 跑 tools/macos/install.bash
└── update/                      # 更新逻辑（占位）

tools/
├── {tool}/
│   ├── Brewfile                 # 该工具要装什么
│   ├── config/                  # 配置文件（会 symlink 到 ~/.config/{tool} 等）
│   ├── install.bash             # brew bundle + 后处理
│   ├── update.bash              # brew upgrade
│   ├── uninstall.bash           # brew uninstall
│   ├── symlinks/link.bash       # 创建该工具的符号链接
│   └── utils.bash               # TOOL_CONFIG_DIR 等环境变量

docs/
├── specs/                       # 设计文档
└── plans/                       # 实施计划
```

## 软件清单

完整清单见 `docs/specs/2026-04-20-macos-dev-setup-design.md` 第 5 节。约 46 项 + 25 个 VSCode 扩展。

**主要类别**：
- 终端：Ghostty + zsh + Powerlevel10k + tmux + sesh
- AI：Claude Code (npm)、Codex (cask)、OpenCode (brew) + oh-my-opencode 插件
- 编辑器：VSCode + 25 个 Python/Node/AI 扩展
- 运行时：mise、uv、fnm、pnpm
- CLI：bat、eza、fd、ripgrep、fzf、zoxide、jq、yq、sd、btop、httpie、tree、direnv、atuin、gnu-sed、coreutils
- Git：git、git-delta、gh、lazygit
- 容器：OrbStack、lazydocker
- GUI：Obsidian、Chrome、Edge、Raycast

## API Key 管理

`~/.zshrc.local` 是机器本地覆盖，**不进 git**。bootstrap 后从 `tools/zsh/config/zshrc.local.example` 复制一份到 `~/.zshrc.local`，写入：

```sh
export OPENROUTER_API_KEY="..."
export ANTHROPIC_API_KEY="..."
export OPENAI_API_KEY="..."
```

`tools/zsh/config/core.zsh` 会在每次 zsh 启动时自动 source 它。

## 更新

```sh
cd ~/Projects/macos-dev-setup
git pull
# 跑各工具的 update.bash
for u in tools/*/update.bash; do bash "$u"; done
```

## 自定义

- **新加工具**：在 `tools/{你的工具}/` 下按现有模板建文件夹
- **改 macOS defaults**：编辑 `tools/macos/install.bash`
- **改 VSCode 扩展**：编辑 `tools/vscode/Brewfile`
- **改 Claude Code 配置**：改 `tools/claude/config/settings.json` 或 `tools/claude/config/CLAUDE.md`（不是 `~/.claude/`，那是 symlink）

## License

MIT
