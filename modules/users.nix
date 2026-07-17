# modules/users.nix
# ==========================================
# 系统用户账户配置
# ==========================================
{pkgs, ... }:

{
        users.users.lk = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "bluetooth" "storage" "disk" "video" "input" "mpd" ];
	#shell = pkgs.fish;
        };
#users.defaultUserShell = pkgs.fish;        

}

