{ pkgs, ... }: {
  users.users.lk = {
    isNormalUser = true;
    group = "lk";
    extraGroups = [ "wheel" "video" "input" ];
  };

  users.groups.lk = {};

  security.sudo.extraRules = [
    {
      users = [ "lk" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/tee /sys/class/backlight/amdgpu_bl1/brightness";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
