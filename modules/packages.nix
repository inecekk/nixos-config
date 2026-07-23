{ pkgs, ... }:
{
  environment = {
    sessionVariables.TZ = "Asia/Shanghai";

    # 精简系统默认软件（移除 strace, rsync, tcpdump 等系统默认预装的维护/诊断工具）
    defaultPackages = [ ];

    systemPackages = with pkgs; [
      vim procps psmisc         # 系统维护
      iw pciutils usbutils       # 硬件驱动
      polkit libsecret           # 桌面底层
    ];
  };

  # 1. 禁用语音合成服务
  services.speechd.enable = false;

  # 2. 禁用 ModemManager（调制解调器管理）
  systemd.services.ModemManager.enable = false;
 # 3. 字体配置
  fonts = {
    enableDefaultPackages = false;               # 关闭默认字体集
    packages = with pkgs; [
      jetbrains-mono                            # 核心英文等宽字体
      wqy_microhei                              # 中文字体
      openmoji-color                            # Emoji 字体
    ];

    fontconfig = {
      enable = true;
      antialias = true;                         # 抗锯齿
      hinting.enable = false;                   # 高分屏关闭 hinting 更平滑
      subpixel.rgba = "none";                   # 高分屏无需子像素渲染

      defaultFonts = {
        monospace = [ "JetBrains Mono" "WenQuanYi Micro Hei Mono" ];
        sansSerif = [ "WenQuanYi Micro Hei" ];
        serif     = [ "WenQuanYi Micro Hei" ];
        emoji     = [ "OpenMoji Color" "OpenMoji" ];
      };
    };
  };
# 4. 其他服务与程序配置
  services.upower.enable = true;   # Noctalia 电量显示依赖
  programs.niri.enable = true;
}
