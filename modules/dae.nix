# /etc/nixos/modules/dae.nix
{
  pkgs,
  lib,
  ...
}: {
  # ----------------------------------------------------
  services.dae = {
    enable = true;

    # 原生使用 pkgs.dae
    package = pkgs.dae;
    # package = pkgs.callPackage ../pkgs/dae-v2.nix {}; # 注释掉自定义 dae-v2

    openFirewall = {
      enable = true;
      port = 12345;
    };

    configFile = "/etc/dae/config.dae";

    assetsPath = "${pkgs.v2ray-geoip}/share/v2ray:${pkgs.v2ray-domain-list-community}/share/v2ray";
  };

  # ----------------------------------------------------
  # Systemd 服务重写（延迟启动与 cgroup 内存限制）
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

    # 内存上限控制
    serviceConfig = {
      MemoryMax = "70M";       # 内存上限,超出直接被 cgroup 干掉
      MemoryHigh = "90M";      # 软上限,超过后内核会尝试回收
    };
  };

  # ----------------------------------------------------
  # 4. 开机 9 秒延迟启动 Timer
  # ----------------------------------------------------
  systemd.timers.dae-delayed = {
    wantedBy = [
      "timers.target"
    ];

    timerConfig = {
      OnBootSec = "9s";        # 开机 9 秒后启动
      Unit = "dae.service";
    };
  };
}
