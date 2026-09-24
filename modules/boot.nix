{ config, pkgs, lib, ... }:

let
  scripts = import ./scripts.nix { inherit pkgs; };
in {
  boot = {
    kernelPackages = pkgs.linuxPackages;
    supportedFilesystems = [ "ntfs" ];
    kernelModules = [ "tcp_bbr" "rtw89_8852be" ];
    blacklistedKernelModules = [ "sp5100_tco" ];

    extraModprobeConfig = ''
      options rtw89_core disable_ps_mode=y
      options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y
    '';

    kernelParams = [
      "mem_sleep_default=deep"
      "acpi_backlight=native"
      "amd_pstate=active"
      "amd_pmc.enable_stb=0"
      "amd_iommu=on"
      "acpi.ec_ignore_errors=1"
      "acpi_osi=!"
      "acpi_osi=\"Linux\""
      "i8042.noaux"
      "pci=pcie_scan_all,noaer"
      "usbcore.old_scheme=1"
      "usbcore.initial_descriptor_timeout=15"
      "usbcore.quirks=0000:0000:k"
      "usbcore.autosuspend=-1"
      "xchi_hcd.quirks=270336"
      "iommu=pt"
      "pcie_aspm.policy=performance"
      "nvme_core.default_ps_max_latency_us=0"
      "nowatchdog"
      "nmi_watchdog=0"
      "acpi_enforce_resources=lax"
      "quiet"
      "loglevel=0"
      "mitigations=auto"
      "systemd.default_timeout_stop_sec=9s"
    ];

    consoleLogLevel = 0;

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
          set quiet_boot=1
        '';
      };
    };
  };

  networking.networkmanager.wifi.powersave = false;
  services.power-profiles-daemon.enable = true;

  systemd.services.pre-suspend-tasks = {
    description = "睡眠前清理任务";
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    script = ''
      ${pkgs.wireplumber}/bin/wpctl suspend-node @DEFAULT_AUDIO_SINK@ 2>/dev/null || true
      ${pkgs.alsa-utils}/bin/amixer -c 0 sset Master mute 2>/dev/null || true
    '';
    serviceConfig.Type = "oneshot";
  };

  powerManagement = {
    powerDownCommands = ''
      ${pkgs.util-linux}/bin/timeout 3s ${pkgs.bluez}/bin/bluetoothctl power off 2>/dev/null || true
      ${pkgs.networkmanager}/bin/nmcli radio wifi off 2>/dev/null || true
      /run/current-system/sw/bin/pkill -9 -u lk -x 'qq|chrome|zen|vscode' 2>/dev/null || true
    '';

    resumeCommands = ''
      sleep 2
      ${pkgs.util-linux}/bin/timeout 3s ${pkgs.bluez}/bin/bluetoothctl power on 2>/dev/null || true
      ${pkgs.networkmanager}/bin/nmcli radio wifi on 2>/dev/null || true
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Master unmute 2>/dev/null || true
    '';
  };
}

