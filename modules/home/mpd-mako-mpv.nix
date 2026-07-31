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

  # ==========================================================================
  #                              MPV 播放器配置
  # ==========================================================================
  programs.mpv = {
    enable = true;

    # 1. 核心与渲染参数
    config = {
      # 硬解与渲染引擎
      hwdec = "auto-safe";
      vo = "gpu-next";             # uosc 启用高斯模糊效果所必需的高级渲染器
      keep-open = "yes";
      volume-max = "150";
      sub-auto = "fuzzy";          # 自动匹配加载同名的外挂 .lrc 歌词文件

      # --- 歌词 / 字幕控制（默认自动显示内嵌/外挂歌词）---
      sid = "1";                   # 核心：默认开启第 1 个字幕/歌词轨道
      slang = "zh,chi,cn,sc,en";  # 优先加载中文歌词/字幕
      demuxer-mkv-subtitle-preroll = "yes";

      # --- 窗口与封面比例优化 ---
      autofit = "71%x71%";         # 窗口永远以 1/2 屏幕大小（长宽各 71%）启动
      keepaspect = "yes";          # 保持视频/封面的原始高宽比，绝对不拉伸变形
      keepaspect-window = "yes";   # 允许窗口自由缩放，但内部画面始终保持原比例居中显示

      # uosc 界面兼容设置
      osc = "no";
      border = "no";
      osd-font = "sans-serif";
      sub-font = "sans-serif";
      sub-font-size = "36";
    };

    # 2. 快捷键与交互控制
    bindings = {
      # --- 左右方向键：切歌/切集 ---
      "LEFT"  = "playlist-prev";
      "RIGHT" = "playlist-next";

      # --- Shift + 左右方向键：快进/快退 ---
      "Shift+LEFT"  = "seek -5";
      "Shift+RIGHT" = "seek 5";

      # --- 键盘调节：音量与亮度 ---
      "UP"         = "add volume 5";
      "DOWN"       = "add volume -5";
      "Shift+UP"   = "add brightness 5";
      "Shift+DOWN" = "add brightness -5";

      # --- 歌词显示与菜单快捷键 ---
      "v"          = "cycle sub-visibility";
      "MBTN_RIGHT" = "script-binding uosc/menu";

      # --- 鼠标手势 ---
      "WHEEL_UP"   = "add volume 5";
      "WHEEL_DOWN" = "add volume -5";
    };

    # 3. 扩展插件
    scripts = with pkgs.mpvScripts; [
      mpris
      uosc
    ];
  };

  # ==========================================================================
  #                              UOSC 界面配置
  # ==========================================================================
  xdg.configFile."mpv/script-opts/uosc.conf".text = ''
    # 语言设置
    languages=zh-hans,zh,en

    # 底部控制栏布局：按钮居中显示
    controls=space,menu,prev,play-pause,next,subtitles,audio,video,playlist,chapters,editions,speed,shuffle,fullscreen,space

    # --- 进度条细节调整 ---
    timeline_style=line          # 将粗线条进度栏改为极细单线模式
    timeline_line_width=2        # 默认细线宽度为 2 像素
    timeline_line_width_minimized=0 # 平时隐藏或仅显示极细像素，鼠标靠近时展开
    timeline_size_min=2          # 未聚焦时进度条厚度
    timeline_size_max=12         # 悬浮时进度条展开最大厚度

    # --- 高斯模糊与透明度风格 ---
    blur=yes                     # 开启菜单、播放列表及控制背景的高斯模糊效果
    opacity=menu=0.8,submenu=0.8,title=0.8,border=0.8,timeline=0.6,controls=0.8

    # 点击阈值与交互
    click_threshold=200
  '';

  # ---------- fastfetch ----------
  xdg.configFile."fastfetch/nixos-gradient.txt".text = ''
    $1☆ _    _  _ __    __    ___     ________
    $2☆| \  | ||_|\ \  / /  / _ \  /  ______|✾
    $2☆|  \ | | _  \ \/ / ✹| | | |/  /_____  ✾
    $3❄|   \| || |  \  /   | | | ||_______ \ ✾
    $4☆| |\   || |  /  \   | | | |    \__ \ \✾
    $5☆| | \  || | / /\ \ ✹| |_| | _____/_/ /✾
    $6✦|_|  \_||_|\_/  \_\ \____/ |________/ ❃
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
