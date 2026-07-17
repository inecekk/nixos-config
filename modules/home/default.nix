{ inputs, lib, ... }:

let
  homeDir = ./.;

  autoImports = builtins.map (name: homeDir + "/${name}") (
    builtins.attrNames (
      lib.filterAttrs (
        name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
      ) (builtins.readDir homeDir)
    )
  );
in
{
  home-manager.users.lk = { pkgs, ... }: {

    imports = autoImports;

    home.stateVersion = "26.11";

    home.packages = with pkgs; [
      git
      gnused
      tree
      wget
      foot
      bluetui
      btop
      fish
      zsh
      yazi
      p7zip-rar
      imagemagick
      grim
      slurp
      wl-clipboard
      wf-recorder
      libnotify
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      qq
      materialgram
      rmpc
      go-musicfox
      vscode
      rnote
      opentabletdriver
    ];

    home.sessionVariables = {
      XMODIFIERS = "@im=fcitx";
      INPUT_METHOD = "fcitx5";
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
    };

  };
}
