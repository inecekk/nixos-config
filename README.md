# LK NixOS Configuration

基于 **NixOS Flakes + Home Manager + Niri Wayland** 的模块化个人桌面配置。

跨发行版支持：配置架构兼容 **NixOS** 与 **Arch Linux** 等传统 Linux 发行版，所有应用 `.config` 统一纳管并通过软链接进行部署。

---

## 🌟 特点

* **窗口管理**：Niri Wayland 平铺窗口管理器
* **桌面 Shell**：Noctalia Desktop Shell
* **配置纳管**：`.config/` 统一存放在 Git 仓库中，支持跨平台无缝同步（NixOS / Arch Linux）
* **输入法**：Fcitx5（小鹤双拼）
* **网络代理**：dae 核心分流
* **环境部署**：Home Manager + Flake 声明式系统构建

---

## 📁 目录结构

```text
.
├── .config/                  # 纳管的应用配置文件 (Niri, Foot, Fcitx5, Btop, Cava 等)
├── flake.nix                 # Flake 系统入口
├── flake.lock                # 依赖锁定文件
├── hardware-configuration.nix # 硬件及分区配置
├── install.sh                # Live CD 环境系统的全新安装脚本
├── link-dotfiles.sh          # 跨平台建立 ~/.config 软链接铺设脚本
├── modules/
│   ├── boot.nix              # 引导配置
│   ├── dae.nix               # dae 代理服务
│   ├── network.nix           # 网络配置
│   ├── nix-settings.nix      # Nix 源与系统特性设置
│   ├── packages.nix          # 系统软件包列表
│   ├── scripts.nix           # 自定义系统脚本/别名 (含 rebuild 命令)
│   ├── system.nix            # 系统服务与环境变量
│   ├── users.nix             # 用户账号与权限管理
│   └── home/
│       ├── default.nix       # Home Manager 模块入口
│       ├── bash.nix          # Bash Shell 配置
│       ├── mpd-mako-mpv.nix  # MPD 音乐 / Mako 通知 / MPV 播放器配置
│       └── terminal-input.nix # 终端与输入法集成
└── README.md

```

---

## 🚀 使用与部署

### 1. 软链接配置部署 (NixOS / Arch Linux 统一)

在克隆仓库后或首次安装系统后，运行软链接脚本自动部署配置文件至 `~/.config/`：

```bash
./link-dotfiles.sh

```

> **注意**：日常修改软件配置直接编辑 `~/.config/` 目录中的文件即可（修改实时生效）。

### 2. 系统构建与更新 (NixOS)

使用封装好的 `rebuild` 命令自动一键构建并推送提交：

```bash
rebuild

```

或者手动使用原生命令：

```bash
# 检查语法与构建测试
sudo nixos-rebuild dry-build --flake .

# 切换并应用配置
sudo nixos-rebuild switch --flake .

# 更新 Flake 依赖
nix flake update

# 校验 Niri 配置文件
niri validate

```
