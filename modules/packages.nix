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
    enableDefaultPackages = false;               # 关闭默认字体集
    packages = with pkgs; [ source-han-sans ];    # 思源黑体（简体）
    fontconfig.defaultFonts = {
      serif = [ "Source Han Sans SC" ];
      sansSerif = [ "Source Han Sans SC" ];
      monospace = [ "Source Han Sans SC" ];
    };
    fontconfig.antialias = true;                  # 抗锯齿
    fontconfig.hinting.enable = false;            # 高分屏关闭 hinting 更平滑
    fontconfig.subpixel.rgba = "none";            # 高分屏无需子像素渲染
  };

  services.upower.enable = true;   # Noctalia 电量显示依赖
  programs.niri.enable = true;
}
