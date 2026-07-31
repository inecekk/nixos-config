# modules/system.nix
# 系统核心基础配置
{ pkgs, lib, ... }:
{  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;
  programs.fuse.userAllowOther = true;

  documentation = {
    enable = false;
    nixos.enable = false;
    info.enable = false;
    doc.enable = false;
    man.enable = false;
  }; # 关闭系统文档减少占用

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
  }; # 中文区域设置

  networking.wireless.iwd.enable = true;
  networking.useNetworkd = true;
  systemd.network.enable = true;
  # 禁用 CUPS 打印服务 (Cupsd & Cups.path)
  services.printing.enable = false;

  # 禁用 SANE 扫描仪服务
  hardware.sane.enable = false;
  systemd.oomd.enable = false;
  systemd.network.wait-online.enable = false;
  services.resolved.enable = true; # 网络配置

  networking.wireless.iwd.settings = {
    General = {
      RoamThreshold = "-60";
      RoamThreshold5G = "-70";
    };
    Scan = {
      DisablePeriodicScan = true;
    };
  }; # iwd无线优化

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
  }; # 交给Wayland桌面处理电源事件

  environment.extraInit = ''
    dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP
  ''; # 更新Wayland环境变量

  systemd.settings.Manager.LogLevel = "err";
  systemd.user.settings.Manager.LogLevel = "err";

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemKeepFree=1G
    MaxRetentionSec=1week
    RateLimitIntervalSec=30s
    RateLimitBurst=1000
  ''; # 限制日志大小

  systemd.coredump.settings.Coredump.MaxUse = "100M"; # 限制崩溃日志

  systemd.tmpfiles.rules = [
    "e ~lk/.cache - - - 7d"
    "e ~lk/.config/materialgram/Cache - - - 7d"
    "e ~lk/.config/google-chrome/Default/Cache - - - 7d"
    "e ~lk/.config/Code/Cache - - - 7d"
    "e ~lk/.config/QQ/*/Cache - - - 7d"
  ]; # 自动清理缓存

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
  ]; # 磁盘挂载免密

  services.vnstat.enable = true; # 网络流量统计

  environment.systemPackages = with pkgs; [
    vnstat
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  }; # 使用内存压缩，防止浏览器占满内存
}
