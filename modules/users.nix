{ pkgs, ... }: {
  users.users.lk = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" ];
  };

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
