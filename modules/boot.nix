{ config, pkgs, lib, ... }:

let
  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  # ==========================================
  # 1. 引导与内核配置
  # ==========================================
  boot = {
    kernelPackages = pkgs.linuxPackages;
    supportedFilesystems = [ "ntfs" ];
    kernelModules = [ "tcp_bbr" ];
    # 强制 S2idle 以避开 ACPI 深度睡眠 Bug，loglevel=3 减少日志噪音
    kernelParams = [
      "mem_sleep_default=s2idle"
      "loglevel=3"
      "acpi_enforce_resources=lax"
      "systemd.default_timeout_stop_sec=9s"
      "amd_pmc.enable_stb=0"
      "amdgpu.runpm=0"
      "nvme_core.default_ps_max_latency_us=0"
    ];

    loader = {
      timeout = 3;
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
        useOSProber = true;
        theme = "${scripts.wutheringGrubTheme}/grub/themes/changli";
        extraConfig = ''
          set gfxmode=1920x1080
          set gfxpayload=keep
        '';
      };
    };
  };

  # ==========================================
  # 2. 睡眠前置清理任务 (防报错处理)
  # ==========================================
  systemd.services.pre-suspend-tasks = {
    description = "睡眠前清理任务";
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c "
          systemctl stop mpd --no-block 2>/dev/null || true
          ${pkgs.wireplumber}/bin/wpctl suspend @DEFAULT_AUDIO_SINK@ 2>/dev/null || true
          ${pkgs.alsa-utils}/bin/amixer -c 0 set Master mute 2>/dev/null || true
        "
      '';
    };
  };

  # ==========================================
  # 3. 电源管理执行逻辑
  # ==========================================
  powerManagement = {
    powerDownCommands = ''
      ${pkgs.bluez}/bin/bluetoothctl power off 2>/dev/null || true
      ${pkgs.networkmanager}/bin/nmcli radio wifi off 2>/dev/null || true
      /run/current-system/sw/bin/pkill -9 -u lk -x 'qq|chrome|zen|vscode' 2>/dev/null || true
    '';

    resumeCommands = ''
      sleep 2
      # 仅在服务存在时尝试启动，使用 --no-block 避免挂起
      if systemctl list-unit-files mpd.service | grep -q 'mpd.service'; then
        systemctl start mpd --no-block
      fi
      ${pkgs.bluez}/bin/bluetoothctl power on 2>/dev/null || true
      ${pkgs.networkmanager}/bin/nmcli radio wifi on 2>/dev/null || true
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Master unmute 2>/dev/null || true
    '';
  };
}
