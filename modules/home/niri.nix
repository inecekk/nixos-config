# modules/home/niri.nix
# =================================================================================
# [Niri 完整配置模块]
# 整合自 dotfiles 配置，保留所有功能，中文快捷键注释
# =================================================================================
{ pkgs, ... }:

let
  scripts = import ../scripts.nix { inherit pkgs; };
in
{
  xdg.configFile."niri/config.kdl" = {
    force = true;
    text = ''
      // ==========================================
      // 1. 显示器配置（仅 eDP-1）
      // ==========================================
      output "eDP-1" {
          mode "3200x2000"
          scale 2.0
          position x=0 y=0
      }

      // ==========================================
      // 2. 手势与热角
      // ==========================================
      gestures {
          hot-corners {
              off
          }
      }

      // ==========================================
      // 3. 输入设备配置
      // ==========================================
      input {
          keyboard {
              xkb {}
              numlock          // 启动时开启 NumLock
          }
          touchpad {
              tap              // 允许点击触控板模拟左键
              natural-scroll   // 自然滚动（类似触摸屏）
          }
          mouse {
              accel-speed -0.72
          }
          trackpoint {}
      }

      // ==========================================
      // 4. 光标配置
      // ==========================================
      cursor {
          xcursor-theme "Adwaita"
          xcursor-size 24
      }

      // ==========================================
      // 5. 布局与外观
      // ==========================================
      layout {
          // 背景颜色（透明）
          background-color "transparent"
          
          gaps 12              // 窗口间距
          
          center-focused-column "never"
          
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }
          
          default-column-width {
              proportion 0.5
          }
          
          focus-ring {
              off              // 关闭焦点环
              width 0
              active-color "#b6c7e7"
              inactive-color "#131315"
              urgent-color "#ffb4ab"
          }
          
          shadow {
              on               // 开启阴影
              softness 10
              spread 4
              offset x=0 y=0
              color "#00000070"
          }

          tab-indicator {
              active-color "#b6c7e7"
              inactive-color "#374761"
              urgent-color "#ffb4ab"
          }

          insert-hint {
              color "#b6c7e780"
          }
      }

      // ==========================================
      // 6. 窗口默认规则（全局）
      // ==========================================
      window-rule {
          opacity 0.9
          geometry-corner-radius 12  // 窗口圆角
          clip-to-geometry true
          draw-border-with-background false
          background-effect {
              blur true
              xray true
          }
      }

      // 全局透明度（聚焦窗口）
      /-window-rule {
          opacity 0.9
      }

      // 未聚焦窗口透明度
      window-rule {
          match is-focused=false
          opacity 0.85
      }

      // ==========================================
      // 7. 模糊效果
      // ==========================================
      blur {
          passes 3
          offset 2.3
          noise 0.001
          saturation 2
      }

      // ==========================================
      // 8. 图层规则（Noctalia）
      // ==========================================
      layer-rule {
          match namespace="^noctalia-wallpaper*"
          place-within-backdrop true
      }

      layer-rule {
          match namespace="^quickshell$"
          place-within-backdrop true
      }

      layer-rule {
          match namespace="^noctalia-bar-bar$"
          opacity 1.0
          geometry-corner-radius 0
          shadow { off; }
          background-effect {
              blur false
          }
      }

      /-layer-rule {
          match namespace="^noctalia-panel$"
      }

      // ==========================================
      // 9. 概览效果
      // ==========================================
      overview {
          backdrop-color "#4c566a90"
          workspace-shadow {
              off
          }
      }

      // ==========================================
      // 10. 环境变量
      // ==========================================
      environment {
          XDG_CURRENT_DESKTOP "niri"
          XDG_SESSION_TYPE "wayland"
          GTK_IM_MODULE ""
          ELECTRON_OZONE_PLATFORM_HINT "auto"
          QT_QPA_PLATFORM "wayland"
          QT_QPA_PLATFORMTHEME "gtk3"
          QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
      }

      // ==========================================
      // 11. 自启动程序
      // ==========================================
      spawn-at-startup "noctalia"

      // ==========================================
      // 12. 其他设置
      // ==========================================
      hotkey-overlay {
          skip-at-startup      // 跳过启动时的快捷键帮助弹窗
      }

      prefer-no-csd
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      // ==========================================
      // 13. 动画配置
      // ==========================================
      animations {
          workspace-switch {
              spring damping-ratio=0.80 stiffness=523 epsilon=0.0001
          }
          window-open {
              duration-ms 150
              curve "ease-out-expo"
          }
          window-close {
              duration-ms 150
              curve "ease-out-quad"
          }
          horizontal-view-movement {
              spring damping-ratio=0.85 stiffness=423 epsilon=0.0001
          }
          window-movement {
              spring damping-ratio=0.75 stiffness=323 epsilon=0.0001
          }
          window-resize {
              spring damping-ratio=0.85 stiffness=423 epsilon=0.0001
          }
          config-notification-open-close {
              spring damping-ratio=0.65 stiffness=923 epsilon=0.001
          }
          screenshot-ui-open {
              duration-ms 200
              curve "ease-out-quad"
          }
          overview-open-close {
              spring damping-ratio=0.85 stiffness=800 epsilon=0.0001
          }
      }

      // ==========================================
      // 14. 特定应用规则
      // ==========================================

      // Noctalia 设置
      window-rule {
          match app-id=r#"^dev\.noctalia\.Noctalia\.Settings$"#
          open-floating true
      }

      // WezTerm 终端
      window-rule {
          match app-id=r#"^org\.wezfurlong\.wezterm$"#
          default-column-width {}
      }

      // 系统工具
      window-rule {
          match app-id=r#"^gnome-control-center$"#
          match app-id=r#"^pavucontrol$"#
          match app-id=r#"^nm-connection-editor$"#
          default-column-width { proportion 0.5; }
          open-floating false
      }

      // 浮动窗口应用
      window-rule {
          match app-id=r#"^org\.gnome\.Calculator$"#
          match app-id=r#"^gnome-calculator$"#
          match app-id=r#"^galculator$"#
          match app-id=r#"^blueman-manager$"#
          match app-id=r#"^org\.gnome\.Nautilus$"#
          match app-id=r#"^xdg-desktop-portal$"#
          open-floating true
      }

      // Steam 通知
      window-rule {
          match app-id=r#"^steam$"# title=r#"^notificationtoasts_\d+_desktop$"#
          default-floating-position x=10 y=10 relative-to="bottom-right"
      }

      // 画中画
      window-rule {
          match app-id=r#"firefox$"# title="^Picture-in-Picture$"
          match app-id="zoom"
          open-floating true
      }

      // Quickshell
      window-rule {
          match app-id=r#"org.quickshell$"#
          open-floating true
      }

      // Wine 应用
      window-rule {
          match app-id="wine"
          open-floating true
          default-column-width { proportion 1.0; }
          draw-border-with-background false
      }

      // ==========================================
      // 15. 应用美化规则
      // ==========================================

      // Zathura PDF阅读器
      window-rule {
          match app-id="org.pwmt.zathura"
          opacity 0.8
          background-effect { blur true; xray true; }
      }

      // VSCode/Codium
      window-rule {
          match app-id="codium"
          opacity 0.85
          background-effect { blur true; xray true; }
      }

      // Steam
      window-rule {
          match app-id="steam"
          opacity 0.9
          background-effect { blur true; xray true; }
      }

      // Obsidian
      window-rule {
          match app-id="obsidian"
          opacity 0.9
          background-effect { blur true; xray true; }
      }

      // Zen 浏览器
      window-rule {
          match app-id="app.zen_browser.zen"
          draw-border-with-background false
          background-effect { blur true; xray true; }
      }

      // Nautilus 文件管理器
      window-rule {
          match app-id=r#"^org\.gnome\.Nautilus$"#
          draw-border-with-background false
          background-effect { blur true; xray true; }
      }

      // ==========================================
      // 16. 游戏专属规则
      // ==========================================
      window-rule {
          // 匹配 Steam 游戏和 Gamescope
          match app-id=r#"^steam_app_.*"#
          match app-id=r#"^gamescope$"#
          match app-id=r#"^wine$"#
          
          // 匹配游戏标题（不区分大小写）
          match title=r#"(?i)genshin impact|zenless zone zero|victoria 3|the sims 4|Endfield"#

          // 禁用透明度，恢复 100% 实体
          opacity 1.0

          // 关闭模糊效果，节省显卡算力
          background-effect {
              blur false
          }

          // 确保没有边框渲染干扰
          draw-border-with-background false
      }

      // ==========================================
      // 17. 画中画规则
      // ==========================================
      window-rule {
          match app-id="firefox" title="画中画"
          match app-id="firefox" title="Picture-in-Picture"
          match app-id="app.zen_browser.zen" title="画中画"
          match app-id="app.zen_browser.zen" title="Picture-in-Picture"

          open-floating true
          opacity 1.0
          default-column-width {}
          default-window-height {}
          default-floating-position x=20 y=20 relative-to="bottom-right"
      }

      // ==========================================
      // 18. Ente-Auth 适配
      // ==========================================
      window-rule {
          match app-id="io.ente.auth"
          open-floating true
          default-column-width { fixed 532; }
          default-window-height { fixed 925; }
      }

      // ==========================================
      // 19. 调试
      // ==========================================
      debug {
          honor-xdg-activation-with-invalid-serial
      }

      // ==========================================
      // 20. 最近窗口切换
      // ==========================================
      recent-windows {
          binds {
              Alt+Tab         { next-window scope="output"; }          // 切换窗口
              Alt+Shift+Tab   { previous-window scope="output"; }      // 反向切换窗口
              Alt+grave       { next-window filter="app-id"; }         // 同应用切换
              Alt+Shift+grave { previous-window filter="app-id"; }     // 反向同应用切换
          }
          highlight {
              corner-radius 12
              active-color "#b6c7e7"
              urgent-color "#ffb4ab"
          }
      }

      // ==========================================
      // 21. 快捷键绑定（中文注释）
      // ==========================================
      binds {
          // --- 系统快捷键 ---
          "Mod+Tab" repeat=false hotkey-overlay-title="切换概览" { toggle-overview; }
          "Mod+Q" hotkey-overlay-title="关闭当前窗口" { close-window; }
          "Mod+Shift+E" hotkey-overlay-title="退出 Niri" { quit; }
          "Mod+Shift+R" hotkey-overlay-title="重新加载配置" { spawn "niri" "msg" "action" "load-config-file"; }

          // --- Noctalia 面板控制 ---
          "Mod+R" hotkey-overlay-title="启动器" { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
          "Mod+X" hotkey-overlay-title="会话管理" { spawn "noctalia" "msg" "panel-toggle" "session"; }
          "Mod+I" hotkey-overlay-title="设置" { spawn "noctalia" "msg" "settings-toggle"; }
          "Mod+V" hotkey-overlay-title="剪贴板" { spawn "noctalia" "msg" "panel-toggle" "clipboard"; }

          // --- 应用启动 ---
          "Mod+Return" hotkey-overlay-title="启动终端" { spawn "kitty"; }
          "Mod+E" hotkey-overlay-title="文件管理器" { spawn "nautilus"; }

          // --- 焦点移动 ---
          "Mod+Left" hotkey-overlay-title="左移焦点" { focus-column-left; }
          "Mod+Right" hotkey-overlay-title="右移焦点" { focus-column-right; }
          "Mod+Up" hotkey-overlay-title="切换到上方工作区" { focus-workspace-up; }
          "Mod+Down" hotkey-overlay-title="切换到下方工作区" { focus-workspace-down; }


          // --- 列/窗口移动 ---
          "Mod+Shift+Left" hotkey-overlay-title="左移列" { move-column-left; }
          "Mod+Shift+Right" hotkey-overlay-title="右移列" { move-column-right; }
          "Mod+Shift+H" hotkey-overlay-title="左移列（备选）" { move-column-left; }
          "Mod+Shift+L" hotkey-overlay-title="右移列（备选）" { move-column-right; }
          "Mod+Shift+J" hotkey-overlay-title="下移窗口" { move-window-down; }
          "Mod+Shift+K" hotkey-overlay-title="上移窗口" { move-window-up; }
          
          "Mod+T" hotkey-overlay-title="切换浮动/平铺" { toggle-window-floating; }

          // --- 窗口调整 ---
          "Mod+F" hotkey-overlay-title="最大化列" { maximize-column; }
          "Mod+Shift+F" hotkey-overlay-title="全屏窗口" { fullscreen-window; }
          "Mod+Space" hotkey-overlay-title="切换列宽预设" { switch-preset-column-width; }

          // --- 窗口吞入/排出 ---
          "Mod+Comma" hotkey-overlay-title="吞入窗口到列" { consume-window-into-column; }
          "Mod+Period" hotkey-overlay-title="排出窗口从列" { expel-window-from-column; }

          // --- 工作区切换 (1-9) ---
          "Mod+1" hotkey-overlay-title="切换到工作区 1" { focus-workspace 1; }
          "Mod+2" hotkey-overlay-title="切换到工作区 2" { focus-workspace 2; }
          "Mod+3" hotkey-overlay-title="切换到工作区 3" { focus-workspace 3; }
          "Mod+4" hotkey-overlay-title="切换到工作区 4" { focus-workspace 4; }
          "Mod+5" hotkey-overlay-title="切换到工作区 5" { focus-workspace 5; }
          "Mod+6" hotkey-overlay-title="切换到工作区 6" { focus-workspace 6; }
          "Mod+7" hotkey-overlay-title="切换到工作区 7" { focus-workspace 7; }
          "Mod+8" hotkey-overlay-title="切换到工作区 8" { focus-workspace 8; }
          "Mod+9" hotkey-overlay-title="切换到工作区 9" { focus-workspace 9; }
          
          // --- 移动列到工作区 (1-9) ---
          "Mod+Shift+1" hotkey-overlay-title="移动列到工作区 1" { move-column-to-workspace 1; }
          "Mod+Shift+2" hotkey-overlay-title="移动列到工作区 2" { move-column-to-workspace 2; }
          "Mod+Shift+3" hotkey-overlay-title="移动列到工作区 3" { move-column-to-workspace 3; }
          "Mod+Shift+4" hotkey-overlay-title="移动列到工作区 4" { move-column-to-workspace 4; }
          "Mod+Shift+5" hotkey-overlay-title="移动列到工作区 5" { move-column-to-workspace 5; }
          "Mod+Shift+6" hotkey-overlay-title="移动列到工作区 6" { move-column-to-workspace 6; }
          "Mod+Shift+7" hotkey-overlay-title="移动列到工作区 7" { move-column-to-workspace 7; }
          "Mod+Shift+8" hotkey-overlay-title="移动列到工作区 8" { move-column-to-workspace 8; }
          "Mod+Shift+9" hotkey-overlay-title="移动列到工作区 9" { move-column-to-workspace 9; }

          // --- 截图 ---
          "Mod+Shift+S" hotkey-overlay-title="截图" { screenshot; }
          "Print" hotkey-overlay-title="截图（Print键）" { screenshot; }
          "Ctrl+Print" hotkey-overlay-title="截图整个屏幕" { screenshot-screen; }
          "Alt+Print" hotkey-overlay-title="截图当前窗口" { screenshot-window; }
          
          // --- 锁屏 ---
          "Mod+L" hotkey-overlay-title="锁屏" { spawn "swaylock"; }
          
          // --- 快捷键帮助 ---
          "Mod+Slash" hotkey-overlay-title="快捷键帮助" { show-hotkey-overlay; }

          // --- 多媒体键 ---
          "XF86AudioRaiseVolume" hotkey-overlay-title="音量增加" { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
          "XF86AudioLowerVolume" hotkey-overlay-title="音量降低" { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
          "XF86AudioMute" hotkey-overlay-title="静音切换" { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

          // --- 鼠标滚轮导航 ---
          "Mod+WheelScrollDown" cooldown-ms=150 hotkey-overlay-title="滚轮向下切换工作区" { focus-workspace-down; }
          "Mod+WheelScrollUp" cooldown-ms=150 hotkey-overlay-title="滚轮向上切换工作区" { focus-workspace-up; }
          "Mod+Ctrl+WheelScrollDown" cooldown-ms=150 hotkey-overlay-title="滚轮向下移动列" { move-column-to-workspace-down; }
          "Mod+Ctrl+WheelScrollUp" cooldown-ms=150 hotkey-overlay-title="滚轮向上移动列" { move-column-to-workspace-up; }

          "Mod+WheelScrollRight" hotkey-overlay-title="滚轮右移焦点" { focus-column-right; }
          "Mod+WheelScrollLeft" hotkey-overlay-title="滚轮左移焦点" { focus-column-left; }
          "Mod+Ctrl+WheelScrollRight" hotkey-overlay-title="滚轮右移列" { move-column-right; }
          "Mod+Ctrl+WheelScrollLeft" hotkey-overlay-title="滚轮左移列" { move-column-left; }

          "Mod+Shift+WheelScrollDown" hotkey-overlay-title="滚轮下移焦点（向右）" { focus-column-right; }
          "Mod+Shift+WheelScrollUp" hotkey-overlay-title="滚轮上移焦点（向左）" { focus-column-left; }
          "Mod+Ctrl+Shift+WheelScrollDown" hotkey-overlay-title="滚轮下移列（向右）" { move-column-right; }
          "Mod+Ctrl+Shift+WheelScrollUp" hotkey-overlay-title="滚轮上移列（向左）" { move-column-left; }

          // --- 亮度控制（仅 eDP-1） ---
          "XF86MonBrightnessUp" allow-when-locked=true hotkey-overlay-title="亮度增加" { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
          "XF86MonBrightnessDown" allow-when-locked=true hotkey-overlay-title="亮度降低" { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }
      }
    '';
  };
}
