# modules/home/noctalia.nix
# =================================================================================
# [Noctalia 完整配置模块]
# 整合自 dotfiles 配置，适配单显示器 eDP-1
# =================================================================================
{ pkgs, config, ... }:

let
  userHome = config.home.homeDirectory or "/home/lk";
in
{
  # ==========================================
  # Noctalia 配置文件
  # ==========================================
  xdg.configFile."noctalia/noctalia-config.toml" = {
    force = true;
    text = ''
      # ==========================================
      # Noctalia 完整配置
      # 适配单显示器 eDP-1 (3200x2000 @ 2.0 缩放)
      # ==========================================

      # ==========================================
      # 音频设置
      # ==========================================
      [audio]
      enable_overdrive = true

      # ==========================================
      # 背景设置
      # ==========================================
      [backdrop]
      blur_intensity = 0.69
      tint_intensity = 0.0

      # ==========================================
      # 顶部栏配置
      # ==========================================
      [bar]
      order = [ "bar" ]

          [bar.bar]
          background_opacity = 0.0
          border_width = 0.0
          capsule = true
          capsule_border = "outline"
          capsule_foreground = "secondary"
          capsule_opacity = 0.79
          capsule_padding = 10.0
          capsule_radius = 80
          capsule_thickness = 0.96
          enabled = true
          end = [ "media", "tray", "wallpaper", "volume", "notifications", "session" ]
          font_family = "JetBrains Mono"
          margin_ends = 14
          scale = 1.1
          shadow = false
          start = [ "launcher", "workspaces", "active_window" ]
          thickness = 36

          # 只启用 eDP-1 显示器
          [bar.bar.monitor.eDP-1]
          enabled = true

      # ==========================================
      # 电池设置
      # ==========================================
      [battery.device."/org/freedesktop/UPower/devices/battery_hidpp_battery_0"]
      warning_threshold = 30

      # ==========================================
      # 亮度控制（使用 ddcutil，仅外接显示器）
      # ==========================================
      [brightness]
      enable_ddcutil = true

      # ==========================================
      # 桌面小部件（音频可视化）
      # ==========================================
      [desktop_widgets]
      schema_version = 2
      widget_order = [ "desktop-widget-0000000000000003" ]

          [desktop_widgets.grid]
          cell_size = 16
          major_interval = 4
          visible = true

          # 音频可视化小部件 - 适配 eDP-1
          [desktop_widgets.widget.desktop-widget-0000000000000003]
          box_height = 0.0
          box_width = 0.0
          cx = 1600.0    # 屏幕中心 (3200/2)
          cy = 1000.0    # 屏幕中心 (2000/2)
          output = "eDP-1"
          rotation = 0.0
          type = "fancy_audio_visualizer"

              [desktop_widgets.widget.desktop-widget-0000000000000003.settings]
              background = false
              visualization_mode = "wave_rings"

      # ==========================================
      # Dock 设置
      # ==========================================
      [dock]
      auto_hide = true
      enabled = true
      radius = 20
      reserve_space = false
      show_dots = true

      # ==========================================
      # 主题同步钩子
      # ==========================================
      [hooks]
      theme_mode_changed = [ "${userHome}/.config/noctalia/theme-sync.sh" ]

      # ==========================================
      # 热角设置（右下角 -> 窗口切换器）
      # ==========================================
      [hot_corners.bottom_right]
      action = "window_switcher"

      # ==========================================
      # 位置信息
      # ==========================================
      [location]
      address = "重庆,中国"

      # ==========================================
      # 锁屏小部件（仅 eDP-1）
      # ==========================================
      [lockscreen_widgets]
      enabled = false
      schema_version = 2
      widget_order = [ "lockscreen-login-box@eDP-1" ]

          [lockscreen_widgets.grid]
          cell_size = 16
          major_interval = 4
          visible = true

          # 锁屏登录框 - 适配 eDP-1
          [lockscreen_widgets.widget."lockscreen-login-box@eDP-1"]
          box_height = 70.0
          box_width = 400.0
          cx = 1600.0    # 屏幕中心 (3200/2)
          cy = 1000.0    # 屏幕中心 (2000/2)
          output = "eDP-1"
          rotation = 0.0
          type = "login_box"

              [lockscreen_widgets.widget."lockscreen-login-box@eDP-1".settings]
              background_color = "surface_variant"
              background_opacity = 0.88
              background_radius = 12.0
              input_opacity = 1.0
              input_radius = 6.0
              show_caps_lock = true
              show_keyboard_layout = true
              show_login_button = true
              show_password_hint = true

      # ==========================================
      # 夜间模式设置
      # ==========================================
      [nightlight]
      temperature_day = 10000
      temperature_night = 8900

      # ==========================================
      # OSD 显示设置
      # ==========================================
      [osd]
      background_opacity = 0.85
      offset_y = 20
      position = "bottom_center"
      scale = 0.9

          [osd.kinds]
          media = false

      # ==========================================
      # Shell 设置
      # ==========================================
      [shell]
      font_family = "Noto Sans CJK SC"
      settings_show_advanced = true
      ui_scale = 1.2

          [shell.panel]
          control_center_placement = "floating"
          control_center_position = "top_right"
          transparency_mode = "soft"
          wallpaper_placement = "floating"
          wallpaper_position = "center"

          # 会话操作
          [[shell.session.actions]]
          action = "lock"
          countdown_seconds = 0.0
          enabled = true
          shortcut = "1"
          variant = "default"

          [[shell.session.actions]]
          action = "logout"
          countdown_seconds = 0.0
          enabled = true
          shortcut = "2"
          variant = "default"

          [[shell.session.actions]]
          action = "lock_and_suspend"
          countdown_seconds = 0.0
          enabled = true
          shortcut = "3"
          variant = "default"

          [[shell.session.actions]]
          action = "reboot"
          countdown_seconds = 0.0
          enabled = true
          shortcut = "4"
          variant = "default"

          [[shell.session.actions]]
          action = "shutdown"
          countdown_seconds = 0.0
          enabled = true
          shortcut = "5"
          variant = "destructive"

          [[shell.session.actions]]
          action = "command"
          command = "notify-send 'Noctalia' '自定义命令'"
          countdown_seconds = 0.0
          enabled = false
          variant = "default"

      # ==========================================
      # 主题设置
      # ==========================================
      [theme]
      builtin = "Ayu"
      community_palette = "One Dark Two"
      mode = "dark"
      source = "wallpaper"
      wallpaper_scheme = "m3-content"

          [theme.templates]
          builtin_ids = [ "kitty", "qt", "starship" ]
          community_ids = [ "zen-browser" ]

      # ==========================================
      # 壁纸设置（适配 eDP-1）
      # ==========================================
      [wallpaper]
      directory = "${userHome}/图片/wallpapers"

          [wallpaper.default]
          path = "${userHome}/图片/wallpapers/wallhaven-w5126q.jpg"

          [wallpaper.last]
          path = "${userHome}/图片/wallpapers/wallhaven-w5126q.jpg"

          # 仅 eDP-1 显示器
          [wallpaper.monitors.eDP-1]
          path = "${userHome}/图片/wallpapers/wallhaven-w5126q.jpg"

          # 收藏壁纸
          [[wallpaper.favorite]]
          palette_source = "wallpaper"
          path = "${userHome}/图片/wallpapers/wallhaven-qrlqw7.png"
          theme_mode = "dark"
          wallpaper_scheme = "m3-content"

          [[wallpaper.favorite]]
          path = "${userHome}/图片/wallpapers/【哲风壁纸】傍晚-冷色调-富士山.png"
          theme_mode = "auto"

          [[wallpaper.favorite]]
          palette_source = "wallpaper"
          path = "${userHome}/图片/wallpapers/3291689053_ezgif-frame-001_waifu2x_4x_3n_png.png"
          theme_mode = "dark"
          wallpaper_scheme = "m3-content"

      # ==========================================
      # 小部件设置
      # ==========================================
      [widget.active_window]
      min_length = 0

      [widget.clock]
      format = "{:%a, %d %b %H:%M}"

      [widget.tray]
      detached_panel = true
      drawer = true
    '';
  };

  # ==========================================
  # 主题同步脚本
  # ==========================================
  xdg.configFile."noctalia/theme-sync.sh" = {
    force = true;
    executable = true;
    text = ''
      #!/bin/bash
      # ==========================================
      # Noctalia 主题同步脚本
      # ==========================================

      # 获取当前主题模式
      THEME_MODE="''${NOCTALIA_THEME_MODE}"
      if [ -z "$THEME_MODE" ]; then
          THEME_MODE=$(noctalia msg theme-mode-get 2>/dev/null || echo "dark")
      fi

      echo "正在同步主题模式: $THEME_MODE"

      # 安全更新 INI 文件的函数
      update_ini() {
          local file="$1"
          local key="$2"
          local val="$3"
          
          if [ ! -f "$file" ]; then
              return
          fi
          
          if grep -q "^''${key}=" "$file"; then
              sed -i "s|^''${key}=.*|''${key}=''${val}|" "$file"
          else
              if grep -q "^\[Settings\]" "$file"; then
                  sed -i "/^\[Settings\]/a ''${key}=''${val}" "$file"
              else
                  echo "''${key}=''${val}" >> "$file"
              fi
          fi
      }

      if [ "$THEME_MODE" = "light" ]; then
          # 浅色模式
          gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
          gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
          
          update_ini "$HOME/.config/gtk-3.0/settings.ini" "gtk-application-prefer-dark-theme" "false"
          update_ini "$HOME/.config/gtk-3.0/settings.ini" "gtk-theme-name" "adw-gtk3"
          
          update_ini "$HOME/.config/gtk-4.0/settings.ini" "gtk-application-prefer-dark-theme" "false"
      else
          # 深色模式
          gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
          gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
          
          update_ini "$HOME/.config/gtk-3.0/settings.ini" "gtk-application-prefer-dark-theme" "true"
          update_ini "$HOME/.config/gtk-3.0/settings.ini" "gtk-theme-name" "adw-gtk3-dark"
          
          update_ini "$HOME/.config/gtk-4.0/settings.ini" "gtk-application-prefer-dark-theme" "true"
      fi
    '';
  };
}
