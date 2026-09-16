# /etc/nixos/modules/packages.nix
{ pkgs, ... }:

{
  environment = {
    sessionVariables.TZ = "Asia/Shanghai";

    # 精简系统默认预装工具（移除 strace, rsync, tcpdump 等）
    defaultPackages = [ ];

    systemPackages = with pkgs; [
      vim
    ];
  };

  # -------------------------------------------------------------
  # 1. 极致精简系统服务与文档构建
  # -------------------------------------------------------------
  documentation.enable = false;                 # 关闭本地手册与文档构建，大幅加快系统 rebuild 速度
  programs.nano.enable = false;                 # 彻底移除默认 nano 编辑器
  services.speechd.enable = false;              # 禁用无障碍语音合成服务
  services.printing.enable = false;             # 禁用 CUPS 打印服务
  systemd.services.ModemManager.enable = false; # 禁用 3G/4G/5G 调制解调器管理
#   hardware.opentabletdriver.enable = false;     # 禁用手绘板/数位板服务
#   boot.swraid.enable = false;                    # 禁用软 RAID 阵列服务

  # 电源管理服务 (适配 Wayland/Niri 与 AMD P-State)
  services.power-profiles-daemon.enable = true;

  # -------------------------------------------------------------
  # 2. GNOME 遗留与桌面 Portal 优化 (完美匹配 Niri/Wayland 桌面环境)
  # -------------------------------------------------------------
  services.gnome.gnome-keyring.enable = false;  # 禁用 GNOME 密钥环
  services.avahi.enable = false;                # 禁用局域网设备自动发现服务 (mDNS)

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk               # 仅保留干净通用的 GTK Portal（处理文件选择等对话框）
    ];
    config = {
      common = {
        default = [ "gtk" ];                    # 默认使用 GTK 处理文件对话框
      };
    };
  };

  # -------------------------------------------------------------
  # 3. 规范 PipeWire 音频服务 (轻量托管)
  # -------------------------------------------------------------
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;                        # 自动模拟 PulseAudio 接口
    jack.enable = false;                        # 禁用非必要的专业音频 JACK 接口
  };

  # -------------------------------------------------------------
  # 4. 字体配置 (高分屏与 Emoji 渲染匹配)
  # -------------------------------------------------------------
  fonts = {
    enableDefaultPackages = false;              # 关闭默认冗余字体集
    packages = with pkgs; [
      jetbrains-mono                            # 核心英文等宽字体
      wqy_microhei                             # 中文字体
      noto-fonts-color-emoji                  # 彩色 Emoji 字体
    ];

    fontconfig = {
      enable = true;
      antialias = true;                         # 开启抗锯齿
      hinting.enable = false;                   # 高分屏关闭 hinting 保持字形平滑
      subpixel.rgba = "none";                   # 高分屏无需子像素渲染

      defaultFonts = {
        monospace = [ "JetBrains Mono" "WenQuanYi Micro Hei Mono" "Noto Color Emoji" ];
        sansSerif = [ "WenQuanYi Micro Hei" "Noto Color Emoji" ];
        serif     = [ "WenQuanYi Micro Hei" "Noto Color Emoji" ];
        emoji     = [ "Noto Color Emoji" ];     # 绑定 noto-fonts-color-emoji 的真实 Font Family
      };
    };
  };
}
