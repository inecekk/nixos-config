{ ... }:

{
  nix = {
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass = "best-effort";
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      builders-use-substitutes = true;
      max-jobs = 1;
      cores = 4;
      connect-timeout = 5;
      fallback = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
