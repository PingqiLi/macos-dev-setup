# macos-dev-setup

我的 macOS 个人开发环境 bootstrap 仓库 —— 把一台**全新 Mac** 在 5–10 分钟内配置成可用的 Python / Node 全栈 + AI 编码工作环境。

> Fork 改造自 [ooloth/dotfiles](https://github.com/ooloth/dotfiles)，去掉 60% 用不到的工具，加入 Claude Code / OpenCode / mempalace 等 AI 工具的安装与配置同步。

---

## 一键 bootstrap（新机器）

```sh
# 1. 装 Xcode CLT（如果还没有）
xcode-select --install

# 2. 跑 setup
curl -s https://raw.githubusercontent.com/PingqiLi/macos-dev-setup/main/features/setup/setup.zsh | zsh
```

setup.zsh 会询问确认后依次：装 Homebrew → 切到 brew zsh → 跑每个 `tools/*/*/install.bash` → 创建符号链接 → 应用 macOS 系统设置 → 提示重启。

---

## 仓库结构

```
features/
├── setup/setup.zsh              # 一键入口
├── install/zsh/                 # 顺序执行的安装阶段
│   ├── tools.zsh                # 跑所有 tools/*/*/install.bash（跳过 _bootstrap）
│   ├── symlinks.zsh             # 创建所有配置 symlinks
│   └── macos.zsh                # 应用 macOS defaults

tools/                           # 按 group 分层（自包含）
├── _bootstrap/                  # 预置依赖（总是最先跑）
│   ├── homebrew/                # 安装 Homebrew
│   └── zsh-switch/              # 切换默认 shell 到 brew zsh
├── shell/                       # 必装：zsh, bat, eza, fzf, vim, ...
├── git/                         # 必装：git, gh, lazygit
├── macos/                       # 必装：系统 defaults, m-cli, Raycast
├── python/                      # 可选（默认开）：uv
├── node/                        # 可选（默认开）：fnm, node, pnpm
├── ai/                          # 可选（默认开）：claude, codex, opencode, mempalace
├── terminal/                    # 可选（默认开）：ghostty
├── multiplexer/                 # 可选（默认关）：tmux
├── containers/                  # 可选（默认关）：orbstack, lazydocker
└── apps/                        # 可选（默认关）：vscode, obsidian, browsers

每个工具目录结构：
tools/{group}/{tool}/
├── Brewfile             # brew/cask 条目
├── install.bash         # brew bundle + 后处理
├── update.bash          # brew upgrade
├── uninstall.bash       # brew uninstall（可选）
├── utils.bash           # TOOL_CONFIG_DIR 等（如有 config）
├── config/              # 配置文件（symlink 到 ~/.config 等）
├── shell.zsh            # env vars / aliases（被 tools.zsh 自动 source）
└── symlinks/link.bash   # 创建该工具的 symlinks（可选）

groups.toml              # group 元数据（required/default/description）

docs/
├── specs/               # 设计文档
└── plans/               # 实施计划
```

---

## 软件清单速览（约 50 项）

| 类别 | 工具 |
|---|---|
| **终端 & Shell** | Ghostty · zsh + Powerlevel10k · zsh-autosuggestions · zsh-syntax-highlighting · JetBrainsMono Nerd Font |
| **AI 编码工具** | Claude Code (npm) · Codex (cask) · OpenCode + oh-my-opencode (插件) · mempalace (uv tool) |
| **编辑器** | VSCode + 25 个精选扩展（Python/Node/AI/Remote/Catppuccin） |
| **Git** | git · git-delta · gh · lazygit |
| **Python 运行时** | uv（Python 版本 + 包 + global CLI 工具，三合一） |
| **Node 运行时** | fnm（版本） · pnpm（包） |
| **CLI 增强** | bat · eza · fd · ripgrep · fzf · zoxide · jq · yq · sd · btop · httpie · tree · direnv · atuin · gnu-sed · coreutils |
| **多路复用** | tmux · gitmux |
| **macOS 工具** | m-cli · mas · Raycast |
| **容器** | OrbStack · lazydocker |
| **GUI 应用** | Obsidian · Chrome · Edge |

详细分类与排除清单：`docs/specs/2026-04-20-macos-dev-setup-design.md`

---

## 日常使用

### Python 由 `uv` 管

这台机器**不用 pyenv / pipx / poetry**，一切 Python 相关都走 `uv`：

| 需求 | 命令 |
|---|---|
| 装一个 Python 版本 | `uv python install 3.12` |
| 在项目里用某个版本 + 创建 venv | `uv venv --python 3.12` |
| 装项目依赖 | `uv add requests` |
| 跑命令（自动 venv） | `uv run python my_script.py` |
| **装一个全局 CLI 工具**（重要） | `uv tool install <pkg>` |
| 升级一个 global 工具 | `uv tool upgrade <pkg>` |
| 卸载一个 global 工具 | `uv tool uninstall <pkg>` |
| 一次性运行某工具（不安装） | `uvx <pkg> --help` |

global tools 装到 `~/.local/share/uv/tools/<pkg>/`，binary 链接到 `~/.local/bin/`（已在 PATH）。当前已装：mempalace、claude-monitor、basedpyright 等。

要在仓库里"声明"一个 global Python 工具，参考 `tools/ai/mempalace/`：建文件夹 + 写 `install.bash` 调 `uv tool install`。

### Node 由 `fnm` 管版本，`pnpm` 装包

```sh
fnm list-remote                # 看可用 node 版本
fnm install --lts              # 装最新 LTS
fnm default <version>          # 设全局默认
pnpm add <package>             # 项目依赖
pnpm install -g <pkg>          # 全局 npm CLI（如 claude-code 就是这样装的）
```

### 装一个新软件 / 更新

```sh
cd ~/Projects/macos-dev-setup

# 装单个工具
bash tools/<group>/<tool>/install.bash

# 升级单个工具
bash tools/<group>/<tool>/update.bash

# 升级所有
for u in tools/*/*/update.bash; do bash "$u"; done
```

### 加一个新工具到仓库

最快路径：复制现有的最小工具作模板。

```sh
cp -r tools/containers/orbstack tools/<group>/<新工具名>
# 然后编辑：
#   tools/<group>/<新工具名>/Brewfile     ← 改 cask/brew 名字
#   tools/<group>/<新工具名>/install.bash ← 改 emoji 和 info 文案
#   tools/<group>/<新工具名>/update.bash
#   tools/<group>/<新工具名>/uninstall.bash
```

无需修改 `setup.zsh` 或别的地方 —— `features/install/zsh/tools.zsh` 会自动找到新文件夹。

### 改一个工具的配置

工具的配置在 `tools/<group>/<tool>/config/`，**不要直接改 `~/.config/<tool>/`**（那是 symlink 指向仓库）。

```sh
$EDITOR tools/terminal/ghostty/config/config   # 改完保存
# 在 Ghostty 里按 Cmd+Shift+R 重载
git commit -am "feat(ghostty): adjust font size"
```

---

## API Key / 密钥管理

**所有密钥走 `~/.zshrc.local`，永远不进 git**。bootstrap 后：

```sh
cp tools/shell/zsh/config/zshrc.local.example ~/.zshrc.local
$EDITOR ~/.zshrc.local
```

填进去：

```sh
export OPENROUTER_API_KEY="..."
export ANTHROPIC_API_KEY="..."
export OPENAI_API_KEY="..."
```

`tools/shell/zsh/config/core.zsh` 末尾会自动 `source ~/.zshrc.local`。配置文件中引用密钥用 `{env:NAME}` 占位（OpenCode 已是这格式）。

---

## 常见问题

**Q：改了 `tools/<X>/config/` 但没生效**  
A：symlink 没刷新，跑 `bash features/install/zsh/symlinks.zsh`。

**Q：新装了一个 brew 工具但 alias 报错**  
A：当前 shell 没 reload，`exec zsh` 或新开终端窗口。

**Q：Ghostty 默认没最大化 / 字号要调**  
A：`maximize=true` 在 macOS 上是已知 bug。我们用 `window-save-state=always`：手动 option-click 绿色按钮 zoom 一次后会被记住。字号改 `tools/ghostty/config/config` 的 `font-size`。

**Q：iTerm2 当前 session 不受影响吗？**  
A：对。Bootstrap 改的是 `~/.zshrc` 等文件 + brew 安装；运行中的 zsh 已加载到内存，**新开 tab/window 才用新配置**。Docker 容器、运行中的 Claude Code session 都不受影响。

---

## 完整重新部署

```sh
# 完全重置（小心，会删本地仓库）
cd ~ && rm -rf ~/Projects/macos-dev-setup
curl -s https://raw.githubusercontent.com/PingqiLi/macos-dev-setup/main/features/setup/setup.zsh | zsh
```

设计文档：`docs/specs/`  
实施计划：`docs/plans/`

## License

MIT
