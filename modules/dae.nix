# /etc/nixos/modules/dae.nix
{
  pkgs,
  lib,
  ...
}: {
  # ----------------------------------------------------
  # dae 服务主体配置
  # ----------------------------------------------------
  services.dae = {
    enable = true;
    package = pkgs.dae;

    assets = with pkgs; [
      v2ray-geoip
      v2ray-domain-list-community
    ];

    openFirewall = {
      enable = true;
      port = 12345;
    };

    configFile = "/etc/dae/config.dae";
  };

  # ----------------------------------------------------
  systemd.services.dae = {
    wantedBy = lib.mkForce [];

    after = [
      "iwd.service"
      "network-online.target"
    ];

    wants = [
      "network-online.target"
    ];

    preStart = ''
      mkdir -p /run/credentials/dae.service
      ln -sf ${pkgs.v2ray-geoip}/share/v2ray/geoip.dat /run/credentials/dae.service/geoip.dat
      ln -sf ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat /run/credentials/dae.service/geosite.dat
    '';

    serviceConfig = {
      MemoryHigh = "70M";
      MemoryMax = "90M";
    };
  };

  # ----------------------------------------------------
  # 开机 9 秒延迟启动 Timer
  # ----------------------------------------------------
  systemd.timers.dae-delayed = {
    wantedBy = [
      "timers.target"
    ];

    timerConfig = {
      OnBootSec = "9s";
      Unit = "dae.service";
    };
  };
}
