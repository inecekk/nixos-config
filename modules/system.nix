{ pkgs, lib, ... }:
{
  imports = [
    ./iwd.nix
  ];

  system.stateVersion = "25.11";

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      xdg-desktop-portal-gnome = pkgs.emptyDirectory;
    };
  };

  programs.fuse.userAllowOther = true;

  environment = {
    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
    extraInit = ''
      dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP
    '';
    systemPackages = with pkgs; [
      vnstat
      brightnessctl
      vim
    ];
  };

  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    kernelParams = [
      "reboot=pci"
      "acpi_dump_path="
    ];
    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
    };
  };

  documentation = {
    enable = false;
    nixos.enable = false;
    info.enable = false;
    doc.enable = false;
    man.enable = false;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = lib.mkForce false;
    };
    sane.enable = false;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [
      "gtk"
    ];
  };

  time = {
    timeZone = "Asia/Shanghai";
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
    extraLocaleSettings = lib.genAttrs [
      "LC_ADDRESS"
      "LC_IDENTIFICATION"
      "LC_MEASUREMENT"
      "LC_MONETARY"
      "LC_NAME"
      "LC_NUMERIC"
      "LC_PAPER"
      "LC_TELEPHONE"
      "LC_TIME"
    ] (_: "zh_CN.UTF-8");
  };

  services = {
    resolved.enable = true;
    printing.enable = false;
    speechd.enable = lib.mkForce false;
    gvfs.enable = true;
    vnstat.enable = true;

    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandlePowerKey = "ignore";
    };

    journald.settings.Journal = {
      SystemMaxUse = "200M";
      SystemKeepFree = "1G";
      MaxRetentionSec = "1week";
      RateLimitBurst = "1000";
    };
  };

  systemd = {
    oomd.enable = false;

    settings.Manager.LogLevel = "err";
    user.settings.Manager.LogLevel = "err";

    coredump.settings.Coredump.MaxUse = "100M";

    tmpfiles.rules = [
      "e ~lk/.cache - - - 7d"
      "e ~lk/.config/materialgram/Cache - - - 7d"
      "e ~lk/.config/google-chrome/Default/Cache - - - 7d"
      "e ~lk/.config/Code/Cache - - - 7d"
      "e ~lk/.config/QQ/*/Cache - - - 7d"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "lk" ];
      commands = map (cmd: {
        command = "/run/current-system/sw/bin/${cmd}";
        options = [ "NOPASSWD" ];
      }) [
        "mount"
        "umount"
      ];
    }
  ];

  fonts.packages = lib.mkForce (with pkgs; [
    wqy_microhei
    noto-fonts-color-emoji
  ]);
}
