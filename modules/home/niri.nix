{ config, pkgs, inputs, ... }:
{
  imports = [ 
    inputs.noctalia.homeModules.default 
  ];

  # 1. 独立小应用包
  home.packages = [
    pkgs.rnote
  ];

  # 2. rnote 配置文件生成
  home.file.".config/rnote/config.toml" = {
    text = ''
      [page]
      width = 20.0
      height = 80.0
      unit = "cm"
      dpi = 96
      orientation = "portrait"
      [document]
      layout = "fixed"
      show_grid = false
      background_color = "#FFFFFF"
      [document.texture]
      type = "line"
      color = "#FF8C00"
      width = 32
      height = 60
    '';
  };

  # 3. 配置文件软链接
  xdg.configFile."niri" = {
    source = ./configs/niri;
    recursive = true;
  };

  # 4. noctalia 桌面壳层配置
  programs.noctalia = {
    enable = true;
    systemd.enable = false;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
      wallpaper = {
        enabled = true;
        mode = "fill";
      };
      screenshot = {
        directory = "/home/lk/Pictures/Screenshots";
      };
    };
  };
}
