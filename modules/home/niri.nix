{ pkgs, ... }:
let
  scripts = import ../scripts.nix { inherit pkgs; };
  niriBinds = builtins.readFile ./niri-binds.kdl;
in
{
  # Nix 层面的配置：使用 # 作为注释
  xdg.configFile."niri/config.kdl" = {
    force = true;
    text = ''
      input {
        keyboard {
          numlock         // 开机自动开启数字锁定键
        }
        touchpad {
          tap         // 触控板轻触即点击
          natural-scroll         // 自然滚动方向
        }
      }
      cursor {
        xcursor-size 24         // 光标大小
      }
      output "eDP-1" {
        scale 2.0         // 内置屏幕缩放 2 倍（高分屏）
      }
      hotkey-overlay {
        skip-at-startup         // 跳过启动时的快捷键提示
      }
      window-rule {
        match app-id="code"         // 匹配 VS Code 窗口
        opacity 0.85         // 设为 85% 不透明度
      }
      layout {
        gaps 16         // 窗口间距 16 像素
        preset-column-widths {
          proportion 0.25         // 预设列宽 25%
          proportion 0.5         // 预设列宽 50%
          proportion 0.75         // 预设列宽 75%
        }
        default-column-width {
          proportion 0.5         // 新窗口默认宽度 50%
        }
        focus-ring {
          width 4         // 焦点边框宽度 4px
          active-color "#a0e8af20"         // 有焦点时颜色（浅绿半透明）
          inactive-color "#50505020"         // 无焦点时颜色（灰色半透明）
        }
        border {
          off         // 关闭普通边框，只留 focus-ring
        }
        shadow {
          softness 30         // 阴影柔和度
          spread 5         // 阴影扩散范围
          offset x=0 y=5         // 阴影偏移：向下 5px
          color "#0007"         // 阴影颜色（黑色半透明）
        }
        struts {         // 应用边距
          left 1
          right 1
          top 1
          bottom 0
        }
      }
      window-rule {
        geometry-corner-radius 12         // 全局窗口圆角半径 12px
        clip-to-geometry true         // 内容裁切到圆角边界内
      }
      layer-rule {
        match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"         // 匹配 Noctalia 图层
        background-effect {
          xray false         // 关闭透视效果
          blur false         // 关闭背景模糊
        }
      }
      spawn-at-startup "qs" "-c" "noctalia-shell"         // 开机启动 Noctalia 状态栏
      ${niriBinds}         // 引入分离的快捷键配置文件
    '';
  };
}
