{ pkgs, ... }:

let

  ytmusic = pkgs.writeShellScriptBin "ytmusic" ''
#!/usr/bin/env bash

# ==========================================
# 🎵 ytmusic
# Terminal YouTube Music Player
#
# yt-dlp  搜索解析
# fzf     交互选择
# mpv     播放
# ==========================================


COOKIE="firefox:/home/lk/.config/zen/tso70vj4.Default Profile"

CACHE="/home/lk/.cache/yt-dlp"


help_text()
{
cat <<'EOF'

🎵 ytmusic 使用帮助

搜索:

ytmusic 歌曲名


快捷键:

↑ ↓
选择歌曲

Enter
播放


命令:

ytmusic ?
打开帮助


播放器:

空格
暂停 / 播放

↑ ↓
音量

← →
快进


ESC
退出

EOF
}


# ==========================================
# 参数
# ==========================================

query="$@"


if [ "$query" = "?" ]; then
    help_text
    exit 0
fi


if [ -z "$query" ]; then
    query="YouTube Music Trending Songs"
fi


mkdir -p "$CACHE"



# ==========================================
# 搜索 YouTube
# ==========================================


result=$(
${pkgs.yt-dlp}/bin/yt-dlp \
    --cookies-from-browser "$COOKIE" \
    --flat-playlist \
    --no-playlist \
    --ignore-errors \
    --cache-dir "$CACHE" \
    --extractor-args "youtube:player_client=tv" \
    --print "%(title)s|%(url)s" \
    "ytsearch10:$query" 2>/dev/null
)



if [ -z "$result" ]; then
    echo "❌ 没有找到歌曲"
    exit 1
fi



# ==========================================
# fzf选择
# ==========================================


song=$(
echo "$result" |

${pkgs.fzf}/bin/fzf \
    --height=70% \
    --layout=reverse \
    --border=rounded \
    --pointer="🎧" \
    --marker="✨" \
    --prompt="🎵 音乐 > " \
    --delimiter="|" \
    --with-nth=1 \
    --info=inline
)



if [ -z "$song" ]; then
    exit 0
fi



url=$(echo "$song" | cut -d "|" -f2)



# ==========================================
# mpv播放
# ==========================================


${pkgs.mpv}/bin/mpv \
    --title="🎵 ytmusic" \
    --ytdl-format=bestaudio \
    --volume=80 \
    "$url"

'';



  yt = pkgs.writeShellScriptBin "yt" ''
    exec ytmusic "$@"
  '';



in
{

  home.packages = with pkgs; [

    yt-dlp
    fzf
    mpv

    ytmusic
    yt

  ];



  # ==========================================
  # yt-dlp 配置
  # ==========================================

  xdg.configFile."yt-dlp/config".text = ''
--cache-dir /home/lk/.cache/yt-dlp
--extractor-args youtube:player_client=tv
--no-warnings
'';


}
