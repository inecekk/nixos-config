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

  { type = "os"; key = "󱄅"; keyColor = "blue"; }
  { type = "kernel"; key = "󰒋"; keyColor = "cyan"; }
  { type = "host"; key = "󰇅"; keyColor = "magenta"; }
  { type = "uptime"; key = "󰅐"; keyColor = "green"; }
  { type = "packages"; key = "󰏖"; keyColor = "yellow"; }

  { type = "wm"; key = "󰖯"; keyColor = "magenta"; }
  { type = "de"; key = "󰧨"; keyColor = "blue"; }
  { type = "terminal"; key = ""; keyColor = "cyan"; }

  "break"

  { type = "cpu"; key = ""; keyColor = "red"; }
  { type = "gpu"; key = "󰢮"; keyColor = "green"; }
  { type = "memory"; key = ""; keyColor = "yellow"; }

  "break"

  { type = "display"; key = "󰍹"; keyColor = "blue"; }
  { type = "disk"; key = "󰋊"; keyColor = "magenta"; }
  { type = "localip"; key = "󰩟"; keyColor = "cyan"; showIpv4 = true; }

  "break"

  { type = "colors"; symbol = "block"; }
];
    };
  };
}
