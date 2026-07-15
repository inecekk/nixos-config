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

  # NixOS 渐变字母 logo，$1~$6 对应下面 logo.color 里的六级颜色，
  # 每一行用一个占位符，从紫色过渡到青色
  xdg.configFile."fastfetch/nixos-gradient.txt".text = ''
$1 _   _ _       ____   _____ 
$2| \ | (_)     / __ \ / ____|
$3|  \| |___  _| |  | | (___  
$4| . ` | \ \/ / |  | |\___ \ 
$5| |\  | |>  <| |__| |____) |
$6|_| \_|_/_/\_\\____/|_____/ 
'';

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "file";
        source = "~/.config/fastfetch/nixos-gradient.txt";
        # 对应 ascii 文件里的 $1~$6，每行一个颜色，做出渐变效果
        color = {
          "1" = "38;5;99";
          "2" = "38;5;93";
          "3" = "38;5;92";
          "4" = "38;5;68";
          "5" = "38;5;44";
          "6" = "38;5;43";
        };
        padding = {
          # top 数值越大，logo 整体往下移动得越多（当前下移 3 行）
          top = 5;
          # logo 和右侧信息栏之间的间距
          right = 5;
        };
      };
      display = {
        # 图标和文字之间的间隔符
        separator = " ";
        # 让所有模块的值从同一列开始，不受图标宽度不一致的影响
        key = { width = 3; };
      };
      modules = [
        { type = "os"; key = "󱄅 "; keyColor = "magenta"; }
        { type = "kernel"; key = "󰒋 "; keyColor = "blue"; }
        { type = "uptime"; key = "󰅐 "; keyColor = "green"; }
        { type = "packages"; key = "󰏖 "; keyColor = "yellow"; }
        { type = "wm"; key = "󰖯 "; keyColor = "magenta"; }
        { type = "shell"; key = "$ "; keyColor = "cyan"; }
        { type = "terminal"; key = ">_ "; keyColor = "blue"; }
        "break"
        { type = "cpu"; key = "󰻠 "; keyColor = "green"; }
        { type = "gpu"; key = "󰢮 "; keyColor = "cyan"; }
        { type = "memory"; key = "󰍛 "; keyColor = "yellow"; }
        "break"
        { type = "disk"; key = "󰋊 "; folders = [ "/" ]; keyColor = "blue"; }
        { type = "display"; key = "󰍹 "; keyColor = "magenta"; }
        { type = "localip"; key = "󰩟 "; keyColor = "cyan"; showIpv4 = true; }
      ];
    };
  };
}
