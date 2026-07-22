{ pkgs, ... }:
{
  environment = {
    sessionVariables.TZ = "Asia/Shanghai";
    systemPackages = with pkgs; [
      vim procps psmisc
      iw pciutils usbutils
      polkit libsecret
    ];
  };

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      jetbrains-mono
      wqy_zenhei
      noto-fonts-color-emoji
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrains Mono" "WenQuanYi Zen Hei Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
      antialias = true;
      hinting.enable = false;
      subpixel.rgba = "none";
    };
  };

  services.upower.enable = true;
  programs.niri.enable = true;
}
