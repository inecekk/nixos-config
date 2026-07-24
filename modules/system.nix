# modules/system.nix
# ==========================================
# 系统核心基础（Locale、网络、电源、日志/清理与系统服务设置）
# ==========================================
{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # 1. 系统版本与基础开关
  # ---------------------------------------------------------------------------
  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;
  programs.fuse.userAllowOther = true;

  # 文档瘦身（完全不生成本地文档）
  documentation = {
    enable = false;
    nixos.enable = false;
    info.enable = false;
    doc.enable = false;
    man.enable = false;
  };

  # ---------------------------------------------------------------------------
  # 2. 语言、时区与区域设置
  # ---------------------------------------------------------------------------
  time.timeZone = "Asia/Shanghai";
  time.hardwareClockInLocalTime = false;

  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "zh_CN.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # ---------------------------------------------------------------------------
  # 3. 网络与无线管理 (NetworkManager + iwd)
  # ---------------------------------------------------------------------------
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    wifi = {
      backend = "iwd";
      powersave = false; # 关闭 WiFi 省电模式
      macAddress = "stable"; # 固定随机 MAC
    };
  };
  services.resolved.enable = true;

  # iwd 漫游与扫描策略调整
  networking.wireless.iwd.settings = {
    General = {
      RoamThreshold = "-80";
      RoamThreshold5G = "-90";
    };
    Scan = {
      DisablePeriodicScan = true;
    };
  };

  # ---------------------------------------------------------------------------
  # 4. 电源、合盖与会话初始化
  # ---------------------------------------------------------------------------
  # 合盖、电源键全部交给 Wayland 合成器（niri/Noctalia）处理
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
  };

  # DBus 环境激活配置（确保 Wayland 环境变量正确传递给全局会话）
  environment.extraInit = ''
    dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP
  '';

  # ---------------------------------------------------------------------------
  # 5. 系统日志、缓存自动清理与 Coredump 限制
  # ---------------------------------------------------------------------------
  # 日志过滤只留错误
  systemd.settings.Manager.LogLevel = "err";
  systemd.user.settings.Manager.LogLevel = "err";

  # 限制 Journald 日志体积
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemKeepFree=1G
    MaxRetentionSec=1week
    RateLimitIntervalSec=30s
    RateLimitBurst=1000
  '';

  # 限制 Coredump 转储文件大小
  systemd.coredump.settings.Coredump.MaxUse = "100M";

  # 用户缓存自动清理（7天）
  systemd.tmpfiles.rules = [
    "e ~lk/.cache - - - 7d"
    "e ~lk/.config/materialgram/Cache - - - 7d"
    "e ~lk/.config/google-chrome/Default/Cache - - - 7d"
    "e ~lk/.config/Code/Cache - - - 7d"
    "e ~lk/.config/QQ/*/Cache - - - 7d"
  ];

  # ---------------------------------------------------------------------------
  # 6. 安全权限与特权配置
  # ---------------------------------------------------------------------------
  # 用户免密挂载/卸载磁盘
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

#7. 网络流量统计
services.vnstat.enable = true;

environment.systemPackages = with pkgs; [
  vnstat
];

}
