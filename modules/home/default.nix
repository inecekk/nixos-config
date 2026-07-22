{ inputs, lib, ... }:

let
  homeDir = ./.;

  # 自动扫描并导入当前目录下的所有 .nix 文件 (排除 default.nix)
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

    imports = autoImports; # 自动导入所有模块
    home.stateVersion = "26.11"; # 设置 Home Manager 状态版本

    # 用户安装的软件包列表
    home.packages = with pkgs; [
      git   wget foot bluetui btop  yazi tree 
       grim slurp wl-clipboard  libnotify
      (inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default)
      qq materialgram rmpc go-musicfox vscode rnote opentabletdriver 
    ];

    # 设置 Wayland 相关环境变量，确保所有 GUI 程序运行在 Wayland 后端
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
