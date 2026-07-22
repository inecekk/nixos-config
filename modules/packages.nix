{ pkgs, ... }:
{
  environment = {
    sessionVariables.TZ = "Asia/Shanghai";
    systemPackages = with pkgs; [
      vim procps psmisc          # 系统维护
      iw pciutils usbutils       # 硬件驱动
      polkit libsecret           # 桌面底层
    ];
  };

  fonts = {
    enableDefaultPackages = false;              # 关闭默认字体集
    packages = with pkgs; [
      sarasa-gothic                              # 更纱黑体（中英等宽严格对齐）
      noto-fonts-color-emoji                     # emoji 彩色符号
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Sarasa Term SC" ];
        emoji = [ "Noto Color Emoji" ];
      };
      antialias = true;                          # 抗锯齿
      hinting.enable = false;                    # 高分屏关闭 hinting 更平滑
      subpixel.rgba = "none";                    # 高分屏无需子像素渲染
    };
  };

  services.upower.enable = true;   # Noctalia 电量显示依赖
  programs.niri.enable = true;
}
