# modules/boot.nix
{
  config,
  pkgs,
  lib,
  ...
}:

let
  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  boot = {
    kernelPackages = pkgs.linuxPackages;
    supportedFilesystems = [ "ntfs" ];
    kernelModules = [ "tcp_bbr" ];
    kernel.sysctl."net.ipv4.ip_forward" = 1;

    extraModprobeConfig = ''
      options cfg80211_regdom=CN
      options mac80211 minstrel_vht_only=0
      options snd_hda_interpower_save=0 power_save_node=0
    '';

    kernelParams = lib.mkForce [
      "loglevel=4"
      "acpi_enforce_resources=lax"
      "systemd.default_timeout_stop_sec=9s"
      "amd_pmc.enable_stb=1"
      "amd_pmc.pref_ignore_msr=1"
      "button.lid_init_state=method"
      "amdgpu.runpm=0"
      "pcie_aspm=force"
      "acpi_osi=!acpi_osi=Linux"
      # [新增/优化] 适配 s2idle
      "nvme_core.default_ps_max_latency_us=0" # 禁止 NVMe 深度休眠，防止睡眠掉盘死机
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
}
