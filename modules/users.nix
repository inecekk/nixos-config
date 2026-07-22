# modules/users.nix
# ==========================================
# 系统用户账户配置
# ==========================================
{ pkgs, ... }:

{
  users.users.lk = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "bluetooth"
      "storage"
      "disk"
      "video"
      "input"
      "mpd"
    ];
    #shell = pkgs.fish;
  };

  system.userActivationScripts.userDirsInit.text = ''
    mkdir -p ~/C ~/D ~/Pictures/Screenshots ~/Music ~/D/Music ~/D/Pictures/Wallpaper/WallhavenDesktop
    chown -R lk:users ~/C ~/D ~/Pictures ~/Music ~/D/Music ~/D/Pictures
  '';
}
