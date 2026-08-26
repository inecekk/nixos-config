# modules/home/bash.nix
# ==========================================
# Bash 快捷命令与环境变量配置
# ==========================================
{ pkgs, ... }: {

  # ═══════════════════════════════
  # Bash 基础配置与函数扩展
  # ═══════════════════════════════
  programs.bash = {
    enable = true;

    initExtra = ''
      # ═══════════════════════════════
      # 基础环境变量
      # ═══════════════════════════════
      export EDITOR="vim"
      export VISUAL="vim"
      export LANG="zh_CN.UTF-8"
      export LC_ALL="zh_CN.UTF-8"

      # ═══════════════════════════════
      # 帮助菜单 (支持 nh / -h / --help)
      # ═══════════════════════════════
      bash_help() {
        echo -e "\033[38;5;114mNixOS 快捷命令指南:\033[0m"
        echo -e "  \033[38;5;221mrebuild\033[0m        - 应用当前 NixOS 配置（自动 Git 提交）"
        echo -e "  \033[38;5;221mupgrade\033[0m        - 更新 Flake、系统软件并深度清理垃圾"
        echo -e "  \033[38;5;221mntest\033[0m          - 测试 NixOS 配置（消除 dirty 干扰，不改 boot）"
        echo -e "  \033[38;5;221mgens\033[0m           - 查看系统 Generations 历史版本"
        echo -e "  \033[38;5;221mnfind <pkg>\033[0m    - 搜索 Nixpkgs 软件包"
        echo -e "  \033[38;5;221mnet\033[0m              - 重启 iwd 服务并进入 iwctl"
        echo -e "  \033[38;5;221mipinfo\033[0m          - 查看内网与外网 IP 地址"
        echo -e "  \033[38;5;221mkp <port>\033[0m      - 快速杀死指定端口的占用进程"
        echo -e "  \033[38;5;221mextract <file>\033[0m - 智能解压任意格式文件"
        echo -e "  \033[38;5;221mmusic\033[0m          - 启动 tmux + MusicFox + Cava"
        echo -e "  \033[38;5;221mmc\033[0m              - 后台播放本地音乐 (/home/lk/D/Music/)"
        echo -e "  \033[38;5;221mbfu / bsl\033[0m       - Btrfs 空间查阅 / 子卷快照列表"
        echo -e "  \033[38;5;221mnh\033[0m              - 显示此帮助菜单"
      }

      # 拦截 -h 参数
      if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        bash_help
      fi

      # ═══════════════════════════════
      # 常用快捷别名 (Aliases)
      # ═══════════════════════════════
      alias nh='bash_help'
      alias c='clear'
      alias ..='cd ..'
      alias ...='cd ../..'
      alias ll='ls -alF --color=auto'
      alias la='ls -A --color=auto'
      alias l='ls -CF --color=auto'
      alias grep='grep --color=auto'
      alias mc='nohup mpv /home/lk/D/Music/ >/dev/null 2>&1 &'
      alias pcmanfm='pcmanfm --no-desktop'

      # ═══════════════════════════════
      # Btrfs 快捷命令与帮助汉化
      # ═══════════════════════════════
      alias bfu='sudo btrfs filesystem usage /'
      alias bsl='sudo btrfs subvolume list -p /'
      alias bds='sudo btrfs device stats /'
      alias bsh='sudo btrfs filesystem show'

      btrfs() {
        if [[ "$1" == "--help" || "$1" == "-h" || "$1" == "help" ]]; then
          echo -e "\033[38;5;114mBtrfs 工具箱用法指南:\033[0m"
          echo -e "  \033[38;5;221mbtrfs [选项] <命令组> [<子命令>] [参数]\033[0m\n"
          echo -e "\033[38;5;111m全局选项:\033[0m"
          echo -e "  --format <格式>      输出格式 (text, json)"
          echo -e "  -v, --verbose        显示详细日志"
          echo -e "  -q, --quiet          仅输出错误"
          echo -e "  --dry-run            仅测试运行，不作实际更改\n"
          echo -e "\033[38;5;111m核心命令组 (Command Groups):\033[0m"
          echo -e "  \033[38;5;221mfilesystem (fi)\033[0m   文件系统整体信息与任务 (用法: btrfs fi us /)"
          echo -e "  \033[38;5;221msubvolume (sub)\033[0m    管理子卷与快照 (创建/删除/列出)"
          echo -e "  \033[38;5;221mdevice (dev)\033[0m       底层物理设备管理与状态监控"
          echo -e "  \033[38;5;221mscrub\033[0m              校验并修复数据与元数据校验和"
          echo -e "  \033[38;5;221mbalance\033[0m            跨设备平衡数据或重组 Block Group"
          echo -e "  \033[38;5;221mproperty\033[0m           修改文件系统/子卷属性 (如压缩模式)\n"
          echo -e "\033[38;5;111m💡 本地快捷别名 (快捷键): \033[0m"
          echo -e "  \033[38;5;114mbfu\033[0m                 - 查看根目录真实物理空间占用 (filesystem usage)"
          echo -e "  \033[38;5;114mbsl\033[0m                 - 列出所有子卷与快照 (subvolume list)"
          echo -e "  \033[38;5;114mbds\033[0m                 - 查看底层磁盘坏道与 I/O 报错统计 (device stats)"
          echo -e "  \033[38;5;114mbsh\033[0m                 - 列出本机所有 Btrfs 分区信息 (filesystem show)"
        else
          command btrfs "$@"
        fi
      }

      # ═══════════════════════════════
      # Niri 帮助菜单汉化
      # ═══════════════════════════════
      niri() {
        if [[ "$1" == "msg" && ("$2" == "help" || "$2" == "--help" || "$2" == "-h") ]]; then
          echo -e "\033[38;5;114m与当前运行的 Niri 窗口管理器实例通信:\033[0m"
          echo -e "  \033[38;5;221mniri msg [选项] <子命令>\033[0m\n"
          echo -e "\033[38;5;111m常用子命令:\033[0m"
          echo -e "  \033[38;5;221moutputs\033[0m           列出已连接的显示器"
          echo -e "  \033[38;5;221mworkspaces\033[0m        列出所有工作区"
          echo -e "  \033[38;5;221mwindows\033[0m           列出当前打开的所有窗口"
          echo -e "  \033[38;5;221mfocused-window\033[0m    打印当前获取焦点的窗口信息"
          echo -e "  \033[38;5;221mfocused-output\033[0m    打印当前获取焦点的显示器信息"
          echo -e "  \033[38;5;221maction\033[0m            执行指定动作 (如切换工作区、关窗等)"
          echo -e "  \033[38;5;221mpick-color\033[0m        用鼠标在屏幕上取色"
          echo -e "  \033[38;5;221mpick-window\033[0m       用鼠标选取窗口并打印其信息"
          echo -e "  \033[38;5;221mkeyboard-layouts\033[0m  获取当前配置的键盘布局"
          echo -e "  \033[38;5;221mversion\033[0m           打印当前运行的 Niri 版本"
          echo -e "  \033[38;5;221mevent-stream\033[0m      持续接收合成器发出的事件流\n"
          echo -e "\033[38;5;111m选项:\033[0m"
          echo -e "  -j, --json        将输出格式化为 JSON"
        elif [[ "$1" == "--help" || "$1" == "-h" || "$1" == "help" ]]; then
          echo -e "\033[38;5;114mNiri - 无限滚动平铺 Wayland 合成器:\033[0m"
          echo -e "  \033[38;5;221mniri [选项] [-- <启动命令>...]\033[0m"
          echo -e "  \033[38;5;221mniri <子命令>\033[0m\n"
          echo -e "\033[38;5;111m核心子命令:\033[0m"
          echo -e "  \033[38;5;221mmsg\033[0m               向运行中的 Niri 发送指令或查询状态"
          echo -e "  \033[38;5;221mvalidate\033[0m          校验配置文件 (config.kdl) 语法是否正确"
          echo -e "  \033[38;5;221mcompletions\033[0m       生成 Shell 补全脚本\n"
          echo -e "\033[38;5;111m选项:\033[0m"
          echo -e "  -c, --config <路径>  指定配置文件路径 (默认: \$XDG_CONFIG_HOME/niri/config.kdl)"
          echo -e "  --session           作为主合成器导入环境变量到 systemd/D-Bus"
          echo -e "  -V, --version       打印版本号"
        else
          command niri "$@"
        fi
      }

      # ═══════════════════════════════
      # Noctalia 帮助菜单汉化
      # ═══════════════════════════════
      noctalia() {
        if [[ "$1" == "msg" && ("$2" == "-h" || "$2" == "--help" || "$2" == "help") ]]; then
          echo -e "\033[38;5;114mNoctalia 进程通信指令控制台 (noctalia msg):\033[0m"
          echo -e "  \033[38;5;221mnoctalia msg <命令> [参数]\033[0m\n"
          echo -e "\033[38;5;111m📊 顶栏/面板控制 (Bar & Panels):\033[0m"
          echo -e "  bar-show / bar-hide / bar-toggle         显示/隐藏/切换顶栏"
          echo -e "  panel-open / panel-close / panel-toggle  打开/关闭/切换指定面板 (如 control-center)"
          echo -e "  dock-show / dock-hide / dock-toggle      显示/隐藏/切换 Dock 栏\n"
          echo -e "\033[38;5;111m🔊 音量与亮度管理 (Volume & Brightness):\033[0m"
          echo -e "  volume-up / volume-down / volume-mute    调节/静音扬声器音量"
          echo -e "  mic-volume-up / mic-down / mic-mute      调节/静音麦克风"
          echo -e "  brightness-up / brightness-down          调节屏幕亮度\n"
          echo -e "\033[38;5;111m🎨 主题、夜览与壁纸 (Theme & Wallpaper):\033[0m"
          echo -e "  theme-mode-toggle                        切换深色/浅色模式"
          echo -e "  nightlight-toggle                        开启/关闭夜览护眼模式"
          echo -e "  wallpaper-next / wallpaper-random        切换下一张/随机壁纸"
          echo -e "  wallpaper-set <路径>                     设置固定壁纸\n"
          echo -e "\033[38;5;111m📡 快捷系统功能 (System Controls):\033[0m"
          echo -e "  wifi-toggle / bluetooth-toggle           开关 Wi-Fi 与蓝牙"
          echo -e "  caffeine-toggle                          开关防休眠 (Caffeine) 状态"
          echo -e "  screenshot-fullscreen / screenshot-region 全屏截图 / 区域选择截图"
          echo -e "  clipboard-clear                          清空剪贴板历史"
          echo -e "  notification-clear-active                清除当前桌面通知"
          echo -e "  config-reload                            立即重载 Noctalia 配置文件\n"
          echo -e "\033[38;5;243m💡 提示: 完整参数请参考官方文档 https://noctalia.dev\033[0m"
        elif [[ "$1" == "dmenu" && ("$2" == "-h" || "$2" == "--help") ]]; then
          echo -e "\033[38;5;114mNoctalia dmenu - 从标准输入读取列表并调用启动器:\033[0m"
          echo -e "  \033[38;5;221mcat list.txt | noctalia dmenu [选项]\033[0m\n"
          echo -e "\033[38;5;111m选项:\033[0m"
          echo -e "  -p, --prompt <文本>  设置应用启动器输入框提示语"
          echo -e "  -h, --help           显示此帮助信息"
        elif [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
          echo -e "\033[38;5;114mNoctalia - Wayland 桌面 Shell 工具箱:\033[0m"
          echo -e "  \033[38;5;221mnoctalia <命令> [选项]\033[0m\n"
          echo -e "\033[38;5;111m核心命令:\033[0m"
          echo -e "  \033[38;5;221mmsg <命令>\033[0m            向后台进程发送运行控制指令 (音量/壁纸/面板等)"
          echo -e "  \033[38;5;221mdmenu [选项]\033[0m          从标准输入读取项目并在 Launcher 弹出供选择"
          echo -e "  \033[38;5;221mtheme [图片] [选项]\033[0m   根据图片智能提取颜色配色方案"
          echo -e "  \033[38;5;221mconfig <命令>\033[0m         校验并测试配置文件合法性"
          echo -e "  \033[38;5;221mfirefox-theme\033[0m        管理与 Firefox 主题色的协同集成"
          echo -e "  \033[38;5;221mplugins\033[0m              离线插件开发与管理工具"
          echo -e "  \033[38;5;221mcompletions <shell>\033[0m  生成 Shell 补全脚本\n"
          echo -e "\033[38;5;111m全局选项:\033[0m"
          echo -e "  -d, --daemon         以后台守护进程方式运行"
          echo -e "  -v, --version        显示版本信息"
          echo -e "  -h, --help           显示帮助信息\n"
          echo -e "\033[38;5;243m更多详细信息请访问: https://noctalia.dev\033[0m"
        else
          command noctalia "$@"
        fi
      }

      # ═══════════════════════════════
      # NixOS 管理命令
      # ═══════════════════════════════
      rebuild() {
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
          echo "用法: rebuild"
          echo "功能: 应用 /etc/nixos 配置，记录 Git commit 并打 tag 提交到远程。"
          return 0
        fi

        sudo -v || return 1
        pushd /etc/nixos >/dev/null || return 1

        git add -A
        local start_time end_time elapsed gen tag
        start_time=$(date +%s)

        echo "🔨 开始构建 NixOS..."

        if sudo nixos-rebuild switch --flake .#nixos; then
          end_time=$(date +%s)
          elapsed=$((end_time - start_time))
          gen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -1 | awk '{print $1}')
          tag="gen-$gen-$(date +%Y%m%d-%H%M%S)"

          git commit -m "gen-$gen $(date +%m-%d_%H:%M) ''${elapsed}s" --allow-empty
          git tag "$tag"
          git push --follow-tags || echo "⚠️ Git push 失败（请检查网络或 Remote 配置）"

          echo "✅ 构建完成 | Generation: $gen | 耗时: ''${elapsed}s | Tag: $tag"
        else
          echo "❌ 构建失败"
          popd >/dev/null
          return 1
        fi

        popd >/dev/null
      }

      upgrade() {
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
          echo "用法: upgrade"
          echo "功能: 更新 flake.lock，升级系统包，删除旧版本并深度清理 Store。"
          return 0
        fi

        sudo -v || return 1
        pushd /etc/nixos >/dev/null || return 1

        echo "🔄 更新 Flake..."
        nix flake update
        git add -A

        local start_time end_time elapsed gen tag
        start_time=$(date +%s)

        echo "🚀 开始升级 NixOS..."

        if sudo nixos-rebuild switch --flake .#nixos; then
          end_time=$(date +%s)
          elapsed=$((end_time - start_time))
          gen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -1 | awk '{print $1}')
          tag="gen-$gen-$(date +%Y%m%d-%H%M%S)"

          git commit -m "upgrade gen-$gen $(date +%m-%d_%H:%M)" --allow-empty
          git tag "$tag"
          git push --follow-tags || echo "⚠️ Git push 失败（请检查网络）"

          echo "🧹 清理旧 generation 并释放空间..."
          sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +20
          sudo nix-collect-garbage -d
          sudo rm -rf /nix/var/nix/builds/*
          nix-store --optimise

          echo "✅ 升级与清理完成 | Generation: $gen | 耗时: ''${elapsed}s"
        else
          echo "❌ 升级失败"
          popd >/dev/null
          return 1
        fi

        popd >/dev/null
      }

      ntest() {
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
          echo "用法: ntest"
          echo "功能: 测试当前 NixOS 配置，不写入启动项（自动 git add 消除 dirty 干扰）。"
          return 0
        fi
        pushd /etc/nixos >/dev/null || return 1
        git add -A >/dev/null 2>&1
        echo "🧪 测试配置..."
        sudo nixos-rebuild test --flake .#nixos
        popd >/dev/null
      }

      gens() {
        sudo nix-env -p /nix/var/nix/profiles/system --list-generations
      }

      nfind() {
        if [ -z "$1" ]; then
          echo "用法: nfind <软件名>"
          return 1
        fi
        nix search nixpkgs "$1"
      }

      # ═══════════════════════════════
      # 网络与系统增强工具
      # ═══════════════════════════════
      net() {
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
          echo "用法: net"
          echo "功能: 重启 iwd 服务并进入 iwctl 交互终端。"
          return 0
        fi
        sudo systemctl restart iwd && iwctl
      }

      ipinfo() {
        echo -e "\033[38;5;114m[内网 IP]\033[0m"
        ip -4 addr show | grep -v '127.0.0.1' | grep -oP 'inet \K[\d.]+'
        echo -e "\033[38;5;221m[公网 IP]\033[0m"
        curl -s ifconfig.me || echo "网络不可用"
        echo ""
      }

      kp() {
        if [ -z "$1" ]; then
          echo "用法: kp <端口号>"
          return 1
        fi
        local pid
        pid=$(lsof -t -i:"$1")
        if [ -n "$pid" ]; then
          echo "杀死占用端口 $1 的进程 PID: $pid"
          kill -9 $pid
        else
          echo "端口 $1 当前未被占用"
        fi
      }

      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' 无法通过 extract 解压" ;;
          esac
        else
          echo "'$1' 不是有效的路径"
        fi
      }

      music() {
        tmux kill-session -t music 2>/dev/null
        tmux new-session -d -s music
        tmux split-window -v -p 25 -t music
        tmux send-keys -t music:0.0 'musicfox' C-m
        tmux send-keys -t music:0.1 'cava' C-m
        tmux select-pane -t music:0.0
        tmux attach-session -t music
      }

      # ═══════════════════════════════
      # Shell 提示符 (单行紧凑高性能版)
      # ═══════════════════════════════
      _prompt_git_branch() {
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        [[ -n "$branch" ]] && echo -e " \033[38;5;135mgit:($branch)\033[0m"
      }

      # 利用 PROMPT_COMMAND 预计算变量并对齐字符边界，解决长命令换行光标错位和按回车卡顿问题
      PROMPT_COMMAND='PS1="\[\033[38;5;111m\]\u\[\033[38;5;81m\]@\[\033[38;5;114m\]\h \[\033[38;5;250m\]· \[\033[38;5;220m\]\w\[\033[0m\]$(_prompt_git_branch) \[\033[38;5;243m\]\t \[\033[38;5;114m\]\$\[\033[0m\] "'
    '';
  };
}
