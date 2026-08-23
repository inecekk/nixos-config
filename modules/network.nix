{ config, pkgs, ... }:
{
  # 确保开启了 systemd-networkd
  networking.useNetworkd = true;

  # 对应你原先的 systemd/network/ 配置
  systemd.network.networks = {
    # 1. 针对有线和通用接口的配置
    "20-wire-wireless" = {
      matchConfig.Name = [ "en*" "eth*" "wlan*" "wlp*" ];
      networkConfig = {
        DHCP = "yes";
      };
    };

    # 2. 针对无线网卡的专用配置 (对应你的 25-wireless.network)
    "25-wireless" = {
      matchConfig.Name = "wl*";
      networkConfig = {
        DHCP = "yes";
        MulticastDNS = "yes";
      };
    };
  };
}
