# modules/home/mpd-mako-mpv.nix
# 通知、音乐、播放器、终端显示工具
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

/*  # ---------- MPD 音乐服务 ----------
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

  # MPD：关机/重启在卸 D 盘前快速释放（关机时由 user manager 直接停 mpd）
  systemd.user.services.mpd = {
    Unit = {
      After = [ "home-lk-D.mount" ];
      Requires = [ "home-lk-D.mount" ];
      Before = [ "shutdown.target" "reboot.target" "umount.target" ];
    };
    Service = { KillMode = "mixed"; TimeoutStopSec = "1s"; };
  };

  # MPD 睡眠钩子：睡停并记 flag；唤醒仅当睡时在播才延迟 2s 拉起；关机不经过此钩子
  systemd.user.services.mpd-sleep-hook = {
    Unit = { Description = "Stop mpd on suspend; resume after wake only if it was running"; Before = [ "sleep.target" ]; StopWhenUnneeded = true; };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'if systemctl --user is-active --quiet mpd.service; then : > /run/user/1000/mpd-was-active; fi; systemctl --user stop mpd.service; true'";
      ExecStop  = "${pkgs.bash}/bin/bash -c 'if [ -f /run/user/1000/mpd-was-active ]; then rm -f /run/user/1000/mpd-was-active; sleep 2; systemctl --user start mpd.service; fi; true'";
    };
    Install.WantedBy = [ "sleep.target" ];
  };
*/
  # ---------- mpv 播放器 ----------
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
    scripts = [ pkgs.mpvScripts.mpris ]; # MPRIS 媒体控制支持 Noctalia
  };

  # ---------- fastfetch ----------
  xdg.configFile."fastfetch/nixos-gradient.txt".text = ''
    $1☆ _    _  _ __    __   ___     ________
    $2☆| \  | ||_|\ \  / /  / _ \  /  ______|✾
    $2☆|  \ | | _  \ \/ / ✹| | | |/  /_____  ✾
    $3❄|   \| || |  \  /   | | | ||_______ \ ✾
    $4☆| |\   || |  /  \   | | | |    \__ \ \✾
    $5☆| | \  || | / /\ \ ✹| |_| | _____/_/ /✾
    $6✦|_|  \_||_|/_/  \_\ \____/ |________/ ❃
  '';

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "file";
        source = "~/.config/fastfetch/nixos-gradient.txt";
        color = { "1" = "38;5;99"; "2" = "38;5;98"; "3" = "38;5;97"; "4" = "38;5;68"; "5" = "38;5;45"; "6" = "38;5;43"; };
        padding = { top = 3; right = 4; };
      };
      display = { separator = "  "; key.width = 4; };
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

  # ---------- cava 音频频谱 ----------
  programs.cava = {
    enable = true;
    settings = {
      color = {
        gradient = 1; gradient_count = 8;
        gradient_color_1 = "'#50fa7b'"; gradient_color_2 = "'#8be9fd'"; gradient_color_3 = "'#bd93f9'"; gradient_color_4 = "'#ff79c6'";
        gradient_color_5 = "'#ffb86c'"; gradient_color_6 = "'#ff5555'"; gradient_color_7 = "'#f1fa8c'"; gradient_color_8 = "'#ff79c6'";
      };
    };
  };
}
