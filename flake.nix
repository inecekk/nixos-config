{
  description = "lk 的 NixOS + Niri + Noctalia 配置";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    daeuniverse = {
      url = "github:daeuniverse/flake.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      collectModules = dir:
        let
          entries = builtins.readDir dir;
        in
          lib.flatten (lib.mapAttrsToList (name: type:
            let path = dir + "/${name}";
            in
              if path == ./modules/home then []
              else if type == "directory" then collectModules path
              else if lib.hasSuffix ".nix" name
                && name != "scripts.nix"
                && !(lib.hasSuffix ".nix.bak" name)
              then [ path ]
              else []
          ) entries);

      autoModules = collectModules ./modules;
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs; };

        modules = [
          ./hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ] ++ autoModules ++ [
          ./modules/home/default.nix
        ];
      };
    };
}
