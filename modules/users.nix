# modules/users.nix
# ==========================================
# 系统用户账户配置
# ==========================================
{ congfig,pkgs,... }:

{

  programs.fish.enable = true;
  users.users.lk = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "bluetooth" "storage" "disk" "video" "input" "mpd" ];
   shell = pkgs.fish;
  };
}
