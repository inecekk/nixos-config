{ pkgs, ... }:
{
  # ---------- 系统级包 ----------
  home.packages = with pkgs; [
    fastfetch
  ];

  #                              MPV 播放器
  # ==========================================================================
  programs.mpv = {
    enable = true;

    config = {
      audio = "auto";
      audio-display = "embedded-first";
      cover-art-auto = "fuzzy";
      hwdec = "auto-safe";
      loop-file = "inf";
      loop-playlist = "inf";
      vo = "gpu";
      keep-open = "yes";
      volume-max = "150";
      sub-auto = "fuzzy";
      sid = "1";
      slang = "zh,chi,cn,sc,en";
      demuxer-mkv-subtitle-preroll = "yes";
      autofit = "71%x71%";
      keepaspect = "yes";
      keepaspect-window = "yes";
      osc = "no";
      border = "no";
      osd-font = "sans-serif";
      sub-font = "sans-serif";
      sub-font-size = "36";
    };

    bindings = {
      "LEFT"  = "playlist-prev";
      "RIGHT" = "playlist-next";
      "Shift+LEFT"  = "seek -5";
      "Shift+RIGHT" = "seek 5";
      "UP"         = "add volume 5";
      "DOWN"       = "add volume -5";
      "Shift+UP"   = "add brightness 5";
      "Shift+DOWN" = "add brightness -5";
      "v"          = "cycle sub-visibility";
      "MBTN_RIGHT" = "script-binding uosc/menu";
      "WHEEL_UP"   = "add volume 5";
      "WHEEL_DOWN" = "add volume -5";
    };

    scripts = with pkgs.mpvScripts; [
      mpris
      uosc
    ];
  };

  xdg.configFile."mpv/script-opts/uosc.conf".text = ''
    languages=zh-hans,zh,en
    controls=space,menu,prev,play-pause,next,subtitles,audio,video,playlist,chapters,editions,speed,shuffle,fullscreen,space
    timeline_style=line
    timeline_line_width=1
    opacity=menu=0.8,submenu=0.8,title=0.8,border=0.8,timeline=0.6,controls=0.8
  '';

  # ==========================================================================
  #                              Fastfetch
  # ==========================================================================
  xdg.configFile."fastfetch/nixos-gradient.txt".text = ''
    $1  _    _  _  _    _    ___    ________
    $2☆| \  | ||_|| \  / |  / _ \  /  ______|✾
    $2☆|  \ | | _  \ \/ / ✹| | | |/  /_____  ✾
    $3❄|   \| || |  \  /   | | | ||_______ \ ✾
    $4☆| |\   || |  /  \   | | | |    \__ \ \✾
    $5☆| | \  || | / /\ \ ✹| |_| | _____/_/ /✾
    $6✦|_|  \_||_||_/  \_|  \___/ |________/ ❃
  '';
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "file";
        source = "~/.config/fastfetch/nixos-gradient.txt";
        color = { "1" = "38;5;99"; "2" = "38;5;98"; "3" = "38;5;97"; "4" = "38;5;68"; "5" = "38;5;45"; "6" = "38;5;43"; };
        padding = { top = 3; left = 2; right = 4; };
        position = "left";       # logo 放左侧
      };
      display = {
        separator = "  ";
        key.width = 4;
        bar = { border = { left = "["; right = "]"; }; };
        size = { maxPrefix = "GB"; ndigits = 2; };   # 内存/磁盘条紧凑
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
        { type = "memory"; key = "📊 "; keyColor = "yellow"; }
        { type = "disk"; key = "💾 "; keyColor = "blue"; folders = [ "/" ]; format = "{1} / {2} ({3})"; }
        { type = "disk"; key = "💾 "; keyColor = "blue"; folders = [ "/mnt/d" ]; format = "{1} / {2} ({3})"; }
        { type = "display"; key = "📺 "; keyColor = "magenta"; }
        { type = "localip"; key = "🌐 "; keyColor = "cyan"; showIpv4 = true; }
      ];
    };
  };

  # ==========================================================================
  #                              cava 音频频谱
  # ==========================================================================
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

  # ==========================================================================
  #                              环境变量
  # ==========================================================================
  home.sessionVariables = {
    GLOG_minloglevel = "3";
    GLOG_logtostderr = "0";
    GLOG_log_dir     = "/dev/null";
  };
}
