# modules/home/niri.nix
# =================================================================================
# [Niri 完整配置模块]
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
      // 1. 输入设备配置
      // ==========================================
      input {
          keyboard {
              numlock          // 启动时开启 NumLock
          }
          touchpad {
              tap              // 允许点击触控板模拟左键
              natural-scroll   // 自然滚动（类似触摸屏）
          }
      }

      // ==========================================
      // 2. 显示器与光标
      // ==========================================
      cursor {
          xcursor-size 24
      }

      output "eDP-1" {
          scale 2
      }

      // ==========================================
      // 3. 布局与外观
      // ==========================================
      hotkey-overlay {
          skip-at-startup      // 跳过启动时的快捷键帮助弹窗
      }
      // code 透明
	window-rule {
  	match app-id="code"
  	opacity 0.7
}

      layout {
          gaps 16              // 窗口间距
          preset-column-widths {
              proportion 0.25
              proportion 0.5
              proportion 0.75
          }
          default-column-width {
              proportion 0.5
          }
          focus-ring {
              width 4
              active-color "#a0e8af20"
              inactive-color "#50505020"
          }
          border {
              off              // 关闭窗口边框
          }
          shadow {
              softness 30
              spread 5
              offset x=0 y=5
              color "#0007"
          }
      }

      window-rule {
          geometry-corner-radius 12  // 窗口圆角
          clip-to-geometry true
      }

      // ==========================================
      // 4. 自启动程序
