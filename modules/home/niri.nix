{ pkgs, ... }: # 模块参数
let
  scripts = import ../scripts.nix { inherit pkgs; }; # 脚本模块
  niriBinds = builtins.readFile ./niri-binds.kdl; # 快捷键绑定（独立文件）
in
{
  xdg.configFile."niri/config.kdl" = {
    force = true; # 强制覆盖已有配置
    text = ''
      input { // 输入设备
        keyboard {
          numlock // 默认开启数字小键盘
        }
        touchpad {
          tap // 轻触=点击
          natural-scroll // 自然滚动
        }
      }
      cursor {
        xcursor-size 24 // 光标大小（HiDPI）
      }
      output "eDP-1" { // 内屏
        scale 2.0 // 200% 缩放
        mode "3200x2000@90" // 分辨率@刷新率
      }
      hotkey-overlay {
        skip-at-startup // 启动时不弹快捷键提示
      }
      overview {
        zoom 0.5 // 概览缩放
      }

      // 窗口默认“贴边最大化”打开
      window-rule {
        open-maximized-to-edges false
      }

      window-rule {
        match app-id="code"
        opacity 0.85 // VS Code 半透明
      }
      layer-rule {
        match namespace="^noctalia-wallpaper$"
        place-within-backdrop true // 壁纸置于最底层
      }
      layout {
        background-color "transparent" // 背景透明，透出壁纸
        gaps 6 // 窗口间距，同时也是窗口到屏幕边的外边距（niri 的 inner=outer 共用此值）
	preset-column-widths { // Mod+R 循环切换的预设列宽
          proportion 0.25
          proportion 0.5
          proportion 0.75
        }
        default-column-width {
          proportion 0.5 // 新窗口默认半屏
        }
        focus-ring { // 焦点环
          width 4
          active-color "#a0e8af20"
          inactive-color "#50505020"
        }
        border {
          off // 关闭边框
        }
        shadow { // 窗口阴影
          softness 30
          spread 5
          offset x=0 y=5
          color "#0007"
        }
        struts { // 窗口到屏幕边的额外边距(outer)：0=贴边，想留缝改大；设负值(如 -6)可抵消 gaps 让 maximize-column 也贴边
          left 0
          right 0
          top -5
          bottom -5
        }
      }
      window-rule {
        match is-window-cast-target=false
        geometry-corner-radius 12 // 窗口圆角
        clip-to-geometry true // 内容裁剪到圆角
      }
      layer-rule {
        match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"
        background-effect { // noctalia 面板类背景特效
          xray false
          blur false // 毛玻璃模糊
        }
      }
      switch-events {
        lid-close { // 合盖
          spawn "qs" "-c" "noctalia-shell" "ipc" "call" "sessionMenu" "lockAndSuspend" // 锁屏并挂起
        }
      }
      spawn-at-startup "qs" "-c" "noctalia-shell" // 启动 noctalia shell（bar/dock/壁纸/通知）
      ${niriBinds} // 插入快捷键绑定
    ''; 
  };
}
