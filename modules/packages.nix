{ pkgs, ... }:
{
  environment = {
    sessionVariables.TZ = "Asia/Shanghai";

    # 精简系统默认软件（移除 strace, rsync, tcpdump 等系统默认预装的维护/诊断工具）
    defaultPackages = [ ];

    systemPackages = with pkgs; [
      vim procps psmisc          # 系统维护
      iw pciutils usbutils       # 硬件驱动
      polkit libsecret           # 桌面底层
    ];
  };

  # 1. 禁用语音合成服务
  services.speechd.enable = false;

  # 2. 禁用 ModemManager（调制解调器管理）
  systemd.services.ModemManager.enable = false;

  fonts = {
    enableDefaultPackages = false;              # 关闭默认字体集
    packages = with pkgs; [
      sarasa-gothic                              # 更纱黑体（中英等宽严格对齐）
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Sarasa Term SC" ];
      };
      antialias = true;                          # 抗锯齿
      hinting.enable = false;                    # 高分屏关闭 hinting 更平滑
      subpixel.rgba = "none";                    # 高分屏无需子像素渲染
    };
  };

  services.upower.enable = true;   # Noctalia 电量显示依赖
  programs.niri.enable = true;
}
