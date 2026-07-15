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

  { type = "os"; key = "󱄅"; keyColor = "magenta"; }
  { type = "kernel"; key = "󰒋"; keyColor = "blue"; }
  { type = "uptime"; key = "󰅐"; keyColor = "green"; }
  { type = "packages"; key = "󰏖"; keyColor = "yellow"; }

  { type = "wm"; key = "󰖯"; keyColor = "magenta"; }
  { type = "shell"; key = ""; keyColor = "cyan"; }
  { type = "terminal"; key = ""; keyColor = "blue"; }

  "break"

  { type = "cpu"; key = ""; keyColor = "green"; }
  { type = "gpu"; key = "󰢮"; keyColor = "cyan"; }
  { type = "memory"; key = ""; keyColor = "yellow"; }

  "break"

  { type = "disk"; key = "󰋊"; folders = [ "/" ]; keyColor = "blue"; }
  { type = "display"; key = "󰍹"; keyColor = "magenta"; }
  { type = "localip"; key = "󰩟"; keyColor = "cyan"; showIpv4 = true; }

  "break"

  { type = "colors"; symbol = "block"; }
]; 

    };
  };
}
