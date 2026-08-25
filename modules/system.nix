# modules/system.nix
# 系统核心基础配置
{ pkgs, lib, ... }:
{
  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;
  programs.fuse.userAllowOther = true;

  # ----------------------------------------------------
  # 1. 软件包拦截覆写（从源头彻底切断隐形大包）
  # ----------------------------------------------------
  nixpkgs.config.packageOverrides = pkgs: {
    # 彻底拦截 fcitx5-gtk（省掉近 1GB 的 GTK4 依赖树）
    fcitx5-gtk = pkgs.emptyDirectory;
    # 彻底拦截 GNOME Portal（防止打包整个 gnome-desktop）
    xdg-desktop-portal-gnome = pkgs.emptyDirectory;
  };

  # ----------------------------------------------------
  # 2. 精简与优化配置
  # ----------------------------------------------------
  # 关闭系统文档以减少软件包节点
  documentation = {
    enable = false;
    nixos.enable = false;
    info.enable = false;
    doc.enable = false;
    man.enable = false;
  };

  # 显式关闭 32 位图形驱动，彻底释放 32Bit 依赖树
  hardware.graphics = {
    enable = true;
    enable32Bit = lib.mkForce false;
  };

  # 精简 Portal：只保留极简 GTK Portal
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "gtk" ];
  };

  # 区域与语言设置
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

  # ----------------------------------------------------
  # 3. 网络配置 & iwd + networkd 稳定度修复
  # ----------------------------------------------------
  networking = {
    useDHCP = false; # 关闭全局全局 DHCP，交由 networkd 按网卡配置
    useNetworkd = true;
    wireless.iwd.enable = true;
    nameservers = [
      "223.5.5.5"    # 阿里 DNS（国内响应极快，避免 dae 假死）
      "119.29.29.29" # 腾讯 DNS
    ];
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;
    # 明确指示 systemd-networkd 自动为 wlan0 抓取 IP，解决 DORMANT 状态
    networks."10-wlan" = {
      matchConfig.Name = "wlan*";
      networkConfig = {
        DHCP = "yes";
        IgnoreCarrierLoss = "3s";
      };
    };
  };

  services.resolved.enable = true;

  networking.wireless.iwd.settings = {
    General = {
      # 避免与 systemd-networkd 冲突，IP 分配交给 networkd
      EnableNetworkConfiguration = false;
    };
    Network = {
      EnableIPv6 = true;
    };
    Scan = {
      # 禁用周期后台扫描（显著减少丢包和高延迟）
      DisablePeriodicScan = true;
    };
  };

  # ----------------------------------------------------
  # 4. 系统服务与后台精简
  # ----------------------------------------------------
  services.printing.enable = false; # CUPS 打印
  hardware.sane.enable = false;     # 扫描仪
  systemd.oomd.enable = false;

  # 电源与 Wayland 事件
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
  };

  environment.extraInit = ''
    dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP
  '';

  # 系统日志与 Coredump 限制
  systemd.settings.Manager.LogLevel = "err";
  systemd.user.settings.Manager.LogLevel = "err";

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemKeepFree=1G
    MaxRetentionSec=1week
    RateLimitIntervalSec=30s
    RateLimitBurst=1000
  '';

  systemd.coredump.settings.Coredump.MaxUse = "100M";

  # 自动清理缓存
  systemd.tmpfiles.rules = [
    "e ~lk/.cache - - - 7d"
    "e ~lk/.config/materialgram/Cache - - - 7d"
    "e ~lk/.config/google-chrome/Default/Cache - - - 7d"
    "e ~lk/.config/Code/Cache - - - 7d"
    "e ~lk/.config/QQ/*/Cache - - - 7d"
  ];

  # 提权规则
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

  # 系统工具
  services.vnstat.enable = true;
  environment.systemPackages = with pkgs; [
    vnstat
  ];
}
