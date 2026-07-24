{ pkgs, ... }:

let

  # ==========================================
  # 🎵 ytmusic
  # 终端版 YouTube 音乐播放器
  #
  # 核心:
  # yt-dlp 负责搜索和解析
  # fzf 负责终端交互选择
  # mpv 负责播放音频
  #
  # 类似网易云终端版体验
  # ==========================================

  ytmusic = pkgs.writeShellScriptBin "ytmusic" ''

    # ------------------------------------------
    # Zen 浏览器 Cookie
    #
    # 用于解决 YouTube:
    # Sign in to confirm you are not a bot
    #
    # Zen 实际兼容 Firefox Cookie 格式
    # ------------------------------------------

    COOKIE="firefox:/home/lk/.config/zen/tso70vj4.Default Profile"


    # ------------------------------------------
    # 获取输入参数
    #
    # 示例:
    # ytmusic Gem
    #
    # 无参数:
    # ytmusic
    # 自动打开音乐排行榜
    # ------------------------------------------

    query="$*"


    # 没有输入时使用默认搜索
    if [ -z "$query" ]; then
      query="YouTube Music Trending Songs"
    fi


    # ------------------------------------------
    # yt-dlp 搜索 YouTube
    #
    # ytsearch8:
    # 只获取8个结果，提高速度
    #
    # flat-playlist:
    # 不下载，只获取信息
    #
    # cache:
    # 保存缓存，提高重复搜索速度
    # ------------------------------------------

    ${pkgs.yt-dlp}/bin/yt-dlp \
      --cookies-from-browser "$COOKIE" \
      --flat-playlist \
      --ignore-errors \
      --cache-dir "/home/lk/.cache/yt-dlp" \
      --extractor-args youtube:player_client=tv \
      --print "🎶 %(title)s|%(url)s" \
      "ytsearch8:$query" |


    # ------------------------------------------
    # fzf 终端音乐选择界面
    #
    # 快捷键:
    #
    # /
    # 搜索
    #
    # ?
    # 查看帮助
    #
    # Enter
    # 播放
    #
    # ESC
    # 退出
    # ------------------------------------------

    ${pkgs.fzf}/bin/fzf \
      --height=70% \
      --layout=reverse \
      --border=rounded \
      --pointer="🎧" \
      --marker="✨" \
      --prompt="🎵 音乐 > " \
      --header="❔ ?帮助  🔍 /搜索  ⏎播放  ESC退出" \
      --delimiter="|" \
      --with-nth=1 \
      --bind '"'"'?:preview(echo "
🎵 ytmusic 使用帮助

🔍 /
进入搜索

❔ ?
打开帮助

⬆️⬇️
选择歌曲

⏎
播放歌曲

ESC
退出程序

播放控制:
空格  暂停
↑ ↓   音量
← →   快进
")'"'"' |


    # ------------------------------------------
    # 提取视频地址
    # ------------------------------------------

    cut -d "|" -f2 |


    # ------------------------------------------
    # mpv 播放
    #
    # 只播放最佳音频
    # 不下载视频
    #
    # 资源占用低
    # ------------------------------------------

    xargs -r ${pkgs.mpv}/bin/mpv \
      --title="🎵 ytmusic" \
      --ytdl-format=bestaudio \
      --volume=80

  '';

in
{

  # ==========================================
  # 安装依赖
  #
  # yt-dlp:
  # YouTube解析
  #
  # fzf:
  # 终端搜索选择
  #
  # mpv:
  # 音频播放
  #
  # ytmusic:
  # 自定义命令
  # ==========================================

  home.packages = with pkgs; [
    yt-dlp
    fzf
    mpv
    ytmusic
  ];


  # ==========================================
  # yt-dlp 全局配置
  # ==========================================

  xdg.configFile."yt-dlp/config".text = ''

    # yt-dlp缓存目录
    --cache-dir /home/lk/.cache/yt-dlp


    # 使用电视客户端
    # 减少部分YouTube验证问题

    --extractor-args youtube:player_client=tv

  '';

}
