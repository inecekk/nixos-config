{ pkgs, ... }:
{
  environment = {
    # 全局环境变量：仅系统级基础设置
    sessionVariables = {
      TZ = "Asia/Shanghai";
    };

    systemPackages = with pkgs; [
      # --- 系统维护与基础（vim 留在系统层，当救急编辑器） ---
      neovim
      procps
      psmisc

      # --- 硬件与驱动 ---
      iw
      pciutils
      usbutils

      # --- 桌面环境底层 ---
      polkit
      libsecret
    ];
  };
  # 启用 UPower 硬件服务（Noctalia 电量必需）
  services.upower.enable = true;
  programs.niri.enable = true;
}
