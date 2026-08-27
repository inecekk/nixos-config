{ pkgs, lib, ... }:
{
  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;
  programs.fuse.userAllowOther = true;

  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    kernelParams = [ "reboot=pci" "loglevel=3" "acpi_dump_path=" "rd.udev.log_level=3" ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    fcitx5-gtk = pkgs.emptyDirectory;
    xdg-desktop-portal-gnome = pkgs.emptyDirectory;
  };

  documentation = { enable = false; nixos.enable = false; info.enable = false; doc.enable = false; man.enable = false; };

  hardware.graphics = {
    enable = true;
    enable32Bit = lib.mkForce false;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  time = {
    timeZone = "Asia/Shanghai";
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "zh_CN.UTF-8/UTF-8" ];
    extraLocaleSettings = lib.genAttrs [
      "LC_ADDRESS" "LC_IDENTIFICATION" "LC_MEASUREMENT" "LC_MONETARY"
      "LC_NAME" "LC_NUMERIC" "LC_PAPER" "LC_TELEPHONE" "LC_TIME"
    ] (_: "zh_CN.UTF-8");
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
    wireless.iwd = {
      enable = true;
      settings = {
        General.EnableNetworkConfiguration = false;
        Network.EnableIPv6 = true;
        Scan = { DisablePeriodicScan = true; RoamThreshold = -88; RoamThreshold5G = -88; };
      };
    };
    nameservers = [ "223.5.5.5" "119.29.29.29" ];
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks."10-wlan" = {
      matchConfig.Name = "wlan*";
      networkConfig = { DHCP = "yes"; IgnoreCarrierLoss = "3s"; };
    };
  };

  services.resolved.enable = true;
  services.printing.enable = false;
  hardware.sane.enable = false;
  systemd.oomd.enable = false;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
  };

  environment.extraInit = ''
    dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP
  '';

  systemd.settings.Manager.LogLevel = "err";
  systemd.user.settings.Manager.LogLevel = "err";
  systemd.coredump.settings.Coredump.MaxUse = "100M";

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    SystemKeepFree=1G
    MaxRetentionSec=1week
    RateLimitIntervalSec=30s
    RateLimitBurst=1000
  '';

  systemd.tmpfiles.rules = [
    "e ~lk/.cache - - - 7d"
    "e ~lk/.config/materialgram/Cache - - - 7d"
    "e ~lk/.config/google-chrome/Default/Cache - - - 7d"
    "e ~lk/.config/Code/Cache - - - 7d"
    "e ~lk/.config/QQ/*/Cache - - - 7d"
  ];

  security.sudo.extraRules = [{
    users = [ "lk" ];
    commands = map (cmd: { command = "/run/current-system/sw/bin/${cmd}"; options = [ "NOPASSWD" ]; }) [ "mount" "umount" ];
  }];

  services.vnstat.enable = true;
  environment.systemPackages = [ pkgs.vnstat ];
}