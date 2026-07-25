{pkgs, ...}:
let
  scripts = import ../scripts.nix {inherit pkgs;}; # 脚本模块
  niriBinds = builtins.readFile ./niri-binds.kdl; # 快捷键绑定（独立文件）
in {
  xdg.configFile."niri/config.kdl" = {
    force = true; # 强制覆盖已有配置
    text = ''
      input { // 输入设备
        keyboard {
          // numlock // 默认开启数字小键盘
        }
        touchpad {
          tap // 轻触=点击
          natural-scroll // 自然滚动
        }
      }

      cursor {
        xcursor-size 32 // 4K 高分屏建议设为 32，光标更清晰
      }

      output "eDP-1" { // 16寸 4K 内屏
        scale 2.0 // 200% 缩放（逻辑分辨率 1920x1200，视觉极为精致）
        // mode "3840x2400@90" // 视具体面板刷新率决定是否解除注释
      }

      hotkey-overlay {
        skip-at-startup // 启动时不弹快捷键提示
      }

      overview {
        zoom 0.5 // 概览缩放
      }

      // ==================== 动画与自定义 Shader 配置 ====================
      animations {
        workspace-switch {
          spring damping-ratio=0.75 stiffness=500 epsilon=0.0001
        }
        horizontal-view-movement {
          spring damping-ratio=0.75 stiffness=500 epsilon=0.0001
        }
        window-movement {
          spring damping-ratio=0.75 stiffness=500 epsilon=0.0001
        }
        window-resize {
          spring damping-ratio=0.75 stiffness=500 epsilon=0.0001
        }
        config-notification-open-close {
          spring damping-ratio=0.5 stiffness=500 epsilon=0.0001
        }
        exit-confirmation-open-close {
          spring damping-ratio=0.5 stiffness=500 epsilon=0.0001
        }
        screenshot-ui-open {
          spring damping-ratio=0.75 stiffness=500 epsilon=0.0001
        }
        overview-open-close {
          spring damping-ratio=0.75 stiffness=500 epsilon=0.0001
        }

        // 窗口关闭：自由落体 + 随机倾斜
        window-close {
          duration-ms 500
          curve "linear"
          custom-shader "vec4 fall_and_rotate(vec3 coords_geo, vec3 size_geo) {
                  // === 适配 4K 屏可调参数 ===
                  float fall_distance = 1500.0;       // 下落距离 (4K 逻辑高度约 1200px，设 1500px 保证完全出屏)
                  float rotation_amplitude = 0.5;     // 旋转幅度系数
                  float fade_speed = 1.8;             // 淡出速度
                  float progress_curve = 2.0;         // 进度曲线指数 (2.0 为二次加速)
                  // === 可调参数结束 ===

                  float progress = pow(niri_clamped_progress, progress_curve);
                  vec2 coords = (coords_geo.xy - vec2(0.5, 1.0)) * size_geo.xy;

                  // 垂直下落
                  coords.y -= progress * fall_distance;

                  // 随机旋转
                  float random = (niri_random_seed - 0.5) / 2.0;
                  random = sign(random) - random;
                  float max_angle = rotation_amplitude * random;
                  float angle = progress * max_angle;

                  mat2 rotate = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
                  coords = rotate * coords;

                  coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 1.0), 1.0);
                  vec3 coords_tex = niri_geo_to_tex * coords_geo;
                  vec4 color = texture2D(niri_tex, coords_tex.st);

                  // 淡出效果
                  color.a *= (1.0 - progress * fade_speed);
                  color.a = max(color.a, 0.0);

                  return color;
              }
              vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                  return fall_and_rotate(coords_geo, size_geo);
              }"
        }

        // 窗口打开：顶部坠落 + 悬挂摆动
        window-open {
          duration-ms 500
          curve "linear"
          custom-shader "vec4 fall_from_top(vec3 coords_geo, vec3 size_geo) {
              // === 适配 4K 屏可调参数 ===
              float overshoot_strength = 1.25;     // 曲线超出幅度
              float bounce_amplitude = 0.15;       // 旋转回弹幅度
              float bounce_frequency = 1.0;        // 震荡次数
              float max_rotation = 0.5;            // 最大旋转角
              float fall_distance = 1500.0;        // 下落距离
              // === 可调参数结束 ===

              float c1 = overshoot_strength * 0.85;
              float c3 = c1 + 1.0;
              float progress = 1.0 + c3 * pow(niri_clamped_progress - 1.0, 3.0) + c1 * pow(niri_clamped_progress - 1.0, 2.0);

              vec2 coords = (coords_geo.xy - vec2(0.5, 0.0)) * size_geo.xy;
              coords.y += (1.0 - progress) * fall_distance;

              float angle_factor = 1.0 - progress;
              float overshoot = 1.0 + bounce_amplitude * sin(progress * 3.14159 * bounce_frequency) * (1.0 - progress);
              float angle = angle_factor * max_rotation * overshoot;

              mat2 rotate = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
              coords = rotate * coords;
              coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 0.0), 1.0);
              vec3 coords_tex = niri_geo_to_tex * coords_geo;
              return texture2D(niri_tex, coords_tex.st);
          }
          vec4 open_color(vec3 coords_geo, vec3 size_geo) {
              return fall_from_top(coords_geo, size_geo);
          }"
        }
      }

      // 窗口默认“贴边最大化”打开
      window-rule {
        open-maximized-to-edges false
      }

      window-rule {
        match app-id="code"
        opacity 0.9 // VS Code 半透明
      }

      layer-rule {
        match namespace="^noctalia-wallpaper$"
        place-within-backdrop true // 壁纸置于最底层
      }

      layout {
        background-color "transparent" // 背景透明，透出壁纸
        gaps 8 // 4K 屏微调为 8px，视觉比例更均衡
        preset-column-widths { // Mod+R 循环切换预设列宽
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
        shadow { // 窗口阴影（微调以适配 4K 高分辨率精细度）
          softness 35
          spread 6
          offset x=0 y=6
          color "#0007"
        }
        struts { // 窗口到屏幕边的额外边距(outer)
          left 0
          right 0
          top -5
          bottom -7
        }
      }

      window-rule {
        match is-window-cast-target=false
        draw-border-with-background false // 移除背景框
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

      spawn-at-startup "qs" "-c" "noctalia-shell" // 启动 noctalia shell
      ${niriBinds} // 插入快捷键绑定
    '';
  };
}
