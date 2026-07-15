# modules/locale.nix
# ==========================================
# 本地化（中文环境）与字体配置
# ==========================================
{ pkgs, ... }:

{
  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        fcitx5-rime
        rime-ice
        qt6Packages.fcitx5-chinese-addons
        qt6Packages.fcitx5-configtool
      ];
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      source-han-sans
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      font-awesome
      twemoji-color-font
      noto-fonts-color-emoji
      symbola
      unifont
      material-design-icons
      papirus-icon-theme
    ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans CJK SC" "JetBrains Mono Nerd Font" "Twemoji Color Font" ];
        serif = [ "Noto Serif CJK SC" "Symbola" ];
        monospace = [ "JetBrains Mono Nerd Font" "Noto Sans CJK SC" ];
        emoji = [ "Twemoji Color Font" "Noto Color Emoji" ];
      };
      antialias = true;
      hinting = { enable = true; style = "slight"; };
      subpixel = { rgba = "rgb"; lcdfilter = "default"; };
    };
  };
}
