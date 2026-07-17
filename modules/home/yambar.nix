{ pkgs, ... }:

let
  # 1. Niri 工作区模块：直接输出工作区名称
  niri-workspace = pkgs.writeShellScript "yambar-niri-workspace" ''
    update_ws() {
      ${pkgs.niri}/bin/niri msg -j workspaces | ${pkgs.jq}/bin/jq -r '
        map(if .is_focused then "[\(.name)]" else " \(.name) " end) | join("")
      '
    }
    update_ws
    ${pkgs.niri}/bin/niri msg --json event-stream | while read -r line; do
      update_ws
    done
  '';

  # 2. 网速监控脚本：通过双美元符号转义防止 Nix 误解析 Bash 变量
  network-speed = pkgs.writeShellScript "yambar-net-speed" ''
    get_bytes() { cat /proc/net/dev | grep $(ip route get 8.8.8.8 | awk '{print $5}') | awk '{print $2+$10}'; }
    while true; do
      b1=$(get_bytes)
      sleep 1
      b2=$(get_bytes)
      speed=$(( (b2 - b1) / 1024 ))
      # 使用 ''${speed} 转义 Bash 变量，确保 Nix 正确处理
      echo "net|string|󰛳 ''${speed}KB/s"
      echo ""
    done
  '';

  # 3. 电池模块：包含充电状态图标区分
  battery-script = pkgs.writeShellScript "yambar-battery" ''
    while true; do
      if [ -e /sys/class/power_supply/BAT0/capacity ]; then
        CAP=$(cat /sys/class/power_supply/BAT0/capacity)
        STATUS=$(cat /sys/class/power_supply/BAT0/status)
        case "$STATUS" in
          Charging) ICON="󰂄" ;; # 充电图标
          Full)     ICON="󰁹" ;; # 满电图标
          *)        ICON="󰁿" ;; # 放电图标
        esac
        echo "bat|string|$ICON ''${CAP}%"
      else
        echo "bat|string|󰂑 AC"
      fi
      echo ""
      sleep 30
    done
  '';
in
{
  home.packages = [ pkgs.yambar ];

  xdg.configFile."yambar/config.yml" = {
    force = true;
    text = ''
      bar:
        height: 50
        location: top
        background: 1e1e2ecc
        font: JetBrainsMono Nerd Font:size=26

        left: # 左侧区域
          - script:
              path: ${niri-workspace}
              content: { string: { text: "󰍹 {ws}", foreground: cba6f7ff, margin: 30 } }

        center: # 中间区域
          - clock:
              date-format: "%y/%m/%d"
              time-format: "%p %I:%M:%S"
              content: [ string: { text: "{date} {time}", foreground: b4befeff } ]

        right: # 右侧区域
          - script: # 网速监控
              path: ${network-speed}
              content: { string: { text: "{net}", foreground: 89b4faff, margin: 15 } }
          
          - script: # 电池状态
              path: ${battery-script}
              content: { string: { text: "{bat}", foreground: 94e2d5ff, margin: 20 } }
    '';
  };
}
