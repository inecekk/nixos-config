{ pkgs,lib, ... }:
{

 services.displayManager.ly.enable = lib.mkForce true;
  # Ly 个性化设置 (Catppuccin Mocha + ASCII Art)
  services.displayManager.ly.settings = {
    bg = "#1e1e2e";          # 背景色
    fg = "#cdd6f4";          # 文字颜色
    border_fg = "#89b4fa";   # 边框颜色
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

  programs.niri.enable = true;

  environment.shellInit = ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec ${pkgs.niri}/bin/niri-session 2>/dev/null || true
    fi
  '';
}
