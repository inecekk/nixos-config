{ pkgs, lib, ... }:
{
  # ========== 1. 禁用所有其他 DM ==========
  services.greetd.enable = false;
  services.displayManager.sddm.enable = false;
  # 注意：不要设置 services.displayManager.ly.enable，避免触发有 bug 的模块逻辑
  security.pam.services.lk={};
  # ========== 2. 手动创建 ly.service ==========
  systemd.services.ly = {
    description = "Ly Display Manager";
    after = [ "getty.target" "systemd-user-sessions.service" ];
    conflicts = [ "getty@tty1.service" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.ly}/bin/ly";
      Restart = "always";
      RestartSec = "5s";
      TTYPath = "/dev/tty1";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      
      # Ly 需要 root 权限操作 TTY
      User = "root";
      Group = "root";
      
      # 安全加固
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      NoNewPrivileges = false; # Ly 需要 exec 替换为会话
    };
    
    wantedBy = [ "graphical.target" ];
  };

  # ========== 3. 禁用 tty1 的默认 getty，防止冲突 ==========
  systemd.services."getty@tty1".enable = false;

  # ========== 4. 确保 Niri 会话文件存在 ==========
  programs.niri.enable = true;

  # ========== 5. Ly 配置文件（通过 environment.etc 注入）==========
  environment.etc."ly/config.ini".text = ''
    [ly]
    bg=#1e1e2e
    fg=#cdd6f4
    border_fg=#89b4fa
    animate=false
   session=niri
    [banner]
    text=\x1b[38;2;137;180;250m██╗   ██╗\x1b[0m\n\x1b[38;2;166;227;236m██║   ██║\x1b[0m\n\x1b[38;2;198;208;245m██║   ██║\x1b[0m\n\x1b[38;2;243;139;168m██╗ ██╔╝\x1b[0m\n\x1b[38;2;249;226;175m ╚████╝\x1b[0m\n\x1b[38;2;137;180;250m  ╚═══╝ \x1b[0m
  '';
}
