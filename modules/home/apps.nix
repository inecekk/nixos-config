{ pkgs, ... }:
{
  # ---------- 系统级包 ----------
  home.packages = with pkgs; [
    fastfetch
  ];

  # ==========================================================================
  #                              foot 终端
  # ==========================================================================
  xdg.configFile."foot/foot.ini".text = ''
    [main]
    font=JetBrains Mono:size=10, WenQuanYi Micro Hei:size=10
    dpi-aware=yes
    pad=3x1 center
    selection-target=clipboard
    resize-delay-ms=10
    bold-text-in-bright=yes
    [scrollback]
    lines=10000
    [csd]
    preferred=none
    [colors-dark]
    alpha=0.7
    blur=yes
    foreground=e0e0e0
    background=000000
    cursor=000000 e0e0e0
    selection-background=000000
    selection-foreground=ffffff
    regular0=2e3436
    regular1=cc0000
    regular2=4e9a06
    regular3=c4a000
    regular4=3465a4
    regular5=75507b
    regular6=06989a
    regular7=d3d7cf
    bright0=555753
    bright1=ef2929
    bright2=8ae234
    bright3=fce94f
    bright4=729fcf
    bright5=ad7fa8
    bright6=34e2e2
    bright7=eeeeec
    [bell]
    notify=no
    visual=no
    [cursor]
    style=block
    blink=no
    [mouse]
    hide-when-typing=yes
    [key-bindings]
    clipboard-paste=Control+v Control+Shift+v
    primary-paste=Shift+Insert
  '';

  # ==========================================================================
  #                              mako 通知
  # ==========================================================================
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

  # ==========================================================================
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
