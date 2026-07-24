{ pkgs, ... }:

let

  ytmusic = pkgs.writeShellScriptBin "ytmusic" ''
#!/usr/bin/env bash

COOKIE="firefox:/home/lk/.config/zen/tso70vj4.Default Profile"
CACHE="$HOME/.cache/yt-dlp"

help(){
cat <<EOF
🎵 ytmusic

搜索:
ytmusic 歌曲名

快捷键:
↑ ↓ 选择
Enter 播放
x 后退10秒
v 快进10秒
空格 暂停
ESC 退出
EOF
}

if [ "$1" = "?" ]; then
    help
    exit
fi

if [ $# -eq 0 ]; then
    query="2026 Pop Playlist"
else
    query="$*"
fi

mkdir -p "$CACHE"

result=$(
${pkgs.yt-dlp}/bin/yt-dlp \
 --cookies-from-browser "$COOKIE" \
 --ignore-errors \
 --cache-dir "$CACHE" \
 --extractor-args "youtube:player_client=web" \
 --print "%(title)s---https://www.youtube.com/watch?v=%(id)s" \
 "ytsearch5:$query" 2>/dev/null
)

[ -z "$result" ] && echo "❌ 没有找到歌曲" && exit 1

song=$(echo "$result" |
${pkgs.fzf}/bin/fzf \
 --height=70% \
 --layout=reverse \
 --border=rounded \
 --pointer="🎧" \
 --marker="✨" \
 --prompt="🎵 " \
 --delimiter="---" \
 --with-nth=1)

[ -z "$song" ] && exit

url=$(echo "$song" | awk -F '---' '{print $2}')

${pkgs.mpv}/bin/mpv \
 --title="🎵 ytmusic" \
 --ytdl-format="best[ext=m4a]/best" \
 --ytdl-raw-options="cookies-from-browser=firefox:/home/lk/.config/zen/tso70vj4.Default Profile" \
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

  xdg.configFile."yt-dlp/config".text = ''
--cache-dir /home/lk/.cache/yt-dlp
--extractor-args youtube:player_client=web
--no-warnings
'';


  xdg.configFile."mpv/input.conf".text = ''
SPACE cycle pause
x seek -10
v seek 10
LEFT seek -5
RIGHT seek 5
UP add volume 5
DOWN add volume -5
ESC quit
'';
}
