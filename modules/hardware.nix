# modules/hardware.nix
# ==========================================
# 硬件驱动、GPU、蓝牙、电源优化
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
