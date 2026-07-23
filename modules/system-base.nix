# modules/system-base.nix
# ==========================================
# 系统基础配置（语言时区、网络管理与电源逻辑）
# ==========================================
{ pkgs, ... }:
{
  # 1. 语言与时区 (原 locale.nix)
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
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

  # 2. 网络管理 (原 networking.nix)
  networking.networkmanager = {
    enable = true;
    wifi = {
      backend = "iwd";
      powersave = false; # 关闭 WiFi 省电模式
      macAddress = "stable"; # 每个网络使用固定的随机 MAC 地址
    };
    dns = "systemd-resolved";
  };
  services.resolved.enable = true;
i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        #qt6Packages.fcitx5-configtool
        qt6Packages.fcitx5-chinese-addons
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-ice
          ];
        })
      ];
    };
  };
  # iwd 漫游策略调整：进一步降低漫游敏感度，减少多 AP 环境下的主动切换/断线
  networking.wireless.iwd.settings = {
    General = {
      RoamThreshold = "-80";
      RoamThreshold5G = "-90";
    };
    Scan = {
      DisablePeriodicScan = true;
    };
  };

  # 3. 电源与合盖逻辑 (原 logind.nix)
  # 合盖、电源键全部交给 niri（switch-events）或 Noctalia 处理，避免竞态漏锁屏
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
  };
}
