# modules/hardware.nix
# ==========================================
# 硬件驱动、文件系统挂载、图形、蓝牙与安全策略模块
# ==========================================
{ pkgs, ... }:

{
  # --- 1. 文件系统挂载 (原 filesystems.nix) ---
  boot.supportedFilesystems = [ "ntfs" "btrfs" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2a2a478e-b03b-4e18-b1be-a37190168ca2";
      fsType = "btrfs";
      options = [ "compress=zstd:5" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/7CB8-A11A";
      fsType = "vfat";
    };

    "/home/lk/C" = {
      device = "/dev/disk/by-uuid/752A6785456870B8";
      fsType = "ntfs3";
      options = [
        "rw"
        "uid=1000"
        "gid=1000"
        "dmask=022"
        "fmask=022"
        "nofail"
        "x-systemd.device-timeout=3"
      ];
    };

    "/home/lk/D" = {
      device = "/dev/disk/by-uuid/4A9ED0D09ED0B5A3";
      fsType = "ntfs3";
      options = [
        "rw"
        "uid=1000"
        "gid=1000"
        "dmask=0000"
        "fmask=0000"
        "force"
        "nofail"
        "x-systemd.device-timeout=3"
      ];
    };
  };

  # --- 2. 数位板驱动与规则 ---
  environment.systemPackages = [ pkgs.opentabletdriver ];
  services.udev.packages = [ pkgs.opentabletdriver ];


  # --- 3. 硬件基础设置 (图形与蓝牙) ---
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        ControllerMode = "dual";
        FastConnectable = true;
        AutoEnable = true;
        JustWorksRepairing = "always";
      };
    };
  };

  # --- 4. 辅助程序配置 ---
  programs = {
    dconf.enable = true;
    niri.enable = true;
  };
/*
  # --- 5. 密钥管理服务 ---
  services.gnome.gnome-keyring.enable = true;
  # --- 6. 安全与认证策略 (Polkit & PAM) ---
  security = {
    polkit.enable = true;

    pam.services.greetd.text = ''
      auth requisite pam_nologin.so
      auth include login
      auth optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
      account include login
      password include login
      password optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so use_authtok
      session include login
      session optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
    '';
  };
*/
}
