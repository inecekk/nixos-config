{ pkgs, ... }:

let

  ytmusic = pkgs.writeShellScriptBin "ytmusic" ''
#!/usr/bin/env bash

# ==========================================
# 🎵 ytmusic
# 终端 YouTube Music 播放器
#
# yt-dlp  搜索解析
# fzf     交互选择
# mpv     音频播放
# ==========================================


COOKIE="firefox:/home/lk/.config/zen/tso70vj4.Default Profile"


CACHE="/home/lk/.cache/yt-dlp"


help_text()
{
cat <<'EOF'
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

空格
暂停 / 播放

↑ ↓
音量

← →
快进
EOF
}


# ------------------------------------------
# 参数
# ------------------------------------------

query="$*"


if [ -z "$query" ]; then
    query="YouTube Music Trending Songs"
fi


mkdir -p "$CACHE"


# ------------------------------------------
# 搜索
# ------------------------------------------

result=$(
${pkgs.yt-dlp}/bin/yt-dlp \
    --cookies-from-browser "$COOKIE" \
    --flat-playlist \
    --no-playlist \
    --ignore-errors \
    --cache-dir "$CACHE" \
    --extractor-args "youtube:player_client=tv" \
    --print "%(title)s|%(url)s" \
    "ytsearch8:$query" \
)


if [ -z "$result" ]; then
    echo "❌ 没有找到歌曲"
    exit 1
fi


# ------------------------------------------
# fzf选择
# ------------------------------------------

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
    --bind "?":preview\(echo\ \"$(printf '%q' "$(help_text)")\"\)
)


if [ -z "$song" ]; then
    exit 0
fi


url=$(echo "$song" | cut -d "|" -f2)


# ------------------------------------------
# 播放
# ------------------------------------------

${pkgs.mpv}/bin/mpv \
    --title="🎵 ytmusic" \
    --ytdl-format=bestaudio \
    --volume=80 \
    "$url"

  '';

in
{

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
--cache-dir /home/lk/.cache/yt-dlp
--extractor-args youtube:player_client=tv
--no-warnings
'';


}
