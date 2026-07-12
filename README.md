# lk 的 NixOS 配置

基于 Nix Flakes 管理的 NixOS 桌面配置。

## 系统环境

* 系统：NixOS
* 架构：x86_64-linux
* 桌面环境：Niri Wayland
* 桌面 Shell：DankMaterialShell (DMS)
* 配置管理：Nix Flakes + Home Manager

## 目录结构

```text
/etc/nixos
├── flake.nix                    # Flake 入口，管理依赖和系统模块
├── flake.lock                   # 锁定依赖版本
├── hardware-configuration.nix   # 硬件自动生成配置
│
├── modules
│   ├── base.nix                 # 基础系统配置
│   ├── boot.nix                 # 引导和内核配置
│   ├── hardware.nix             # 硬件驱动配置
│   ├── networking.nix            # 网络配置
│   ├── locale.nix               # 中文环境、字体
│   ├── users.nix                # 用户配置
│   ├── packages.nix             # 系统级软件包
│   ├── nix-settings.nix         # Nix 参数、GC、优化
│   ├── dae.nix                  # dae 网络代理
│   │
│   └── home                    # Home Manager 配置
│       ├── default.nix          # 用户模块入口
│       ├── dms.nix              # DankMaterialShell
│       ├── niri.nix             # Niri 窗口管理器
│       ├── foot.nix             # Foot 终端
│       ├── fcitx5-rime.nix      # 输入法
│       ├── rnote.nix             # 手写笔记
│       └── rmpc.nix             # MPD 音乐控制
│
└── README.md                    # 配置说明
```

## 桌面架构

当前桌面采用纯 Wayland 方案：

```text
Niri
 │
 ├── DankMaterialShell
 │     ├── 状态栏
 │     ├── 启动器
 │     ├── 通知中心
 │     ├── 快捷控制
 │     └── 壁纸管理
 │
 ├── swayidle
 │     └── 自动息屏 / 锁屏
 │
 ├── foot
 │     └── Wayland 终端
 │
 └── yazi
       └── 终端文件管理
```

## 软件管理原则

### 系统级软件

放置：

```text
modules/packages.nix
```

用于：

* 硬件工具
* 系统工具
* Wayland 基础组件
* 必要依赖

### 用户软件

放置：

```text
modules/home/
```

用于：

* 桌面应用
* 配置文件
* Shell 环境
* 开发环境

## Flake 输入

主要依赖：

| 输入                | 用途       |
| ----------------- | -------- |
| nixpkgs           | 软件包源     |
| home-manager      | 用户环境管理   |
| zen-browser       | Zen 浏览器  |
| daeuniverse       | 网络代理     |
| DankMaterialShell | 桌面 Shell |

## 常用命令

进入配置目录：

```bash
cd /etc/nixos
```

更新 Flake：

```bash
nix flake update
```

查看依赖：

```bash
nix flake metadata
```

测试配置：

```bash
sudo nixos-rebuild test --flake .#nixos
```

应用配置：

```bash
sudo nixos-rebuild switch --flake .#nixos
```

查看历史版本：

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

回滚：

```bash
sudo nixos-rebuild switch --rollback
```

## 桌面软件

### 窗口管理

* Niri

### Shell

* DankMaterialShell

### 终端

* Foot

### 文件管理

* Yazi

### 音乐

* MPD
* rmpc

### 手写

* Rnote

### 浏览器

* Zen Browser
* Google Chrome

## 已移除组件

以下组件由 DMS 替代：

| 原组件    | 替代                         |
| ------ | -------------------------- |
| Waybar | DankMaterialShell          |
| fuzzel | DankMaterialShell Launcher |
| swaybg | DankMaterialShell 壁纸       |
| mako   | DankMaterialShell 通知       |

## 维护建议

修改配置前：

```bash
git status
```

查看变化：

```bash
git diff
```

重建失败时：

1. 查看错误模块
2. 检查最近修改文件
3. 使用上一代配置回滚

## 设计目标

* 使用纯 Wayland 桌面
* 减少重复桌面组件
* 模块化管理配置
* 使用 Flakes 固定环境
* 使用 Home Manager 管理用户环境
* 保持系统可恢复、可维护

