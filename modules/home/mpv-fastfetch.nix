# modules/home/mpv-fastfetch.nix
{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "gpu-next";
      keep-open = "yes";
      volume-max = "150";
      sub-auto = "fuzzy";
    };
    bindings = {
      "WHEEL_UP" = "add volume 5";
      "WHEEL_DOWN" = "add volume -5";
    };
    scripts = [ pkgs.mpvScripts.mpris ];
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "auto";
        padding = { top = 1; right = 4; };
      };
      display.separator = " 󰁔 ";
      modules = [
        "title"
        "separator"
        { type = "os"; key = "󱄅 OS"; }
        { type = "kernel"; key = "󰒋 Kernel"; }
        { type = "host"; key = "󰇅 Host"; }
        { type = "uptime"; key = "󰅐 Uptime"; }
        { type = "packages"; key = "󰏖 Packages"; }
        { type = "wm"; key = "󰖯 WM"; }
        { type = "de"; key = "󰧨 DE"; }
        { type = "terminal"; key = " Terminal"; }
        "break"
        { type = "cpu"; key = " CPU"; }
        { type = "gpu"; key = "󰢮 GPU"; }
        { type = "memory"; key = " Memory"; format = "{percentage} ({used}/{total})"; }
        "break"
        { type = "display"; key = "󰍹 Display"; }
        { type = "disk"; key = "󰋊 Disk"; }
        { type = "localip"; key = "󰩟 IP"; showIpv4 = true; }
        "break"
        { type = "colors"; symbol = "block"; }
      ];
    };
  };
}