spawn-at-startup "qs" "-c" "noctalia-shell"
      // 延迟拉起 dae 代理服务
      spawn-at-startup "sh" "-c" "sleep 3 && sudo systemctl start dae.service"
      
      // 空闲管理守护进程
       /*   

		spawn-at-startup "swayidle" "-w" \
          "timeout" "233" "niri msg action power-off-monitors" \
          "resume" "niri msg action power-on-monitors" \
          "before-sleep" "niri msg action power-off-monitors" \
          "after-resume" "niri msg action power-on-monitors"
*/
      // ==========================================
      // 5. 快捷键绑定
      // ==========================================
      binds {
          // --- 系统快捷键 ---
          "Mod+Slash" hotkey-overlay-title="快捷键帮助" { show-hotkey-overlay; }
          "Mod+Shift+E" hotkey-overlay-title="退出 Niri" { quit; }
          "Mod+S" hotkey-overlay-title="截图" { screenshot; }
          //"Ctrl+B" hotkey-overlay-title="隐藏/显示 Waybar" { spawn "sh" "-c" "pgrep waybar && pkill waybar || waybar &"; }

          // --- 应用启动 ---
          "Mod+Return" hotkey-overlay-title="启动终端" { spawn "foot"; }
          "Mod+Shift+Return" hotkey-overlay-title="随机壁纸" { spawn "${scripts.randomWallpaperScript}"; }
          "Mod+E" hotkey-overlay-title="文件管理器" { spawn "yazi"; }
          "Mod+G" hotkey-overlay-title="Chrome 浏览器" { spawn "google-chrome-stable"; }
          "Mod+Z" hotkey-overlay-title="Zen 浏览器" { spawn "zen"; }
          "Mod+Shift+M" hotkey-overlay-title="Materialgram" { spawn "materialgram"; }
          "Mod+Shift+Q" hotkey-overlay-title="QQ" { spawn "qq"; }
          "Mod+Shift+C" hotkey-overlay-title="VSCode" { spawn "code"; }
          "Mod+Shift+L" hotkey-overlay-title="挂起系统" { spawn-sh "systemctl suspend"; }
          "Mod+M" hotkey-overlay-title="音乐控制" { spawn "foot" "-e" "rmpc"; }
          
          // --- 窗口操作 ---
          "Mod+Q" hotkey-overlay-title="关闭当前窗口" { close-window; }
          "Mod+F" hotkey-overlay-title="最大化列" { maximize-column; }
          "Mod+Shift+F" hotkey-overlay-title="全屏窗口" { fullscreen-window; }
          "Mod+V" hotkey-overlay-title="切换窗口浮动" { toggle-window-floating; }
          "Mod+C" hotkey-overlay-title="居中列" { center-column; }


"Mod+Shift+P" {
        spawn "sh" "-c" "playerctl -p mpv status && playerctl -p mpv stop || nohup mpv --shuffle --no-video --script-opts=mpris-player=mpv /home/lk/D/Music/ > /dev/null 2>&1 &";
    }
// 2. Mod+Shift+Alt+P: 彻底关闭 mpv 后台进程
    Mod+Alt+P { spawn "pkill" "-f" "mpv"; }
    //# === 播放控制 (针对 mpv 实例) ===
    //# -p mpv 参数确保只控制 mpv，而不影响浏览器或其他播放器
    "XF86AudioPlay" { spawn "playerctl" "-p" "mpv" "play-pause"; }
    "Mod+P"         { spawn "playerctl" "-p" "mpv" "play-pause"; }

    "XF86AudioNext" { spawn "playerctl" "-p" "mpv" "next"; }
    "Mod+Period"    { spawn "playerctl" "-p" "mpv" "next"; }

    "XF86AudioPrev" { spawn "playerctl" "-p" "mpv" "previous"; }
    "Mod+Comma"     { spawn "playerctl" "-p" "mpv" "previous"; }

          // --- 焦点与移动 ---
          "Mod+Left" hotkey-overlay-title="左移焦点" { focus-column-left; }
          "Mod+Right" hotkey-overlay-title="右移焦点" { focus-column-right; }
          "Mod+Shift+Left" hotkey-overlay-title="左移列" { move-column-left; }
          "Mod+Shift+Right" hotkey-overlay-title="右移列" { move-column-right; }

          // --- 列宽控制 ---
          "Mod+R" hotkey-overlay-title="切换列宽预设" { switch-preset-column-width; }
          "Mod+Minus" hotkey-overlay-title="缩小列宽" { set-column-width "-10%"; }
          "Mod+Equal" hotkey-overlay-title="增大列宽" { set-column-width "+10%"; }

          // --- 工作区控制 ---
          "Mod+Up" hotkey-overlay-title="上一工作区" { focus-workspace-up; }
          "Mod+Down" hotkey-overlay-title="下一工作区" { focus-workspace-down; }
          
          //  Mod+1~9 快速切换工作区
          "Mod+1" hotkey-overlay-title="切换到工作区 1" { focus-workspace 1; }
          "Mod+2" hotkey-overlay-title="切换到工作区 2" { focus-workspace 2; }
          "Mod+3" hotkey-overlay-title="切换到工作区 3" { focus-workspace 3; }
          "Mod+4" hotkey-overlay-title="切换到工作区 4" { focus-workspace 4; }
          "Mod+5" hotkey-overlay-title="切换到工作区 4" { focus-workspace 5; }
          //  将列移动到上方/下方工作区
          "Mod+Shift+Up" hotkey-overlay-title="移动列到上方工作区" { move-column-to-workspace-up; }
          "Mod+Shift+Down" hotkey-overlay-title="移动列到下方工作区" { move-column-to-workspace-down; }

          //  移动列到指定工作区
          "Mod+Ctrl+1" hotkey-overlay-title="移动列到工作区 1" { move-column-to-workspace 1; }
          "Mod+Ctrl+2" hotkey-overlay-title="移动列到工作区 2" { move-column-to-workspace 2; }

          // --- 交互与媒体键 ---
          "Mod+WheelScrollDown" cooldown-ms=150 hotkey-overlay-title="下一工作区" { focus-workspace-down; }
          "Mod+WheelScrollUp" cooldown-ms=150 hotkey-overlay-title="上一工作区" { focus-workspace-up; }

          "XF86AudioRaiseVolume" allow-when-locked=true hotkey-overlay-title="音量增加" { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
          "XF86AudioLowerVolume" allow-when-locked=true hotkey-overlay-title="音量降低" { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
          "XF86AudioMute" allow-when-locked=true hotkey-overlay-title="静音切换" { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
          "XF86MonBrightnessUp" allow-when-locked=true hotkey-overlay-title="亮度增加" { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
          "XF86MonBrightnessDown" allow-when-locked=true hotkey-overlay-title="亮度降低" { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

          // --- 高级窗口操作 ---
          "Mod+Alt+H" hotkey-overlay-title="向左吞入/排出窗口" { consume-or-expel-window-left; }
          "Mod+Alt+L" hotkey-overlay-title="向右吞入/排出窗口" { consume-or-expel-window-right; }
          "Mod+Tab" hotkey-overlay-title="切换浮动/平铺焦点" { switch-focus-between-floating-and-tiling; }
          "Mod+0" hotkey-overlay-title="打开概览" {  open-overview; }

      }
    '';
  };
}
