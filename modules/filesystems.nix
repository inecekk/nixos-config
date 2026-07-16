# modules/filesystems.nix
{ ... }:

{

        fileSystems = {
        "/home/lk/C" = {
        device = "/dev/disk/by-uuid/752A6785456870B8";
        fsType = "ntfs3";
        options = [ "rw" "uid=1000" "gid=1000" "dmask=022" "fmask=022" "nofail" "x-systemd.device-timeout=3" ];
        };

        "/home/lk/D" = {
        device = "/dev/disk/by-uuid/4A9ED0D09ED0B5A3";
        fsType = "ntfs3";
        options = [ "rw" "uid=1000" "gid=1000" "dmask=0000" "fmask=0000" "force" "nofail" "x-systemd.device-timeout=3" ];
        };
        "/" = {
        device = "/dev/disk/by-uuid/2a2a478e-b03b-4e18-b1be-a37190168ca2";
        fsType = "btrfs";
        options = [ "compress=zstd:5" ];
        };
        "/boot" = {
        device = "/dev/disk/by-uuid/7CB8-A11A";
        fsType = "vfat";
        };
        };
}
