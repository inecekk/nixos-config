{ pkgs }:
{
  # GRUB 启动主题构建
  wutheringGrubTheme = pkgs.stdenv.mkDerivation {
    pname = "wuthering-grub-theme"; version = "unstable-2024";
    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice"; repo = "Wuthering-grub2-themes";
      rev = "ed3f8bc"; sha256 = "sha256-q9TLZTZI/giwKu8sCTluxvkBG5tyan7nFOqn4iGLnkA=";
    };
    nativeBuildInputs = [ pkgs.imagemagickBig ];
    buildPhase = ''
      D="$out/grub/themes/changli"; mkdir -p "$D/icons"
      cp common/*.pf2 "$D/" 2>/dev/null || true
      cp assets/assets-icons/icons-4k/* "$D/icons/" 2>/dev/null || true
      cp assets/assets-other/other-4k/* "$D/" 2>/dev/null || true
      BG=$(find . -type f \( -name 'background-changli.jpg' -o -name 'changli*.jpg' \) | head -1)
      [ -z "$BG" ] && BG=$(find . -type f -name '*.jpg' | head -1)
      [ -n "$BG" ] && magick "$BG" -resize 3840x2160! -quality 95 "$D/background.jpg" || exit 1
      for f in config/theme-4k.txt theme-4k.txt; do [ -f "$f" ] && cp "$f" "$D/theme.txt" && break; done || true
    '';
    installPhase = "true";
  };

  # 随机壁纸切换脚本
  randomWallpaperScript = pkgs.writeShellScript "random-wallpaper.sh" ''
    DIR="/home/lk/D/Pictures/Wallpaper/WallhavenDesktop"
    [ -d "$DIR" ] && WALLPAPER=$(find "$DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)
    [ -n "$WALLPAPER" ] && pkill swaybg && swaybg -i "$WALLPAPER" -m fill &
  '';

  # 实时网速监测（上下行总速率）
  netSpeedScript = pkgs.writeShellScript "net-speed.sh" ''
    IF=$(ip route | awk '/default/{print $5; exit}')
    [ -z "$IF" ] && echo '{"text":"无网络"}' && exit 0
    R1=$(cat /sys/class/net/$IF/statistics/rx_bytes); T1=$(cat /sys/class/net/$IF/statistics/tx_bytes)
    sleep 1
    R2=$(cat /sys/class/net/$IF/statistics/rx_bytes); T2=$(cat /sys/class/net/$IF/statistics/tx_bytes)
    TOTAL=$(( (R2 - R1) + (T2 - T1) ))
    echo "{\"text\":\"$((TOTAL / 1024))K/s\"}"
  '';


  # 自定义时钟脚本（强制 C locale 避免中文 上/下午）
clockScript = pkgs.writeShellScript "clock.sh" ''
  TEXT=$(LC_TIME=C date '+%m/%d %p %I:%M:%S')
  echo "{\"text\":\"$TEXT\"}"
'';
  # 音量图标脚本
  volumeIconScript = pkgs.writeShellScript "volume-icon.sh" ''
    RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    VOL=$(echo "$RAW" | awk '{print int($2*100)}')
    if echo "$RAW" | grep -q "MUTED"; then echo "{\"text\":\"🔇 Mute\"}";
    else echo "{\"text\":\"$( [ $VOL -lt 30 ] && echo "🔈" || echo "🔊" ) $VOL%\"}"; fi
  '';

  # 实时天气（仅显示当前温度，去掉30天详细预报）
  weatherScript = pkgs.writeShellScript "weather.sh" ''
    data=$(curl -s --connect-timeout 2 "wttr.in/Yangxian?format=%t" | sed 's/+//g')
    echo "{\"text\": \"󰖐 $data\"}"
  '';

  # 30 天详细天气弹窗（已注释，不再使用）
  # weatherDetailsScript = pkgs.writeShellScript "weather-details.sh" ''
  #   export WAYLAND_DISPLAY=wayland-1
  #   DETAILS=$(curl -s "wttr.in/Yangxian?format=3&period=30" | sed 's/\x1b\[[0-9;]*m//g')
  #   echo "$DETAILS" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --lines 20 --width 60 --title "30天天气预报"
  # '';
}
