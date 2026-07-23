# modules/home/media-notify.nix
# ==========================================
# 通知与媒体：mako + mpd/rmpc + mpv + fastfetch
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
      [app-name="Bluetooth"] urgency=low default-timeout=1500
      [summary~="[Bb]luetooth"] urgency=low default-timeout=1500
      [summary~="[Cc]onnected"] urgency=low default-timeout=1500
    '';
  };

  # ---------- MPD + rmpc ----------
  services.mpd = {
    enable = true;
    musicDirectory = "/home/lk/D/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }
    '';
  };
  programs.rmpc = {
    enable = true;
    config = ''( address: "127.0.0.1:6600", )'';
  };

  # ---------- mpv ----------
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

  # ---------- fastfetch ----------

# ---------- fastfetch ----------
xdg.configFile."fastfetch/nixos-gradient.txt".text = ''
  $1❄☆ _   __  ✷✿✸   _ ☾❀   __  __ ✺✹   ___ ✵✼✳   ____     ✽
  $2✦☆ | \ | | ✷✿✸ | | ✧☾❀ \ \/ / ✶✺✹ / _ \ ✵✼✳ / ___|   ❃✽✾
  $3❄☆ |  \| | ✷✿✸ | | ✧☾❀  \  / ✶✺✹ | | | | ✵✼✳ \___ \  ❃✽✾
  $4✦☆ | . ` | ✷✿✸ | | ✧☾❀  /  \ ✶✺✹ | | | | ✵✼✳  ___) | ❃✽✾
  $5❄☆ | |\  | ✷✿✸ | | ✧☾❀ / /\ \ ✶✺✹ | |_| | ✵✼✳ |____/ ❃✽✾
  $6❄✦☆|_| \_| ✷✿✸ |_| ✧☾❀ /_/  \_\ ✶✺✹  \___/ ✵✼✳ |_____/ ❃
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
        { type = "os"; key = "❄️ "; keyColor = "magenta"; }
        { type = "kernel"; key = "🐧 "; keyColor = "blue"; }
        { type = "uptime"; key = "⏱️ "; keyColor = "green"; }
        { type = "packages"; key = "📦 "; keyColor = "yellow"; }
        { type = "wm"; key = "🪟 "; keyColor = "magenta"; }
        { type = "shell"; key = "🐚 "; keyColor = "cyan"; }
        { type = "terminal"; key = "💻 "; keyColor = "blue"; }
        "break"
        { type = "cpu"; key = "⚡ "; keyColor = "green"; }
        { type = "memory"; key = "📊 "; keyColor = "yellow"; }
        "break"
        { type = "disk"; key = "💾 "; folders = [ "/" ]; keyColor = "blue"; }
        { type = "display"; key = "📺 "; keyColor = "magenta"; }
        { type = "localip"; key = "🌐 "; keyColor = "cyan"; showIpv4 = true; }
      ];
    };
  };
}
