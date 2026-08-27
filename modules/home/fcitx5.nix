{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fcitx5 
    qt6Packages.fcitx5-configtool
    qt6Packages.fcitx5-chinese-addons

  ];

/*
  xdg.configFile."fcitx5/conf/pinyin.conf" = {
    force = true;
    text = ''
      ShuangpinProfile=Flypy
      TraditionalChinese=False
    '';
  };

  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
      [GroupOrder]
      0=Default

      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=shuangpin

      [Groups/0/Items/0]
      Name=keyboard-us

      [Groups/0/Items/1]
      Name=shuangpin

      [GroupList]
      0=Default
    '';
  };
*/
  home.sessionVariables = {
    GTK_IM_MODULE  = "fcitx";
    QT_IM_MODULE   = "fcitx";
    XMODIFIERS     = "@im=fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
