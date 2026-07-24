# modules/home/bash.nix
# ═══════════════════════════════
# Bash 快捷命令说明
# ═══════════════════════════════
#
# 日常修改:
#   rebuild
#   - 应用当前 NixOS 配置
#   - 不更新 nixpkgs
#   - 自动 Git 提交并推送 GitHub
#
# 系统升级:
#   upgrade
#   - 更新 flake.lock
#   - 更新 nixpkgs
#   - 更新系统软件
#   - 自动 Git 提交并推送 GitHub
#   - 清理旧 generation，仅保留20代
#
# 测试:
#   ntest
#   - 测试配置，不切换默认系统
#
# 查看版本:
#   gens
#   - 查看 NixOS generation
#
# 音乐:
#   music
#   - tmux 启动 MusicFox + Cava
#
# 网络:
#   net
#   - 重启 NetworkManager
#   - 打开 nmtui
#
# 使用:
#   修改配置 → ntest → rebuild
#   软件升级 → upgrade
#
# ═══════════════════════════════

{ pkgs, ... }:

{
  programs.bash = {
    enable = true;

    initExtra = ''
      # ═══════════════════════════════
      # 环境变量
      # ═══════════════════════════════
      export EDITOR="vim"
      export VISUAL="vim"

      # ═══════════════════════════════
      # NixOS 日常构建
      # 不更新 nixpkgs
      # ═══════════════════════════════
      rebuild() {
        sudo -v || return 1
        cd /etc/nixos || return 1

        git add -A
        local start_time end_time elapsed gen tag
        start_time=$(date +%s)

        echo "🔨 开始构建 NixOS..."

        if sudo nixos-rebuild switch --flake .#nixos; then
          end_time=$(date +%s)
          elapsed=$((end_time-start_time))
          gen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -1 | awk '{print $1}')
          tag="gen-$gen-$(date +%Y%m%d-%H%M%S)"

          git commit -m "gen-$gen $(date +%m-%d_%H:%M) ''${elapsed}s" --allow-empty
          git tag "$tag"
          git push --follow-tags 2>/dev/null

          echo "✅ 构建完成"
          echo "📦 Generation: $gen"
          echo "⏱️ 时间: ''${elapsed}s"
          echo "🏷️ Tag: $tag"
        else
          echo "❌ 构建失败"
          return 1
        fi

        cd - >/dev/null
      }

      # ═══════════════════════════════
      # NixOS 系统升级
      # 更新 flake + 软件版本
      # ═══════════════════════════════
      upgrade() {
        sudo -v || return 1
        cd /etc/nixos || return 1

        echo "🔄 更新 Flake..."
        nix flake update
        git add -A

        local start_time end_time elapsed gen tag
        start_time=$(date +%s)

        echo "🚀 开始升级 NixOS..."

        if sudo nixos-rebuild switch --flake .#nixos; then
          end_time=$(date +%s)
          elapsed=$((end_time-start_time))
          gen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -1 | awk '{print $1}')
          tag="gen-$gen-$(date +%Y%m%d-%H%M%S)"

          git commit -m "upgrade gen-$gen $(date +%m-%d_%H:%M)" --allow-empty
          git tag "$tag"
          git push --follow-tags 2>/dev/null

          echo "🧹 清理旧 generation..."
          sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +20
          sudo nix-collect-garbage -d

          echo "✅ 升级完成"
          echo "📦 Generation: $gen"
          echo "⏱️ 时间: ''${elapsed}s"
          echo "🏷️ Tag: $tag"
        else
          echo "❌ 升级失败"
          return 1
        fi

        cd - >/dev/null
      }

      # ═══════════════════════════════
      # 测试配置
      # ═══════════════════════════════
      ntest() {
        cd /etc/nixos || return 1
        echo "🧪 测试配置..."
        sudo nixos-rebuild test --flake .#nixos
        cd - >/dev/null
      }

      # ═══════════════════════════════
      # Generation 查看
      # ═══════════════════════════════
      gens() {
        sudo nix-env -p /nix/var/nix/profiles/system --list-generations
      }

      # ═══════════════════════════════
      # MusicFox + Cava
      # ═══════════════════════════════
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
      # 网络工具
      # ═══════════════════════════════
      net() {
        sudo systemctl restart NetworkManager &&
        sudo nmtui
      }

      # ═══════════════════════════════
      # Git 分支显示
      # ═══════════════════════════════
      git_branch() {
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        [ -n "$branch" ] && echo "git:($branch)"
      }

      # ═══════════════════════════════
      # Shell 提示符
      # ═══════════════════════════════
      export PS1='\[\033[38;5;111m\]\u\[\033[38;5;81m\]@\[\033[38;5;114m\]\h \[\033[38;5;250m\]· \w \[\033[38;5;135m\]$(git_branch) \[\033[38;5;221m\]\t\[\033[0m\]\n'
    '';
  };
}
