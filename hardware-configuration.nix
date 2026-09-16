{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/新UUID";
      fsType = "xfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/5DCD-3651";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    # Windows C 盘
    "/home/lk/win11/c" = {
      device = "/dev/disk/by-uuid/C2C8E6BFC8E6B0B9";
      fsType = "ntfs3";
      options = [ "defaults" "noatime" "rw" "uid=1000" "gid=100" ];
    };

    # Windows D 盘
    "/home/lk/win11/D" = {
      device = "/dev/disk/by-uuid/45B78617C66EE19E";
      fsType = "ntfs3";
      options = [ "defaults" "noatime" "rw" "uid=1000" "gid=100" ];
    };
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
