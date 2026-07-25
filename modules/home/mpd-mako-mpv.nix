# modules/home/mpd-mako-mpv.nix
# ==========================================
# 通知、音乐、播放器、终端显示工具
# ==========================================

{ pkgs, ... }:

{
  # ---------- mako 通知 ----------
  services.mako = {
    settings = {
      default-timeout = 1500;
      border-radius = 8;
      border-color = "#7fc8ff";
      border-size = 2;
      padding = "10";
      margin = "10";
      height = 100;
      width = 300;
      text-color = "#ffffff";
      background-color = "#1a1a1a";
      font = "Sans 12";
    };

    extraConfig = ''
      [app-name="Bluetooth"]
      urgency=low
      default-timeout=1500

      [summary~="[Bb]luetooth"]
      urgency=low
      default-timeout=1500

      [summary~="[Cc]onnected"]
      urgency=low
      default-timeout=1500
    '';
  };

  # ---------- MPD音乐服务 ----------
  services.mpd = {
    enable = true;

    musicDirectory = "/home/lk/D/Music";

    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }

      auto_update "yes"
      restore_paused "yes"
    '';
  };

  # MPD关机/重启快速释放D盘
  systemd.user.services.mpd = {
    Unit = {
      After = [
        "home-lk-D.mount"
      ];

      Requires = [
        "home-lk-D.mount"
      ];

      Before = [
        "shutdown.target"
        "reboot.target"
        "umount.target"
      ];
    };

    Service = {
      KillMode = "mixed";
      TimeoutStopSec = "1s";
    };
  };
  # ---------- mpv播放器 ----------
  programs.mpv = {
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

    # MPRIS媒体控制支持Noctalia
    scripts = [
      pkgs.mpvScripts.mpris
    ];
  };

  # ---------- fastfetch ----------
  xdg.configFile."fastfetch/nixos-gradient.txt".text = ''
    $1☆ _   _  _  __  __    ___    ________
    $2☆| \ | || | \ \/ / ✹ /  _  \/  ______|✾
    $3❄|  \| || |  \  /    | | | || \______ ✾
    $4☆| . ` || |  /  \    | | | |\______  |✾
    $5☆| |\  || | / /\ \ ✹ | |_| | _____/  /✾
    $6✦|_| \_||_|/_/  \_\  \___ / |______ / ❃
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
          "3" = "38;5;97";
          "4" = "38;5;68";
          "5" = "38;5;45";
          "6" = "38;5;43";
        };

        padding = {
          top = 3;
          right = 4;
        };
      };

      display = {
        separator = "  ";
        key.width = 4;
      };

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
          folders = ["/"];
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

  # ---------- cava音频频谱 ----------
  programs.cava = {
    enable = true;

    settings = {
      color = {
        gradient = 1;
        gradient_count = 8;

        gradient_color_1 = "'#50fa7b'";
        gradient_color_2 = "'#8be9fd'";
        gradient_color_3 = "'#bd93f9'";
        gradient_color_4 = "'#ff79c6'";
        gradient_color_5 = "'#ffb86c'";
        gradient_color_6 = "'#ff5555'";
        gradient_color_7 = "'#f1fa8c'";
        gradient_color_8 = "'#ff79c6'";
      };
    };
  };
}
