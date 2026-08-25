{
  inputs,
  lib,
  pkgs,
  ...
}:
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
# 定义 miyu 自定义 Rust 软件包

  miyu = pkgs.rustPlatform.buildRustPackage rec {
    pname = "miyu";
    version = "latest";
    doCheck = false ;
    src = pkgs.fetchFromGitHub {
      owner = "SHORiN-KiWATA";
      repo = "Miyu";
      rev = "main";
      sha256 = "sha256-hOzwiRRGA9NKp7mBEIQ6fR7tUchvbypFIgO7djhAsiI=";
    };
    cargoHash = "sha256-SBl+JcmKEonUmmFt1Zpf+2TeAhFlvRktd2IJxKHraU4=";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.alsa-lib pkgs.openssl ];
  };

in
{
  # 1. Home Manager 用户配置
  home-manager.users.lk = { pkgs, ... }: {
    imports = autoImports; # 自动导入所有模块
    home.stateVersion = "26.11"; # 设置 Home Manager 状态版本

    # 用户安装的软件包列表
    home.packages = with pkgs; [
      git impala wget foot bluetui btop yazi tree grim
      libnotify
      qq pcmanfm go-musicfox
      (inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default)
      materialgram
      jq vscode rnote opentabletdriver
   miyu # 自定义包
    ];

    # 路径与环境变量配置
    home.sessionPath = [
      "$HOME/.local/bin"
      "/etc/profiles/per-user/lk/bin"
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

  # 2. 系统级服务与窗口管理器配置
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  
  services.upower.enable = true; # Noctalia 电量显示依赖

  programs.noctalia = {
    enable = true;
    package = pkgs.noctalia;
  };

  # 3. 系统级挂载：QQ 缓存目录 tmpfs
  fileSystems."/home/lk/.config/QQ/versions" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=1M"
      "nr_inodes=64"
      "uid=1000"
      "gid=100"
      "mode=0755"
      "x-systemd.requires-mounts-for=/home/lk/.config/QQ"
    ];
  };
}
