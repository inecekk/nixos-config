{ pkgs, ... }:

{
  environment = {
    sessionVariables.TZ = "Asia/Shanghai";

    # 精简系统默认软件（移除 strace, rsync, tcpdump 等系统默认预装工具）
    defaultPackages = [ ];

    systemPackages = with pkgs; [
      vim
      procps
      psmisc      # 系统进程维护
      pciutils
      usbutils    # 硬件/总线查看工具
      polkit
      libsecret   # 桌面密钥存储底层
      # 剔除了 iw（无线管理留给 iwd/iwctl 即可）
    ];
  };

  # -------------------------------------------------------------
  # 1. 精简系统与默认工具禁用
  # -------------------------------------------------------------
  programs.nano.enable = false;                 # 彻底移除默认的 nano 编辑器
  services.speechd.enable = false;              # 禁用语音合成服务
  systemd.services.ModemManager.enable = false; # 禁用调制解调器管理
  hardware.opentabletdriver.enable = false;     # 禁用手绘板/数位板服务

  # -------------------------------------------------------------
  # 2. GNOME 遗留与桌面 Portal 优化 (适合 Niri 环境)
  # -------------------------------------------------------------
  services.gnome.gnome-keyring.enable = false;  # 禁用不需要的 GNOME 密钥环

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk               # 仅保留干净通用的 GTK Portal 后端
    ];
    config.common.default = [ "gtk" ];
  };

  # -------------------------------------------------------------
  # 3. 规范 PipeWire 音频服务 (托管 PulseAudio / JACK 接口)
  # -------------------------------------------------------------
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;                       # 自动模拟 PulseAudio 接口，无需实装 pulseaudio
    jack.enable = true;                        # 自动模拟 JACK 接口
  };

  # -------------------------------------------------------------
  # 4. 字体配置 (针对高分屏渲染优化)
  # -------------------------------------------------------------
  fonts = {
    enableDefaultPackages = false;              # 关闭默认冗余字体集
    packages = with pkgs; [
      jetbrains-mono                            # 核心英文等宽字体
      wqy_microhei                              # 中文字体
      openmoji-color                            # Emoji 字体
    ];

    fontconfig = {
      enable = true;
      antialias = true;                         # 开启抗锯齿
      hinting.enable = false;                   # 高分屏关闭 hinting 保持字形平滑
      subpixel.rgba = "none";                   # 高分屏无需子像素渲染

      defaultFonts = {
        monospace = [ "JetBrains Mono" "WenQuanYi Micro Hei Mono" ];
        sansSerif = [ "WenQuanYi Micro Hei" ];
        serif = [ "WenQuanYi Micro Hei" ];
        emoji = [ "OpenMoji Color" "OpenMoji" ];
      };
    };
  };
}
