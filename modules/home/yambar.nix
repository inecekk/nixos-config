{ pkgs, ... }:
let
  # ============================================================
  # 1. Niri 工作区模块
  # 功能：调用 `niri msg -j workspaces` 获取当前所有工作区信息（JSON），
  #       用 jq 按 idx 数字排序后拼接成一行文本；当前聚焦的工作区用方括号
  #       包裹以示区分。随后监听 niri 的事件流（event-stream），一旦
  #       工作区发生切换 / 增删等变化，就重新计算一次并输出给 yambar。
  # 协议：yambar script 模块要求每次输出为 `变量名|类型|值`，
  #       并且每一批更新后要跟一个空行表示"这一轮数据结束"。
  # ============================================================
  niri-workspace = pkgs.writeShellScript "yambar-niri-workspace" ''
    update_ws() {
      ws=$(${pkgs.niri}/bin/niri msg -j workspaces | ${pkgs.jq}/bin/jq -r '
        sort_by(.idx)
        | map(if .is_focused then "[\(.name // .idx)]" else " \(.name // .idx) " end)
        | join("")
      ')
      echo "ws|string|$ws"
      echo ""   # 空行表示本次更新结束
    }
    update_ws  # 启动时先输出一次当前状态，避免刚启动时状态栏空白
    # 监听 niri 事件流，每来一行事件就刷新一次工作区显示
    ${pkgs.niri}/bin/niri msg --json event-stream | while read -r line; do
      update_ws
    done
  '';

  # ============================================================
  # 2. CPU 占用监控
  # 功能：读取 /proc/stat 第一行（全局 CPU 累计时间），间隔 1 秒采样两次，
  #       用差值计算这 1 秒内的平均占用率。
  #       字段含义（按顺序）：user nice system idle iowait irq softirq steal
  # ============================================================
  cpu-script = pkgs.writeShellScript "yambar-cpu" ''
    get_stat() {
      # $2~$8 相加为总时间片，$5 为 idle（空闲）时间片
      head -n1 /proc/stat | awk '{print $2+$3+$4+$5+$6+$7+$8, $5}'
    }
    while true; do
      read total1 idle1 <<< "$(get_stat)"
      sleep 1
      read total2 idle2 <<< "$(get_stat)"
      dtotal=$(( total2 - total1 ))   # 总时间片增量
      didle=$(( idle2 - idle1 ))      # 空闲时间片增量
      if [ "$dtotal" -gt 0 ]; then
        pct=$(( (100 * (dtotal - didle)) / dtotal ))  # 占用率 = 1 - 空闲占比
      else
        pct=0
      fi
      echo "cpu|string|󰻠 ''${pct}%"
      echo ""
    done
  '';

  # ============================================================
  # 3. 内存占用监控
  # 功能：读取 /proc/meminfo 的 MemTotal（总内存）与 MemAvailable
  #       （真实可用内存，已扣除可回收缓存），计算已用内存百分比。
  #       每 3 秒刷新一次，内存变化没有 CPU 那么剧烈，不需要 1 秒级刷新。
  # ============================================================
  mem-script = pkgs.writeShellScript "yambar-mem" ''
    while true; do
      total=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
      avail=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
      used=$(( total - avail ))
      pct=$(( (100 * used) / total ))
      echo "mem|string|󰍛 ''${pct}%"
      echo ""
      sleep 3
    done
  '';

  # ============================================================
  # 4. 网速监控
  # 功能：找到默认路由使用的网卡（通常是 wifi 或有线网卡），
  #       读取 /proc/net/dev 中该网卡的收发字节数（第 2 列接收 + 第 10 列发送），
  #       间隔 1 秒采样两次算出差值，即为每秒网速（KB/s）。
  #       图标使用 WiFi 符号 󰤨。
  # 注意：''${speed} 使用双美元符号转义，防止 Nix 把 ${...} 当作自己的字符串
  #       插值语法来解析，这里我们要的是纯 Bash 变量引用。
  # ============================================================
  network-speed = pkgs.writeShellScript "yambar-net-speed" ''
    get_bytes() {
      iface=$(ip route get 8.8.8.8 | awk '{print $5}')  # 取默认路由的出口网卡名
      cat /proc/net/dev | grep "$iface" | awk '{print $2+$10}'
    }
    while true; do
      b1=$(get_bytes)
      sleep 1
      b2=$(get_bytes)
      speed=$(( (b2 - b1) / 1024 ))  # 字节差 / 1024 = KB/s
      echo "net|string|󰤨 ''${speed}KB/s"
      echo ""
    done
  '';

  # ============================================================
  # 5. 电池模块（横向电池图标版本）
  # 功能：读取 BAT0 的电量百分比与充放电状态。
  #       图标改用 Font Awesome 风格的"横向胶囊"电池图标（而非竖版），
  #       并按电量档位（满/75%/50%/25%/低电量）切换图标；
  #       充电时额外叠加一个闪电符号 󰂄 提示正在充电。
  # ============================================================
  battery-script = pkgs.writeShellScript "yambar-battery" ''
    while true; do
      if [ -e /sys/class/power_supply/BAT0/capacity ]; then
        CAP=$(cat /sys/class/power_supply/BAT0/capacity)
        STATUS=$(cat /sys/class/power_supply/BAT0/status)

        # 根据电量百分比选择横向电池图标（满/75/50/25/空）
        if   [ "$CAP" -ge 90 ]; then ICON=""   # 横向满电
        elif [ "$CAP" -ge 65 ]; then ICON=""   # 横向 75%
        elif [ "$CAP" -ge 35 ]; then ICON=""   # 横向 50%
        elif [ "$CAP" -ge 10 ]; then ICON=""   # 横向 25%
        else                        ICON=""   # 横向低电量
        fi

        # 充电中额外加一个闪电符号前缀，与图标区分状态
        if [ "$STATUS" = "Charging" ]; then
          PREFIX="󰂄 "
        else
          PREFIX=""
        fi

        echo "bat|string|''${PREFIX}$ICON ''${CAP}%"
      else
        echo "bat|string|󰂑 AC"   # 没有电池（台式机/外接电源）
      fi
      echo ""
      sleep 30
    done
  '';

  # ============================================================
  # 6. 音量模块
  # 功能：用 wpctl（wireplumber 自带工具）读取默认输出设备的音量，
  #       根据是否静音 / 音量高低切换不同图标。
  # ============================================================
  volume-script = pkgs.writeShellScript "yambar-volume" ''
    get_vol() {
      ${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@
    }
    update_vol() {
      raw=$(get_vol)  # 形如 "Volume: 0.45" 或 "Volume: 0.45 [MUTED]"
      vol=$(echo "$raw" | awk '{print $2}')
      pct=$(echo "$vol * 100" | ${pkgs.bc}/bin/bc | cut -d'.' -f1)
      if echo "$raw" | grep -q MUTED; then
        ICON="󰝟"   # 静音
      elif [ "$pct" -ge 60 ]; then
        ICON="󰕾"   # 高音量
      elif [ "$pct" -ge 1 ]; then
        ICON="󰖀"   # 低音量
      else
        ICON="󰸈"   # 音量为 0
      fi
      echo "vol|string|$ICON ''${pct}%"
      echo ""
    }
    update_vol
    while true; do
      sleep 2
      update_vol
    done
  '';
in
{
  # 依赖包：yambar 本体、wireplumber（音量控制）、bc（音量计算需要浮点运算）
  home.packages = [ pkgs.yambar pkgs.wireplumber pkgs.bc ];

  # 将生成的 config.yml 写入 ~/.config/yambar/config.yml
  xdg.configFile."yambar/config.yml" = {
    force = true;  # 覆盖已有文件，确保每次 rebuild 都用最新配置
    text = ''
      # ===================== yambar 状态栏总配置 =====================
      bar:
        height: 50
        location: top
        background: 1e1e2ecc          # 深紫黑半透明背景（Dracula 风格）
        margin: 8                     # 状态栏整体上下边距（离屏幕边缘）
        left-spacing: 16              # 左侧区域整体左边距
        right-spacing: 16             # 右侧区域整体右边距
        font: JetBrainsMono Nerd Font:size=26

        # ---------- 左侧区域：工作区 + CPU + 内存 ----------
        left:
          - script: # 工作区（去掉了前面的电脑图标，直接显示数字/名称）
              path: ${niri-workspace}
              content: { string: { text: "{ws}", foreground: cba6f7ff, margin: 10 } } # 淡紫色，间距收窄

          - script: # CPU 占用
              path: ${cpu-script}
              content: { string: { text: "{cpu}", foreground: fab387ff, margin: 10 } } # 淡橙色

          - script: # 内存占用
              path: ${mem-script}
              content: { string: { text: "{mem}", foreground: 94e2d5ff, margin: 10 } } # 淡青色

        # ---------- 中间区域：时钟 ----------
        center:
          - clock:
              date-format: "%y/%m/%d"
              time-format: "%P %I:%M:%S %a"
              content: [ string: { text: "{date} {time}", foreground: f9e2afff, margin: 10 } ] # 米黄色

        # ---------- 右侧区域：音量 / 网速 / 电池 ----------
        right:
          - script: # 音量
              path: ${volume-script}
              content: { string: { text: "{vol}", foreground: a6e3a1ff, margin: 10 } } # 淡绿色

          - script: # 网速（WiFi 图标）
              path: ${network-speed}
              content: { string: { text: "{net}", foreground: 89b4faff, margin: 10 } } # 淡蓝色

          - script: # 电池状态（横向图标）
              path: ${battery-script}
              content: { string: { text: "{bat}", foreground: f38ba8ff, margin: 10 } } # 淡红色
	bar:
	   height: 50
  	location: top
  	background: 1e1e2ecc
  	margin: 8
  	left-spacing: 16
	right-spacing: 16
  	spacing: 5          # 新增：模块与模块之间的间距
  	font: JetBrainsMono Nerd Font:size=26
    '';
  };
}
