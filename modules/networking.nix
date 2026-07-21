# modules/networking.nix
# ==========================================
# 网络管理与 XDG 桌面门户配置
# ==========================================
{ pkgs, ... }:
{
  networking.networkmanager = {
    enable = true;
    wifi = {
      backend = "iwd";
      powersave = false; # 关闭 WiFi 省电模式，解决连接不稳定问题
      macAddress = "stable"; # 每个网络使用固定的随机 MAC 地址
    };
    dns = "systemd-resolved";
  };
  services.resolved.enable = true;

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
}
