# LK NixOS Configuration

基于 **NixOS Flakes + Home Manager + Niri Wayland** 的个人桌面配置。

特点：

- Niri Wayland 平铺窗口管理
- Noctalia 桌面 Shell
- Home Manager 管理用户环境
- Fcitx5 + Rime 中文输入
- PipeWire 音频
- dae 网络代理
- 模块化 Nix 配置


## 目录结构


.
├── flake.nix # Flake 入口
├── flake.lock # 依赖锁定
├── hardware-configuration.nix # 硬件配置
├── install.sh # 安装脚本
│
├── modules
│ ├── boot.nix # 引导配置
│ ├── hardware.nix # 硬件/驱动
│ ├── system.nix # 系统服务
│ ├── packages.nix # 软件包
│ ├── nix-settings.nix # Nix 设置
│ ├── dae.nix # dae 代理
│ │
│ └── home
│ ├── niri.nix # Niri 配置
│ ├── niri-binds.kdl # 快捷键
│ ├── terminal-input.nix # 终端/输入法
│ ├── mpd-mako-mpv.nix # 音乐/通知/播放器
│ └── rnote-noctalia.nix # 桌面 Shell
│
└── pkgs
└── dae-v2.nix # 自定义包



## 使用


检查配置：

```bash
sudo nixos-rebuild dry-build --flake .

应用配置：

sudo nixos-rebuild switch --flake .

更新依赖：

nix flake update

检查 Niri：

niri validate
