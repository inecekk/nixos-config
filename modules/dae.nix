# /etc/nixos/modules/dae.nix
{ pkgs, inputs, lib, ... }:
{
  imports = [ inputs.daeuniverse.nixosModules.dae ];
  services.dae = {
    enable = true;
    openFirewall = {
      enable = true;
      port = 12345;
    };
    configFile = "/etc/dae/config.dae";
    assets = with pkgs; [ v2ray-geoip v2ray-domain-list-community ];
  };
  # 禁用服务自动随开机启动，改为由 Timer 触发
  systemd.services.dae.wantedBy = lib.mkForce [];
  # 创建一个定时器，在开机/登录后 15 秒触发启动
  systemd.timers.dae-delayed = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15s";
      Unit = "dae.service";
    };
  };
}
