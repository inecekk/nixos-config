# /etc/nixos/modules/dae.nix
{
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.daeuniverse.nixosModules.dae
  ];

  services.dae = {
    enable = true;

    package = pkgs.callPackage ../pkgs/dae-v2.nix { };

    openFirewall = {
      enable = true;
      port = 12345;
    };

    configFile = "/etc/dae/config.dae";

    assets = with pkgs; [
      v2ray-geoip
      v2ray-domain-list-community
    ];
  };

  # 禁止 dae 随 multi-user.target 立即启动
  systemd.services.dae = {
    wantedBy = lib.mkForce [ ];

    after = [
      "NetworkManager.service"
      "network-online.target"
    ];

    wants = [
      "network-online.target"
    ];
  };

  # 开机延迟启动 dae
  systemd.timers.dae-delayed = {

    wantedBy = [
      "timers.target"
    ];

    timerConfig = {

      # 开机 9 秒后启动
      OnBootSec = "9s";

      # 如果失败自动再次尝试
      Unit = "dae.service";
    };
  };
}
