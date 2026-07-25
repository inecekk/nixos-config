# modules/hardware.nix
# ==========================================
# 硬件驱动、文件系统挂载、图形、蓝牙与安全策略模块
# ==========================================

{ pkgs, ... }:

{
  # CPU 调频
  powerManagement.cpuFreqGovernor = "schedutil";

  # 支持文件系统
  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
  ];


  # 文件系统挂载
  fileSystems = {

    "/" = {
      device = "/dev/disk/by-uuid/2a2a478e-b03b-4e18-b1be-a37190168ca2";
      fsType = "btrfs";
      options = [
        "compress=zstd:5"
      ];
    };


    "/boot" = {
      device = "/dev/disk/by-uuid/7CB8-A11A";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };


    # Windows C盘
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
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
      ];
    };


    # Windows D盘
    "/home/lk/D" = {
      device = "/dev/disk/by-uuid/4A9ED0D09ED0B5A3";
      fsType = "ntfs3";

      options = [
        "rw"
        "uid=1000"
        "gid=1000"
        "umask=000"
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
      ];
    };
  };


  # 数位板驱动
  environment.systemPackages = [
    pkgs.opentabletdriver
  ];

  services.udev.packages = [
    pkgs.opentabletdriver
  ];


  # WiFi关闭省电
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan0", RUN+="${pkgs.iw}/bin/iw dev wlan0 set power_save off"
  '';


  # 图形与蓝牙
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


  # 程序支持
  programs = {
    dconf.enable = true;
    niri.enable = true;
  };
}
