{ pkgs, ... }:

{
  environment = {
    # 全局环境变量：仅限底层系统行为，输入法变量建议移至 home-manager
    sessionVariables = {
      TZ = "Asia/Shanghai";
   # Electron 应用（如 QQ、VS Code、Discord）强制使用 Wayland
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    
    # Qt 应用（如 KDE 软件、部分工具）强制使用 Wayland
    QT_QPA_PLATFORM = "wayland";
    
    # GTK 应用（如 GNOME 软件、部分工具）强制使用 Wayland
    GDK_BACKEND = "wayland";
    
    # SDL2 应用（常见于游戏和模拟器）强制使用 Wayland
    SDL_VIDEODRIVER = "wayland";
    };

    systemPackages = with pkgs; [
      # --- 系统维护与基础 ---
      wget git vim gnused procps psmisc tree

      # --- 硬件与驱动 ---
      iw pciutils usbutils

      # --- 桌面环境底层 ---
      niri  
# xwayland
  polkit  libsecret
    ];
  };
}
