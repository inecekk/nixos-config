{
  pkgs,
  config,
  lib,
  ...
}:

let
  # 定义用户目录
  userHome = "/home/lk";
in
{
  programs.fish = {
    enable = true;

    # === 从 config.fish 迁移的别名 ===
    shellAliases = {
      # 清除屏幕（修复kitty滚动问题）
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
      celar = "printf '\\033[2J\\033[3J\\033[1;1H'";
      claer = "printf '\\033[2J\\033[3J\\033[1;1H'";
      q = "qs -c ii";

      # 如果安装了eza，使用eza替代ls
      ls = "eza --icons";

      # 其他常用别名
      ll = "eza -alh --icons";
      la = "eza -A --icons";
      l = "eza -l --icons";
      tree = "eza --tree --icons";

      # 系统更新别名
      update = "sudo nixos-rebuild switch";
      hmupdate = "home-manager switch";
      flakeupdate = "sudo nixos-rebuild switch --flake /etc/nixos#default";

      # Git别名
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";

      # 其他工具
      ff = "fastfetch";
      nixclean = "sudo nix-collect-garbage -d";

      # 代理相关
      proxy-on = "proxy_on";
      proxy-off = "proxy_off";
    };

    # === Fish交互式初始化 ===
    interactiveShellInit = ''
      # ==========================================
      # 1. 从 config.fish 迁移
      # ==========================================

      # 禁用欢迎信息
      set fish_greeting

      # ==========================================
      # 2. 代理函数
      # ==========================================
      function proxy_on
      set -gx http_proxy "http://127.0.0.1:7890"
      set -gx https_proxy "http://127.0.0.1:7890"
      set -gx all_proxy "socks5://127.0.0.1:7890"
      echo "[+] 终端代理已开启 (Port: 7890)"
      end

      function proxy_off
      set -e http_proxy
      set -e https_proxy
      set -e all_proxy
      echo "[-] 终端代理已关闭"
      end

      function ask_agy
      proxy_on
      agy $argv
      end

      # ==========================================
      # 3. Starship 提示符
      # ==========================================
      if command -v starship &>/dev/null
      starship init fish | source
      end

      # ==========================================
      # 4. 终端颜色配置 (Material You)
      # ==========================================
      if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
      cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
      end

      # ==========================================
      # 5. 从 conf.d/inir-env.fish 迁移
      # ==========================================
      set -gx INIR_VENV "$HOME/.local/state/quickshell/.venv"
      set -gx ILLOGICAL_IMPULSE_VIRTUAL_ENV "$INIR_VENV"

      # ==========================================
      # 6. 从 conf.d/inir-path.fish 迁移
      # ==========================================
      if not contains -- "$HOME/.local/bin" $PATH
      set -gx PATH "$HOME/.local/bin" $PATH
      end

      # ==========================================
      # 7. 从 conf.d/rustup.fish 迁移
      # ==========================================
      if not contains -- "$HOME/.cargo/bin" $PATH
      set -gx PATH "$HOME/.cargo/bin" $PATH
      end
      set -gx CARGO_HOME "$HOME/.cargo"
      set -gx RUSTUP_HOME "$HOME/.rustup"

      # ==========================================
      # 8. 基础环境变量
      # ==========================================
      set -gx EDITOR nvim
      set -gx VISUAL nvim
      set -gx TERM xterm-256color
      set -gx LANG zh_CN.UTF-8
      set -gx LC_ALL zh_CN.UTF-8

      # ==========================================
      # 9. 检查 eza 是否安装
      # ==========================================
      if not command -v eza &>/dev/null
      alias ls "ls --color=auto"
      end

      # ==========================================
      # 10. 登录时运行 fastfetch
      # ==========================================
      if status is-login
      fastfetch
      end

      # ==========================================
      # 11. 从 auto-Niri.fish 迁移
      # ==========================================
      # Auto start Niri on tty1
      if test -z "$DISPLAY" ;and test "$XDG_VTNR" -eq 1
      mkdir -p ~/.cache
      exec niri-session > ~/.cache/niri.log 2>&1
      end
    '';
  };

  # === 创建自定义函数目录 ===
}
