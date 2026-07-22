{ pkgs, ... }:
let
  # ============================================================
  # 工作区模块：读取 niri 工作区列表，按 idx 排序，聚焦项加方括号，监听事件流实时刷新
  # ============================================================
  niri-workspace = pkgs.writeShellScript "yambar-niri-workspace" ''
    update_ws() {
      ws=$(${pkgs.niri}/bin/niri msg -j workspaces | ${pkgs.jq}/bin/jq -r '
        sort_by(.idx) | map(if .is_focused then "[\(.name // .idx)]" else " \(.name // .idx) " end) | join("")
      ')
      echo "ws|string|$ws"; echo ""
    }
    update_ws
    ${pkgs.niri}/bin/niri msg --json event-stream | while read -r line; do update_ws; done
  '';

  # ============================================================
  # CPU 占用模块：采样 /proc/stat 前后差值算 1 秒平均占用率
  # ============================================================
  cpu-script = pkgs.writeShellScript "yambar-cpu" ''
    get_stat() { head -n1 /proc/stat | awk '{print $2+$3+$4+$5+$6+$7+$8, $5}'; }
    while true; do
      read total1 idle1 <<< "$(get_stat)"; sleep 1; read total2 idle2 <<< "$(get_stat)"
      dtotal=$(( total2 - total1 )); didle=$(( idle2 - idle1 ))
      pct=0; [ "$dtotal" -gt 0 ] && pct=$(( (100 * (dtotal - didle)) / dtotal ))
      echo "cpu|string|󰻠 ''${pct}%"; echo ""
    done
  '';

  # ============================================================
  # 内存占用模块：MemTotal - MemAvailable 得已用内存，显示 GiB 数值
  # ============================================================
  mem-script = pkgs.writeShellScript "yambar-mem" ''
    while true; do
      total=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
      avail=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
      used_gib=$(awk -v t="$total" -v a="$avail" 'BEGIN{printf "%.1f", (t-a)/1024/1024}')
      echo "mem|string|󰍛 ''${used_gib}GiB"; echo ""
      sleep 3
    done
  '';

  # ============================================================
  # 磁盘占用模块：读取根分区（/）已用百分比，每 60 秒刷新一次
  # ============================================================
  disk-script = pkgs.writeShellScript "yambar-disk" ''
    while true; do
      pct=$(df --output=pcent / | tail -n1 | tr -d ' %')
      echo "disk|string|󰋊 ''${pct}%"; echo ""
      sleep 60
    done
  '';

  # ============================================================
  # CPU 温度模块：读取第一个 thermal_zone 的温度（原始单位为毫摄氏度），每 5 秒刷新
  # ============================================================
  temp-script = pkgs.writeShellScript "yambar-temp" ''
    while true; do
      raw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)
      temp=$(( raw / 1000 ))
      echo "temp|string|󰔏 ''${temp}°C"; echo ""
      sleep 5
    done
  '';

  # ============================================================
  # 网速模块：默认路由网卡收发字节差值算 KB/s，WiFi 图标
  # ============================================================
  network-speed = pkgs.writeShellScript "yambar-net-speed" ''
    get_bytes() {
      iface=$(ip route get 8.8.8.8 | awk '{print $5}')
      cat /proc/net/dev | grep "$iface" | awk '{print $2+$10}'
    }
    while true; do
      b1=$(get_bytes); sleep 1; b2=$(get_bytes)
      speed=$(( (b2 - b1) / 1024 ))
      echo "net|string|󰤨 ''${speed}KB/s"; echo ""
    done
  '';

  # ============================================================
  # 电池模块：横向图标按电量分档，充电/未充满时加闪电前缀
  # ============================================================
  battery-script = pkgs.writeShellScript "yambar-battery" ''
    while true; do
      if [ -e /sys/class/power_supply/BAT0/capacity ]; then
        CAP=$(cat /sys/class/power_supply/BAT0/capacity)
        STATUS=$(cat /sys/class/power_supply/BAT0/status)
        if   [ "$CAP" -ge 90 ]; then ICON=""
        elif [ "$CAP" -ge 65 ]; then ICON=""
        elif [ "$CAP" -ge 35 ]; then ICON=""
        elif [ "$CAP" -ge 10 ]; then ICON=""
        else                        ICON=""
        fi
        PREFIX=""
        case "$STATUS" in
          Charging|"Not charging") PREFIX="󰂄 " ;;
        esac
        echo "bat|string|''${PREFIX}$ICON ''${CAP}%"
      else
        echo "bat|string|󰂑 AC"
      fi
      echo ""; sleep 30
    done
  '';

  # ============================================================
  # 音量模块：wpctl 读音量，按静音/高/低音量切换图标
  # ============================================================
  volume-script = pkgs.writeShellScript "yambar-volume" ''
    update_vol() {
      raw=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)
      vol=$(echo "$raw" | awk '{print $2}')
      pct=$(echo "$vol * 100" | ${pkgs.bc}/bin/bc | cut -d'.' -f1)
      if echo "$raw" | grep -q MUTED; then ICON="󰝟"
      elif [ "$pct" -ge 60 ]; then ICON="󰕾"
      elif [ "$pct" -ge 1 ]; then ICON="󰖀"
      else ICON="󰸈"; fi
      echo "vol|string|$ICON ''${pct}%"; echo ""
    }
    update_vol
    while true; do sleep 2; update_vol; done
  '';

  # ============================================================
  # MPD 音乐信息模块：用 mpc idle 阻塞监听，有变化才刷新，避免轮询浪费
  # ============================================================
  mpd-script = pkgs.writeShellScript "yambar-mpd" ''
    update_song() {
      status=$(${pkgs.mpc}/bin/mpc status 2>/dev/null | sed -n '2p' | awk '{print $1}')
      song=$(${pkgs.mpc}/bin/mpc current 2>/dev/null)
      if [ -z "$song" ]; then
        echo "mpd|string|"
      elif [ "$status" = "[playing]" ]; then
        echo "mpd|string|󰐊 ''${song}"
      else
        echo "mpd|string|󰏤 ''${song}"
      fi
      echo ""
    }
    update_song
    while true; do
      ${pkgs.mpc}/bin/mpc idle player > /dev/null 2>&1
      update_song
    done
  '';

  # ============================================================
  # fcitx5 输入法状态模块：轮询当前输入法名称，每 3 秒刷新
  # ============================================================
  fcitx-script = pkgs.writeShellScript "yambar-fcitx" ''
    while true; do
      im=$(${pkgs.fcitx5}/bin/fcitx5-remote -n 3>/dev/null)
      case "$im" in
        *pinyin*|*rime*) label="zh" ;;
        *keyboard-us*)   label="en" ;;
        *)               label="''${im}" ;;
      esac
      echo "fcitx|string|󰌌 ''${label}"; echo ""
      sleep 2
    done
  '';
