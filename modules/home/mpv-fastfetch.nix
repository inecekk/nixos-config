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

  # 6 行精密 ASCII Logo ($1~$6)
  xdg.configFile."fastfetch/nixos-gradient.txt".text = ''
$1 _   _  ___  _  _   ____   ____
$2| \ | ||_ || |/ /  / __ \ / ___|
$3|  \| | | || ' /  | |  | |\___ \
$4| . ` | | ||  <   | |  | | ___) |
$5| |\  |_| || . \  | |__| ||____/
$6|_| \_||___||_|\_\  \____/|_____/
'';

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "file";
        source = "~/.config/fastfetch/nixos-gradient.txt";
        # 6 级渐变色
        color = {
          "1" = "38;5;99";
          "2" = "38;5;98";
          "3" = "38;5;97";
          "4" = "38;5;68";
          "5" = "38;5;45";
          "6" = "38;5;43";
        };
        padding = {
          top = 3;       # 上下垂直居中
          right = 4;     # Logo 与右侧文字之间的间距
        };
      };
      display = {
        separator = "  "; # 增加分隔符空格数
        key = {
          width = 4;      # 宽容度更高，专门对齐 Emoji
        };
      };
      # 所有 Key 后面显式附带空格，彻底解决 Emoji 贴字问题
      modules = [
        {
          type = "os";
          key = "❄️ ";
          keyColor = "magenta";
        }
        {
          type = "kernel";
          key = "🐧 ";
          keyColor = "blue";
        }
        {
          type = "uptime";
          key = "⏱️ ";
          keyColor = "green";
        }
        {
          type = "packages";
          key = "📦 ";
          keyColor = "yellow";
        }
        {
          type = "wm";
          key = "🪟 ";
          keyColor = "magenta";
        }
        {
          type = "shell";
          key = "🐚 ";
          keyColor = "cyan";
        }
        {
          type = "terminal";
          key = "💻 ";
          keyColor = "blue";
        }
        "break"
        {
          type = "cpu";
          key = "⚡ ";
          keyColor = "green";
        }
        {
          type = "memory";
          key = "📊 ";
          keyColor = "yellow";
        }
        "break"
        {
          type = "disk";
          key = "💾 ";
          folders = [ "/" ];
          keyColor = "blue";
        }
        {
          type = "display";
          key = "📺 ";
          keyColor = "magenta";
        }
        {
          type = "localip";
          key = "🌐 ";
          keyColor = "cyan";
          showIpv4 = true;
        }
      ];
    };
  };
}
