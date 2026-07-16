# modules/users.nix
# ==========================================
# 系统用户账户配置
# ==========================================
{ ... }:

{
        users.users.lk = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "bluetooth" "storage" "disk" "video" "input" "mpd" ];
        };
}
