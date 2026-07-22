{ pkgs, ... }:
{
  environment = {
    sessionVariables = {
      TZ = "Asia/Shanghai";
    };

    systemPackages = with pkgs; [
      vim
      procps
      psmisc
      iw
      pciutils
      usbutils
      polkit
      libsecret
    ];
  };

  # --- 字体：仅中文（文泉驿正黑），英文靠 WQY 自带西文字形 ---
  fonts = {
    enableDefaultPackages = false;

    packages = with pkgs; [
      wqy_zenhei
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "WenQuanYi Zen Hei" ];
        sansSerif = [ "WenQuanYi Zen Hei" ];
        monospace = [ "WenQuanYi Zen Hei Mono" ];
      };
    };
  };

  services.upower.enable = true;
  programs.niri.enable = true;
}
