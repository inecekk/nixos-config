# modules/home/bash.nix
{ pkgs, ... }:

{
  programs.bash = {
    enable = true;

    # 直接使用 raw string（''...''）引入原生 Shell 代码
    # 在单个单引号括起来的字符串中，像 $gen, $(date) 这些完全不需要写 $$ 转义！
    initExtra = ''
      # ==============================================================================
      # 环境变量设置 (Environment Variables)
      # ==============================================================================
      export EDITOR="vim"
      export VISUAL="vim"

      # ==============================================================================
      # NixOS 配置管理 (Rebuild & Test)
      # ==============================================================================

      # NixOS 测试配置
      ntest() {
          cd /etc/nixos || return 1
          echo "[TEST] 测试 NixOS 配置..."
          sudo nixos-rebuild test
          cd - >/dev/null || return
      }

      # NixOS 正式部署与 Git 联动
      rebuild() {
          sudo -v || return 1
          cd /etc/nixos || return 1

          git add -A
          local start_time
          start_time=$(date +%s)

          echo "[BUILD] 开始构建 NixOS..."
          if sudo nixos-rebuild switch; then
              local end_time elapsed gen tag
              end_time=$(date +%s)
              elapsed=$((end_time - start_time))

              gen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -1 | awk '{print $1}')
              
              git commit -m "gen-''${gen}: $(date +%m-%d_%H:%M) (''${elapsed}s)" --allow-empty
              tag="gen-''${gen}-$(date +%Y%m%d-%H%M%S)"
              git tag "$tag"
              git push --follow-tags

              echo ""
              echo "[OK] NixOS 更新完成"
              echo "Generation: $gen"
              echo "Time: ''${elapsed}s"
              echo "Tag: $tag"
          else
              echo "[FAIL] NixOS 构建失败"
              cd - >/dev/null || return 1
              return 1
          fi

          cd - >/dev/null || return
      }

      # ==============================================================================
      # NixOS 世代与清理 (Generations & Clean)
      # ==============================================================================

      # 查看世代列表
      last10() {
          nixos-rebuild list-generations | head -n 11
      }
      alias gens='last10'

      # 彻底清理所有旧世代，只保留当前世代并释放磁盘空间
      alias nixclean="sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations old && sudo nix-collect-garbage -d && sudo nixos-rebuild switch"

      # 安全清理：仅删除 3 天前的世代
      alias nixclean-3d="sudo nix-collect-garbage --delete-older-than 3d && sudo nixos-rebuild switch"

      # ==============================================================================
      # 音乐终端 (上方全屏 MusicFox + 下方 Cava)
      # ==============================================================================
      unalias music 2>/dev/null
      function music() {
          tmux kill-session -t music 2>/dev/null
          # 1. 新建 session
          tmux new-session -d -s music
          # 2. 上下切分：将底部 25% 留给 cava
          tmux split-window -v -p 25 -t music
          # 3. 上方（Pane 0）运行 musicfox，下方（Pane 1）运行 cava
          tmux send-keys -t music:0.0 'musicfox' C-m
          tmux send-keys -t music:0.1 'cava' C-m
          # 4. 聚焦上方 musicfox 并进入
          tmux select-pane -t music:0.0
          tmux attach-session -t music
      }

      # ==============================================================================
      # 网络与系统工具 (Network & Utilities)
      # ==============================================================================

      # 重启网络并进入 nmtui 界面
      net() {
          sudo systemctl restart NetworkManager && sudo nmtui
      }

      # ==============================================================================
      # 终端提示符与 Git 状态 (Prompt Settings)
      # ==============================================================================

      git_branch() {
          local branch
          branch=$(git symbolic-ref --short HEAD 2>/dev/null)
          if [ -n "$branch" ]; then
              echo "git:($branch)"
          fi
      }

      # 自定义终端 PS1 提示符
      export PS1='\[\033[38;5;111m\]\u\[\033[38;5;81m\]@\[\033[38;5;114m\]\h \[\033[38;5;250m\]· \w \[\033[38;5;135m\]$(git_branch) \[\033[38;5;221m\]\t\[\033[0m\]\n'
    '';
  };
}
