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

      display.separator = " ";

      modules = [
        "title"
        "separator"

        { type = "os"; key = "󱄅"; }
        { type = "kernel"; key = "󰒋"; }
        { type = "host"; key = "󰇅"; }
        { type = "uptime"; key = "󰅐"; }
        { type = "packages"; key = "󰏖"; }

        { type = "wm"; key = "󰖯"; }
        { type = "de"; key = "󰧨"; }
        { type = "terminal"; key = ""; }

        "break"

        { type = "cpu"; key = ""; }
        { type = "gpu"; key = "󰢮"; }
        { type = "memory"; key = ""; format = "{percentage} ({used}/{total})"; }

        "break"

        { type = "display"; key = "󰍹"; }
        { type = "disk"; key = "󰋊"; }
        { type = "localip"; key = "󰩟"; showIpv4 = true; }

        "break"

        { type = "colors"; symbol = "block"; }
      ];
    };
  };
}
