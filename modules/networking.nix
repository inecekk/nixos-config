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

}
