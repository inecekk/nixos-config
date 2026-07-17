# NixOS 个人配置

基于 NixOS Flakes 管理的个人系统配置，使用 [niri](https://github.com/YaLTeR/niri) 作为 Wayland 合成器，配合 home-manager 管理用户环境。

## 目录结构

```
.
├── dot-bashrc                  # bash 配置文件模板
├── flake.lock                  # flake 依赖锁定文件
├── flake.nix                   # flake 入口，定义系统与 home-manager 输出
├── hardware-configuration.nix  # 硬件自动检测配置（由 nixos-generate-config 生成）
├── install.sh                  # 一键安装/部署脚本
├── modules
│   ├── activation.nix          # 系统激活阶段相关配置
│   ├── base.nix                # 基础系统配置（语言环境、shell 启用等）
│   ├── boot.nix                # 引导加载器配置
│   ├── dae.nix                 # dae 透明代理服务配置
│   ├── filesystems.nix         # 文件系统与挂载点配置
│   ├── hardware.nix            # 显卡驱动、蓝牙等硬件相关配置
│   ├── home                    # home-manager 用户级配置
│   │   ├── default.nix         # home-manager 入口，汇总所有子模块 imports
│   │   ├── dms.nix.bak         # 已弃用：DMS 相关配置（保留备份）
│   │   ├── fcitx5-rime.nix     # fcitx5 + rime 中文输入法配置
│   │   ├── fish.nix            # fish shell 配置（别名、函数、环境变量）
│   │   ├── foot.nix            # foot 终端模拟器配置
│   │   ├── mako-mpd.nix        # mako 通知服务 + mpd 音乐播放器配置
│   │   ├── mpv-fastfetch.nix   # mpv 播放器与 fastfetch 系统信息展示配置
│   │   ├── niri-binds.kdl      # niri 快捷键绑定（独立文件，被 niri.nix 引入）
│   │   ├── niri.nix            # niri 合成器主配置
│   │   ├── noctalia.nix        # Noctalia 状态栏/桌面壳配置（当前使用中）
│   │   ├── rnote.nix           # rnote 手写笔记应用配置
│   │   ├── waybar.nix.bak      # 已弃用：waybar 状态栏配置（保留备份，供参考）
│   │   └── yambar.nix.bak      # 已弃用：yambar 状态栏配置（保留备份，供参考）
│   ├── locale.nix              # 系统语言/地区配置
│   ├── networking.nix          # 网络配置（NetworkManager 等）
│   ├── nix-settings.nix        # Nix 本身的设置（experimental-features、缓存等）
│   ├── packages.nix            # 系统级软件包列表
│   ├── scripts.nix             # 自定义脚本集合，供其他模块复用
│   ├── system-services.nix     # 系统服务：睡眠/唤醒、电源管理、音频、显示管理器等
│   └── users.nix               # 用户账户定义
├── pkgs
│   └── dae-v2.nix              # dae 代理软件的自定义 derivation
├── README.md                   # 本文档
└── result -> /nix/store/...    # nixos-rebuild build 产物软链（不纳入版本控制）
```

## 核心设计

### 窗口管理：niri

- 使用 [niri](https://github.com/YaLTeR/niri) 滚动平铺式 Wayland 合成器，配置在 `modules/home/niri.nix`，快捷键单独维护在 `modules/home/niri-binds.kdl`。
- 已启用窗口圆角（`geometry-corner-radius`）、阴影、焦点边框，并通过 `layout.gaps` / `layout.struts` 分别控制窗口间距与屏幕四边的整体留白。
- 通过 `layer-rule` 显式关闭了 Noctalia 状态栏/面板/dock/通知/OSD 的合成器背景模糊（`ext-background-effects`），需要 niri ≥ 26.04。

### 状态栏：Noctalia（当前） / waybar、yambar（已弃用）

- 当前使用 [Noctalia](https://docs.noctalia.dev/)（基于 quickshell 的 QML 桌面壳），配置见 `modules/home/noctalia.nix`。
- 曾评估过 `waybar`（C++/GTK，功能丰富但内存占用偏高）和 `yambar`（C 语言、极致轻量，但上游已停止开发），相关配置保留为 `.bak` 后缀供后续参考，未接入 `default.nix` 的 `imports`。

### 睡眠与电源管理

`modules/system-services.nix` 处理了以下几类问题：

- **抢占式睡眠前静音**：通过 `systemd.services.pre-suspend-mute`（挂在 `sleep.target` 之前）先停止 MPD、挂起 PipeWire 音频节点、物理静音声卡，避免睡眠瞬间残留音频重播的问题。
- **睡眠前收尾**：`powerManagement.powerDownCommands` 负责关闭蓝牙/WiFi、懒卸载可能导致睡眠卡死的挂载点、终止高耗能或持有 GPU 硬件上下文的用户进程（先 `SIGTERM` 再 `SIGKILL`，避免与显卡挂起流程竞争）。
- **只保留键盘作为唤醒源**：不再一刀切禁用所有 USB 控制器的 ACPI 唤醒能力（这曾是导致长时间睡眠后"睡死"、无法唤醒的根因），改为动态探测键盘所在的 USB 控制器并仅保留其唤醒能力。
- **唤醒后恢复**：`resumeCommands` 负责恢复网络、蓝牙、音频（含防止扬声器"滋滋"声的寄存器刷新技巧）。

### 网络代理：dae

- `modules/dae.nix` + `pkgs/dae-v2.nix` 提供基于 [dae](https://github.com/daeuniverse/dae) 的透明代理服务，通过 niri 的 `spawn-at-startup` 延迟启动，避免与其他开机项抢占资源。

### Shell：fish（登录 shell）

- 系统级通过 `programs.fish.enable = true;`（`modules/base.nix`）启用，登录 shell 通过 `users.defaultUserShell = pkgs.fish;` 或 `users.users.lk.shell = pkgs.fish;`（`modules/users.nix`）指定。
- 用户级配置（别名、代理开关函数、Starship 提示符、tty1 自动启动 niri 会话等）在 `modules/home/fish.nix`。

### 输入法与其他应用

- `fcitx5-rime.nix`：中文输入法（fcitx5 + rime 引擎）。
- `mako-mpd.nix`：桌面通知（mako）与音乐播放（mpd）。
- `foot.nix`：轻量终端模拟器。
- `mpv-fastfetch.nix` / `rnote.nix`：媒体播放与手写笔记相关配置。

## 常用命令

```bash
# 语法/求值检查，不实际切换（别名 ntest，定义在 dot-bashrc 或 fish 别名中）
sudo nixos-rebuild dry-build --flake .

# 正式应用配置
sudo nixos-rebuild switch --flake .

# 新建文件后需要先纳入 git 追踪，flakes 才能识别到该文件
git add -A

# 校验 niri 配置文件语法
niri validate

# 手动测试某个用户态程序（例如状态栏），便于直接看到报错信息
yambar    # 或 qs -c noctalia-shell
```

## 已知注意事项

- **Flakes 只读取 git 索引中的文件**：新建文件后若未 `git add`，`nixos-rebuild` 会报 `Path ... is not tracked by Git` 错误，务必先追踪再构建。
- **yambar 上游已停止维护**（[官方仓库](https://codeberg.org/dnkl/yambar) 标注 "NOT DEVELOPED ANYMORE"），目前没有确认活跃维护的继任 fork，`yambar.nix.bak` 仅作历史参考保留。
- **改动登录 shell 需要系统级同步启用**：例如设置 `users.users.lk.shell = pkgs.fish;` 前，必须先在某个系统模块里加上 `programs.fish.enable = true;`，否则 `nixos-rebuild` 会被内置 assertion 拦截。
- **KDL 配置文件的注释语法是 `//` 或 `/* */`**，不是 `#`；单行内多个并列节点需用分号或换行分隔，不能仅靠空格区分。
