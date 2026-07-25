# modules/hardware.nix
# ==========================================
# 硬件驱动、磁盘挂载、GPU、蓝牙、电源优化
# ==========================================

{ pkgs, ... }:

{
  # CPU动态调频，笔记本功耗和性能平衡
  powerManagement.cpuFreqGovernor = "schedutil";

  # 支持的文件系统
  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
  ];
# 文件系统挂载
  fileSystems = {

    # NixOS根分区
    "/" = {
      device = "/dev/disk/by-uuid/2a2a478e-b03b-4e18-b1be-a37190168ca2";
      fsType = "btrfs";
      options = [
        "compress=zstd:5" # Btrfs透明压缩，节省空间
      ];
    };

    # EFI启动分区
    "/boot" = {
      device = "/dev/disk/by-uuid/7CB8-A11A";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    # Windows C盘（去除 automount，改为常规挂载）
    "/home/lk/C" = {
      device = "/dev/disk/by-uuid/752A6785456870B8";
      fsType = "ntfs3";
      options = [
        "rw"
        "uid=1000"
        "gid=1000"
        "dmask=022"
        "fmask=022"
        "nofail"                      # 分区不存在也继续启动
        "x-systemd.device-timeout=1s" # 设备找不到时快速跳过
        "x-systemd.mount-timeout=1s"  # 挂载/卸载动作超时限制
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
        "nofail"                      # 分区不存在也继续启动
        "x-systemd.device-timeout=1s" # 设备找不到快速跳过
        "x-systemd.mount-timeout=1s"  # 挂载/卸载动作超时限制
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

  # WiFi关闭省电，减少延迟和断流
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan0", RUN+="${pkgs.iw}/bin/iw dev wlan0 set power_save off"
  '';

  # AMD显卡、蓝牙
  hardware = {

    # Mesa Vulkan/OpenGL图形支持
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # 蓝牙支持
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

  # 桌面程序支持
  programs = {
    dconf.enable = true;
    niri.enable = true;
  };
}
