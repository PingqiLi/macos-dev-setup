# macOS 开发环境一键 Bootstrap 仓库 — 设计文档

- 创建日期：2026-04-20
- 仓库本地路径：`~/Projects/macos-dev-setup/`
- 上游模板：[`ooloth/dotfiles`](https://github.com/ooloth/dotfiles)（fork 后大幅精简）

## 1. 目标 (Goals)

把一台**全新 macOS** 在 5–10 分钟内配置成可以做 **Python / Node.js 全栈开发 + AI 算法工作** 的环境，包含：

1. 必要软件（终端、编辑器、Git、运行时、CLI 工具、容器、AI 编码工具、少量 GUI 应用）
2. 各软件的配置文件（zsh、ghostty、vscode、claude-code、opencode 等）
3. 全局 macOS 系统设置（键盘、Finder、Dock、截图、触控板）

**成功标准**：在干净 Mac 上跑一条 `curl … | zsh` 命令 → 输入密码 → 等待 → 重启 → 终端立刻可用。

## 2. 非目标 (Non-Goals)

- 不做 Linux / Windows 兼容
- 不做"work machine vs personal machine"差异（个人机一种就够）
- 不引入密钥管理软件（API key 用 `~/.zshrc.local` gitignored 文件即可）
- 不引入 vim 模式 / 不安装 Cursor / 不安装 Copilot
- 不试图同步 Claude Code 运行时状态（sessions / projects / history 等）

## 3. 方案选型 (Approach)

考虑过 3 种方式：

| 方案 | 选 | 理由 |
|---|---|---|
| **A. Brewfile + shell 脚本（fork ooloth/dotfiles）** | ✅ | 透明、可调试、迁移成本低、ooloth 的模块化结构成熟 |
| B. chezmoi（dotfile 管理器） | ❌ | 多一层抽象，对个人用途收益有限 |
| C. nix-darwin（声明式） | ❌ | 学习曲线陡，调试困难 |

**最终选 A**：fork `ooloth/dotfiles`，保留其每工具一文件夹的模块化设计，删去 60% 用不到的工具，加入 OpenCode / Claude Code 配置同步。

## 4. 仓库结构 (Repository Structure)

继承 ooloth 的模块化布局：

```
macos-dev-setup/
├── README.md
├── CLAUDE.md                       # Claude 在该仓库工作的指引
├── docs/
│   └── specs/
│       └── 2026-04-20-macos-dev-setup-design.md  # 本文档
├── features/
│   ├── setup/setup.zsh             # 入口 bootstrap 脚本
│   ├── install/zsh/                # 各阶段安装脚本（ssh、github、homebrew、symlinks、settings）
│   └── update/                     # 更新逻辑
└── tools/                          # 每个工具一个文件夹
    ├── {tool}/
    │   ├── Brewfile                # 该工具要装什么
    │   ├── config/                 # 该工具的配置文件
    │   ├── install.bash            # brew bundle + 必要后处理
    │   ├── update.bash             # brew upgrade 等
    │   ├── uninstall.bash          # 卸载
    │   ├── symlinks/link.bash      # 把 config/* 链到 ~/.config/{tool}/ 等
    │   └── shell.zsh               # 该工具的 env vars / aliases
```

**Fork 定制点**（必须改的 4 处）：

| 位置 | ooloth 原值 | 改成 |
|---|---|---|
| `features/setup/setup.zsh` | `${HOME}/Repos/ooloth/dotfiles` | `${HOME}/Projects/macos-dev-setup` |
| `features/setup/setup.zsh` 的 git clone URL | `https://github.com/ooloth/dotfiles.git` | 你 fork 后的 URL（在 GitHub 创建仓库后填入） |
| 所有 `tools/*/Brewfile` 中的 `if computer_name == "..."` 条件块 | ooloth 的机器名 | 删掉条件块，让所有保留的工具在所有机器上都装 |
| `README.md`, `CLAUDE.md` | ooloth 的内容 | 重写为本仓库说明 |

## 5. 软件清单 (Software Inventory)

总数约 46 项（不含 25 个 VSCode 扩展、不含 oh-my-opencode 插件）。按类别：

### 5.1 终端 & Shell
| 项 | 安装 | 说明 |
|---|---|---|
| ghostty | cask | 终端 |
| zsh | brew | Homebrew 版 zsh（替换系统自带） |
| zsh-autosuggestions | brew | 输入补全 |
| zsh-syntax-highlighting | brew | 语法高亮 |
| powerlevel10k | brew | 提示符主题 |
| font-jetbrains-mono-nerd-font | cask | 字体 |
| font-symbols-only-nerd-font | cask | 图标补充 |

### 5.2 AI 编码工具
| 项 | 安装 | 说明 |
|---|---|---|
| claude-code | `npm i -g @anthropic-ai/claude-code` | Claude 官方 CLI |
| codex | cask | OpenAI Codex CLI |
| opencode | brew | 第三方 AI agent |
| oh-my-opencode | opencode 插件（自动加载，不需手动装） | 在 opencode.json 里声明即可 |

### 5.3 编辑器
| 项 | 安装 | 说明 |
|---|---|---|
| visual-studio-code | cask | + 25 个精选扩展（见下） |

**精选 VSCode 扩展**（约 25 个，去掉 ooloth 原 80 个里的主题/语言外的）：
- Python：`ms-python.python`, `ms-python.vscode-pylance`, `charliermarsh.ruff`, `ms-python.mypy-type-checker`, `ms-python.debugpy`
- Jupyter：`ms-toolsai.jupyter`, `ms-toolsai.jupyter-renderers`
- JS/TS：`dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, `bradlc.vscode-tailwindcss`, `christian-kohler.npm-intellisense`, `christian-kohler.path-intellisense`
- Git：`eamodio.gitlens`, `vivaxy.vscode-conventional-commits`
- 配置/数据：`redhat.vscode-yaml`, `tamasfe.even-better-toml`, `editorconfig.editorconfig`, `mikestead.dotenv`
- 通用：`usernamehw.errorlens`, `ms-azuretools.vscode-docker`
- Remote：`ms-vscode-remote.remote-ssh`, `ms-vscode-remote.remote-ssh-edit`, `ms-vscode-remote.remote-containers`
- 主题：`catppuccin.catppuccin-vsc`, `catppuccin.catppuccin-vsc-icons`

### 5.4 Git
| 项 | 说明 |
|---|---|
| git | 最新版（替换系统 Xcode 自带的） |
| git-delta | 彩色 diff pager |
| gh | GitHub CLI |
| lazygit | TUI |

### 5.5 语言运行时
| 项 | 说明 |
|---|---|
| mise | 通用版本管理器（顶替 nvm/pyenv/rbenv） |
| uv | Python 包/项目管理（保持本机现有） |
| fnm | Node 版本管理（mise 也能管，先保留 fnm 与 ooloth 一致） |
| pnpm | Node 包管理 |

### 5.6 CLI 效率工具
| 项 | 替代什么 |
|---|---|
| bat | cat（语法高亮） |
| eza | ls（彩色 + 图标） |
| fd | find（快） |
| ripgrep | grep（快） |
| fzf | 模糊查找 |
| zoxide | cd（智能跳转） |
| jq | JSON 处理 |
| yq | YAML 处理 |
| sd | sed（友好语法） |
| btop | top |
| httpie | curl（友好） |
| tree | 目录树 |
| direnv | 自动加载 `.envrc` |
| atuin | shell 历史增强 |
| gnu-sed | macOS BSD sed → GNU sed |
| coreutils | macOS BSD coreutils → GNU coreutils |

### 5.7 多路复用
| 项 | 说明 |
|---|---|
| tmux | 终端多路复用 |
| sesh | tmux session 智能管理（fzf + zoxide 集成） |
| gitmux | tmux 状态栏显示 git 信息 |

### 5.8 macOS 系统 CLI
| 项 | 说明 |
|---|---|
| m-cli | 命令行操控 macOS 系统设置 |
| mas | App Store CLI（用于 brew bundle 装 App Store 应用，目前 Brewfile 里暂无 mas 条目，保留以备扩展） |

### 5.9 容器
| 项 | 说明 |
|---|---|
| orbstack | cask，替代 Docker Desktop（轻量、免费个人版） |
| lazydocker | TUI |

### 5.10 GUI 应用
| 项 | 说明 |
|---|---|
| obsidian | cask |
| google-chrome | cask |
| microsoft-edge | cask |
| raycast | cask（免费版够用） |

## 6. macOS 全局系统设置 (`tools/macos/`)

通过 `defaults write` 写入。基于 ooloth 现有 `features/install/zsh/settings.zsh`，**保留**：

- `NSGlobalDomain NSNavPanelExpandedStateForSaveMode = true`（默认展开保存对话框）
- `NSGlobalDomain AppleKeyboardUIMode = 3`（modal 中 Tab 可切换全部控件）
- `NSGlobalDomain AppleFontSmoothing = 2`（非 Apple LCD 字体平滑）
- `NSGlobalDomain AppleShowAllExtensions = true`（显示文件扩展名）
- `com.apple.finder FXDefaultSearchScope = "SCcf"`（Finder 默认搜索当前文件夹）
- `com.apple.finder ShowPathbar = true`
- `com.apple.finder ShowStatusBar = true`
- `chflags nohidden ~/Library`

**新增**（user 需求里要的）：

- 加快键盘 key repeat：`NSGlobalDomain KeyRepeat = 2`, `InitialKeyRepeat = 15`
- 截图位置：`com.apple.screencapture location = ~/Pictures/Screenshots`（先 `mkdir -p`）
- 截图格式 PNG：`com.apple.screencapture type = png`
- Dock 自动隐藏：`com.apple.dock autohide = true`
- Dock 不显示最近应用：`com.apple.dock show-recents = false`
- 触控板轻触点击：`com.apple.AppleMultitouchTrackpad Clicking = true` + `NSGlobalDomain com.apple.mouse.tapBehavior = 1`

**移除**（ooloth 有但用不到）：

- Safari debug menu（你不主要用 Safari）

## 7. 工具配置同步 (Configurations Synced from Local Machine)

以下是从本机现有配置抽出来放进仓库的内容：

### 7.1 Ghostty (`tools/ghostty/config/config`)

直接采用 ooloth 现成配置（Catppuccin Mocha + UbuntuMono），**改动**：
- `font-family` 改为 `JetBrainsMono Nerd Font`
- 保留 `keybind = shift+enter=text:\n`（Claude Code 多行输入）
- 保留 tmux 透传 keybinds

### 7.2 Claude Code (`tools/claude/`)

**同步的文件**：
- `~/.claude/CLAUDE.md` → `tools/claude/config/CLAUDE.md`
- `~/.claude/settings.json` → `tools/claude/config/settings.json`

**settings.json 含**：
- 6 个启用的插件：`superpowers`, `frontend-design`, `chrome-devtools-mcp`, `claude-hud`, `codex`, `ui-ux-pro-max`
- 4 个 marketplace 源（其中 3 个是 GitHub repo，1 个是官方内置）
- 自定义 statusLine（运行 claude-hud 插件的 dist/index.js）
- `alwaysThinkingEnabled = true`
- `skipDangerousModePermissionPrompt = true`

**插件不需要 vendor**：Claude Code 启动时按 settings.json 里的 marketplace 源自动从 GitHub 拉取并缓存到 `~/.claude/plugins/cache/`。MCP server（chrome-devtools-mcp）由插件提供，无需单独配置。

**不同步**（gitignore + 不创建 symlink）：
- `~/.claude/settings.local.json`（本机 override）
- `~/.claude/sessions/`, `projects/`, `todos/`, `tasks/`, `history.jsonl`, `transcripts/`, `shell-snapshots/`, `session-env/`, `file-history/`, `paste-cache/`
- `~/.claude/plugins/cache/`, `plugins/repos/`, `plugins/data/`
- `~/.claude/debug/`, `telemetry/`, `statsig/`
- `~/.claude.json`（runtime startup state）

### 7.3 OpenCode (`tools/opencode/`)

**同步的文件**：
- `~/.config/opencode/opencode.json` → `tools/opencode/config/opencode.json`
- `~/.config/opencode/oh-my-opencode.json` → `tools/opencode/config/oh-my-opencode.json`
- `~/.config/opencode/oh-my-opencode.openrouter-fallback.json` → `tools/opencode/config/...`
- `~/.config/opencode/package.json` → `tools/opencode/config/package.json`
- `~/.config/opencode/skills/` → `tools/opencode/config/skills/`
- `~/.config/opencode/switch-to-openrouter.sh` → `tools/opencode/config/switch-to-openrouter.sh`

**install.bash**：
1. `brew bundle --file=tools/opencode/Brewfile`（装 opencode）
2. 创建 symlinks
3. `cd ~/.config/opencode && bun install`（安装 `@opencode-ai/plugin` SDK）

**oh-my-opencode** 是 opencode 插件，opencode 启动时会按 `opencode.json` 里 `"plugin": ["oh-my-opencode@latest"]` 自动从 npm 加载。

**API Key**：`OPENROUTER_API_KEY` 通过 `~/.zshrc.local` 设置（gitignored），配置里用 `{env:OPENROUTER_API_KEY}` 占位。

### 7.4 zsh (`tools/zsh/`)

继承 ooloth：`zshrc`, `zshenv`, aliases，加上：

```sh
# In tools/zsh/config/zshrc 末尾
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

`~/.zshrc.local` 永远不进 git，存放：
- `OPENROUTER_API_KEY=...`
- `ANTHROPIC_API_KEY=...`（如有）
- `OPENAI_API_KEY=...`（如有）
- 任何机器特定的 export

### 7.5 Git (`tools/git/`)

继承 ooloth：`.gitconfig`, `.gitignore_global`，**确认本机 user.email = lipingqi2018@gmail.com 已设**。

### 7.6 VSCode (`tools/vscode/`)

- `Brewfile` 列出 25 个扩展（见 5.3）
- `config/settings.json`、`config/keybindings.json` 从本机导出
  - 路径：`~/Library/Application Support/Code/User/{settings,keybindings}.json`

### 7.7 其它工具配置

直接采用 ooloth 现有：`tmux/`, `lazygit/`, `bat/`, `fzf/`, `zoxide/`, `mise/`, `uv/`, `fnm/`, `httpie/`, `btop/`, `gh/`, `git/`。

## 8. Bootstrap 流程 (Setup Flow)

入口：`features/setup/setup.zsh`，依赖 ooloth 现有逻辑稍作精简：

1. 确认是 macOS（`uname == Darwin`）
2. 提示用户即将进行的步骤，等待确认（y/N）
3. 检查 git（Xcode CLT 是否装）
4. 获取 sudo 密码 + keep-alive
5. clone 本仓库到 `~/Projects/macos-dev-setup`（若未存在）
6. 生成 SSH key（如未有），引导加到 GitHub
7. 用 `gh auth login` 完成 GitHub 认证
8. 安装 Homebrew
9. 按 tools/ 顺序逐个 `brew bundle --file=tools/{tool}/Brewfile`
10. 把 zsh 切换为 Homebrew 版（`chsh -s /opt/homebrew/bin/zsh`）
11. 安装 mise / uv / fnm，装 latest Node + pnpm
12. `npm i -g @anthropic-ai/claude-code`
13. `cd ~/.config/opencode && bun install`
14. 跑所有 `tools/*/symlinks/link.bash` 创建符号链接
15. 跑 `tools/macos/install.bash` 应用全局系统设置
16. 提示重启

## 9. 删除的工具清单 (Excluded Tools)

明确从 ooloth 移除的（不需要）：

**GUI 应用**（19 项）：alfred, amphetamine, appcleaner, backblaze, carbon-copy-cloner, 1password, 1password-cli, hyperkey, meetingbar, neohtop, notion, pages, numbers, keynote, reeder, sip, speedtest, tailscale, things, vlc, zoom, firefox

**编辑器/终端**（2 项）：kitty, zed

**AI / 工具**（2 项）：gemini-cli, beads

**云/k8s**（5 项）：kubernetes (k9s/kubectl/kubectx/stern), opa, logcli, jira-cli

**语言运行时**（6 项）：bun, deno, gleam, zig, go, ruby（其依赖 gmp/libyaml/openssl@3）

**文件管理 TUI**（1 项）：yazi（按需可加回）

**其它**（2 项）：surfingkeys, vimium-c

## 10. 自检清单 (Self-Check)

- [ ] `setup.zsh` 跑完后 `which ghostty` / `which claude` / `which opencode` / `which codex` 都能找到
- [ ] `~/.config/ghostty/config` 是 symlink 指向仓库
- [ ] `~/.claude/CLAUDE.md` 和 `~/.claude/settings.json` 是 symlink
- [ ] 启动 Claude Code → 6 个插件自动下载完成 → `/help` 看到 superpowers 等 skill
- [ ] 启动 opencode → 用 oh-my-opencode 的 `/agent sisyphus` 等命令可用
- [ ] tmux + sesh 工作（`Ctrl+a o` 弹 fzf）
- [ ] `defaults read com.apple.dock autohide` 返回 `1`
- [ ] 截图触发 → 文件落到 `~/Pictures/Screenshots/`

## 11. 待定事项 / Future Work

**实施前需要解决**：

- **GitHub 仓库**：决定仓库名（默认 `macos-dev-setup`）和可见性（public / private），用 `gh repo create` 创建，把 URL 填到 `setup.zsh`
- **本机器名**：跑 `networksetup -getcomputername` 确认本机名，用于将来要做"多机器差异"时复用

**未来优化**：

- **OPENROUTER_API_KEY 怎么转移**：第一次新机器 setup 时，需要手动从旧机器复制到 `~/.zshrc.local`。未来可考虑用 1Password CLI。
- **VSCode 设置导出脚本**：bootstrap 不会备份，需要手动从本机一次性导出 `settings.json` / `keybindings.json` 到仓库。
- **Claude Code 项目级配置**（`.claude/` 在各项目里）：不在本仓库范围。
- **mise 工具集**：可后续在 `~/.config/mise/config.toml` 声明 Python/Node 版本。
- **OpenCode 升级**：本机当前 1.2.27，brew 上 1.4.0，bootstrap 会装最新。
