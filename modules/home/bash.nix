# modules/home/bash.nix
# ═══════════════════════════════
# Bash 快捷命令与环境变量配置
# ═══════════════════════════════
{ pkgs, ... }: {
  programs.bash = {
    enable = true;

    initExtra = ''
      # ═══════════════════════════════
      # 环境变量
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
        echo -e "  \033[38;5;221mnet\033[0m            - 重启 iwd 服务并进入 iwctl"
        echo -e "  \033[38;5;221mipinfo\033[0m         - 查看内网与外网 IP 地址"
        echo -e "  \033[38;5;221mkp <port>\033[0m      - 快速杀死指定端口的占用进程"
        echo -e "  \033[38;5;221mextract <file>\033[0m - 智能解压任意格式文件"
        echo -e "  \033[38;5;221mmusic\033[0m          - 启动 tmux + MusicFox + Cava"
        echo -e "  \033[38;5;221mmc\033[0m             - 后台播放本地音乐 (/home/lk/D/Music/)"
        echo -e "  \033[38;5;221mnh\033[0m             - 显示此帮助菜单"
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
      # Git 分支辅助函数
      # ═══════════════════════════════
      git_branch() {
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        [ -n "$branch" ] && echo "git:($branch)"
      }

      # ═══════════════════════════════
      # Shell 提示符 (单行紧凑美化版)
      # ═══════════════════════════════
      export PS1='\[\033[38;5;111m\]\u\[\033[38;5;81m\]@\[\033[38;5;114m\]\h \[\033[38;5;250m\]· \[\033[38;5;220m\]\w \[\033[38;5;135m\]$(git_branch) \[\033[38;5;243m\]\t \[\033[38;5;114m\]\$\[\033[0m\] '
    '';
  };
}
