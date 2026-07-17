# modules/activation.nix
# ==========================================
# 用户目录初始化脚本
# 系统每次激活（切换 generation）时自动创建必要目录并修正属主
# ==========================================
{ ... }:

{
  system.userActivationScripts.userDirsInit.text = ''
    mkdir -p ~/C ~/D ~/Pictures/Screenshots ~/Music ~/D/Music ~/D/Pictures/Wallpaper/WallhavenDesktop
    chown -R lk:users ~/C ~/D ~/Pictures ~/Music ~/D/Music ~/D/Pictures
  '';
}
