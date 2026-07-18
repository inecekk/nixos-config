# modules/base.nix
# ==========================================
# 系统基础设置：时区、状态版本、杂项开关
# ==========================================
{
  config,
  lib,
  pkgs,
  ...
}:
{
  #   programs.fish.enable = true; # 启用fish
  time.timeZone = "Asia/Shanghai";
  time.hardwareClockInLocalTime = false;
  system.stateVersion = "26.05";
  
# 在系统环境初始化阶段执行的操作
  environment.extraInit = ''
    # 显式向 DBus 同步 Wayland 关键环境变量
    # 替换过时的 --all 参数，消除 systemd 的弃用警告，
    # 并确保所有在桌面会话中启动的应用都能正确获取显示服务器地址和会话类型。
    dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP
  '';
  # 日志过滤
  systemd.settings.Manager = {
    LogLevel = "err";
  };
  systemd.user.settings.Manager = {
    LogLevel = "err";
  };

  # 临时文件清理（用户缓存）
  systemd.tmpfiles.rules = [
    "e ~lk/.cache - - - 7d"
    "e ~lk/.config/materialgram/Cache - - - 7d"
    "e ~lk/.config/google-chrome/Default/Cache - - - 7d"
    "e ~lk/.config/Code/Cache - - - 7d"
    "e ~lk/.config/QQ/*/Cache - - - 7d"
  ];

  nixpkgs.config.allowUnfree = true;
  programs.fuse.userAllowOther = true;
  systemd.coredump.settings.Coredump.MaxUse = "100M";

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemKeepFree=1G
    MaxRetentionSec=1week
    RateLimitIntervalSec=30s
    RateLimitBurst=1000
  '';

  # 免密码挂载
  security.sudo.extraRules = [
    {
      users = [ "lk" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/mount";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/umount";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # 禁用 WiFi 省电
  networking.networkmanager.wifi.powersave = false;

  # ---------- 文档瘦身 ----------
  documentation.nixos.enable = false;
  documentation.info.enable = false;
  documentation.doc.enable = false;
  documentation.man.enable = false; # 不要 man

  # 精简语言环境
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "zh_CN.UTF-8/UTF-8"
  ];

  # 禁用不需要的服务
  # --- 禁用传统/冗余服务 ---
   services.xserver.enable = false;    # 彻底禁用 X11 服务
  services.printing.enable = false;   # 禁用打印
  services.avahi.enable = false;      # 禁用网络发现
  services.gnome.core-utilities.enable = false; # 禁用 GNOME 全家桶
  services.geoclue2.enable = false;
  services.packagekit.enable = false;
}
