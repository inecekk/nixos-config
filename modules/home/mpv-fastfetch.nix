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

  # 渐变字母 logo 的 ascii 文件，用 $1~$5 占位符标记每行颜色
  xdg.configFile."fastfetch/nixos-gradient.txt".text = ''
$1 _   _ _      ___  ____
$2| \ | (_)_  _/ _ \/ ___|
$3|  \| | \ \/ / | | \___ \
$4| |\  | |>  <| |_| |___) |
$5|_| \_|_/_/\_\\___/|____/
'';

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "file";
        source = "~/.config/fastfetch/nixos-gradient.txt";
        color = {
          "1" = "38;5;99";
          "2" = "38;5;98";
          "3" = "38;5;68";
          "4" = "38;5;44";
          "5" = "38;5;43";
        };
        padding = { top = 1; right = 4; };
      };
      display.separator = " ";
      modules = [
        { type = "os"; key = "󱄅"; keyColor = "magenta"; }
        { type = "kernel"; key = "󰒋"; keyColor = "blue"; }
        { type = "uptime"; key = "󰅐"; keyColor = "green"; }
        { type = "packages"; key = "󰏖"; keyColor = "yellow"; }
        { type = "wm"; key = "󰖯"; keyColor = "magenta"; }
        { type = "shell"; key = "";  keyColor = "cyan"; }
        { type = "terminal"; key = ""; keyColor = "blue"; }
        "break"
        { type = "cpu"; key = ""; keyColor = "green"; }
        { type = "gpu"; key = "󰢮"; keyColor = "cyan"; }
        { type = "memory"; key = ""; keyColor = "yellow"; }
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
