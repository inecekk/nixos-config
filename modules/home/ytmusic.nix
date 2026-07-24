{ pkgs, ... }:

let
  ytmusic = pkgs.writeShellScriptBin "ytmusic" ''
    query="$*"

    ${pkgs.yt-dlp}/bin/yt-dlp \
      --print "%(title)s|%(webpage_url)s" \
      "ytsearch10:$query" |
    ${pkgs.fzf}/bin/fzf \
      --delimiter="|" \
      --with-nth=1 |
    cut -d "|" -f2 |
    xargs -r ${pkgs.mpv}/bin/mpv \
      --volume=80 \
      --ytdl-format=bestaudio \
      --ytdl-raw-options=cookies-from-browser="firefox:/home/lk/.config/zen/tso70vj4.Default Profile"
  '';
in
{
  home.packages = with pkgs; [
    yt-dlp
    fzf
    ytmusic
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
