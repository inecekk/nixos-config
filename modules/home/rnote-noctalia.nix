# modules/home/apps.nix
# ==========================================
# 独立小应用：rnote 手写笔记 + noctalia 桌面壳层
# ==========================================
{ pkgs, inputs, ... }:
{
  imports = [ inputs.noctalia.homeModules.default ];

  # ---------- rnote ----------
  home.packages = [ pkgs.rnote ];
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

  # ---------- noctalia ----------
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
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
