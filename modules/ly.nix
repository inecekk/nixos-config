{ pkgs, lib, ... }:
{
  services.displayManager.ly.enable = lib.mkForce true;

  services.displayManager.defaultSession = "niri";


  services.displayManager.ly.settings = {
    bg = "#1e1e2e";
    fg = "#cdd6f4";
    border_fg = "#89b4fa";
    banner = ''
      \x1b[38;2;137;180;250m██╗   ██╗\x1b[0m
      \x1b[38;2;166;227;236m██║   ██║\x1b[0m
      \x1b[38;2;198;208;245m██║   ██║\x1b[0m
      \x1b[38;2;243;139;168m██╗ ██╔╝\x1b[0m
      \x1b[38;2;249;226;175m ╚████╔╝\x1b[0m
      \x1b[38;2;137;180;250m  ╚═══╝ \x1b[0m
    '';
    animate = false;
  };

}