in
{
  # 依赖包：yambar 本体、wireplumber（音量）、bc（浮点计算）、mpc-cli（MPD 客户端）、fcitx5（输入法状态查询）
  home.packages = [ pkgs.yambar pkgs.wireplumber pkgs.bc pkgs.mpc pkgs.fcitx5 ];

  xdg.configFile."yambar/config.yml" = {
    force = true;
    text = ''
      # ===================== yambar 状态栏总配置 =====================
      bar:
        height: 50
        location: top
        background: 1e1e2ecc     # 深紫黑半透明背景
        margin: 3                # 整体上下边距
        left-spacing: 0          # 左区离屏幕左边缘的距离（留出空隙）
        right-spacing: 0         # 右区离屏幕右边缘的距离（留出空隙）
        spacing: 2                # 同区域内相邻模块之间的间距
        font: JetBrainsMono Nerd Font:size=26

        # ---------- 左侧区域：工作区 + CPU + 内存 + 磁盘 + 温度 ----------
        left:
          - script:
              path: ${niri-workspace}
              content: { string: { text: "{ws}", foreground: cba6f7ff, left-margin: 5, right-margin: 5 } } # 淡紫
          - script:
              path: ${cpu-script}
              content: { string: { text: "{cpu}", foreground: fab387ff, left-margin: 4, right-margin: 4 } } # 淡橙
          - script:
              path: ${mem-script}
              content: { string: { text: "{mem}", foreground: 94e2d5ff, left-margin: 4, right-margin: 4 } } # 淡青
          - script:
              path: ${disk-script}
              content: { string: { text: "{disk}", foreground: 89dcebff, left-margin: 4, right-margin: 4 } } # 淡天蓝
          - script:
              path: ${temp-script}
              content: { string: { text: "{temp}", foreground: eba0acff, left-margin: 4, right-margin: 4 } } # 淡珊瑚色

        # ---------- 中间区域：时钟 ----------
        center:
          - clock:
              date-format: "%y/%m/%d"
              time-format: "%P %I:%M:%S %a"
              content: [ string: { text: "{date} {time}", foreground: f9e2afff, left-margin: 6, right-margin: 6 } ] # 米黄

        # ---------- 右侧区域：音乐 / 输入法 / 音量 / 网速 / 电池 ----------
        right:
          - script:
              path: ${mpd-script}
              content: { string: { text: "{mpd}", foreground: f5c2e7ff, left-margin: 4, right-margin: 4 } } # 淡粉
          - script:
              path: ${fcitx-script}
              content: { string: { text: "{fcitx}", foreground: cdd6f4ff, left-margin: 4, right-margin: 4 } } # 淡灰白
          - script:
              path: ${volume-script}
              content: { string: { text: "{vol}", foreground: a6e3a1ff, left-margin: 4, right-margin: 4 } } # 淡绿
          - script:
              path: ${network-speed}
              content: { string: { text: "{net}", foreground: 89b4faff, left-margin: 4, right-margin: 4 } } # 淡蓝
          - script:
              path: ${battery-script}
              content: { string: { text: "{bat}", foreground: f38ba8ff, left-margin: 0, right-margin: 0 } } # 淡红
    '';
  };
}
