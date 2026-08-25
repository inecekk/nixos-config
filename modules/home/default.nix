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

  # 定义 miyu (使用 Github Release 免编译二进制包)
  miyu = pkgs.stdenv.mkDerivation rec {
    pname = "miyu";
    version = "0.4.5";

    src = pkgs.fetchurl {
      url = "https://github.com/inecekk/Miyu/releases/download/v${version}/miyu-x86_64-linux.tar.gz";
      hash = "sha256-EngbDv6Jh2+YWE143VVaXu75UQyvaT+TBlCGoLSPPvA=";
    };

    # 关键修复：告知 Nix 压缩包解压后直接使用当前工作目录，无需寻找子文件夹
    sourceRoot = ".";

    # 使用 autoPatchelfHook 自动修复 NixOS 下的动态库链接
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];

    # 包含运行该二进制文件所需的系统动态库
    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      alsa-lib
      openssl
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp miyu $out/bin/
      chmod +x $out/bin/miyu
      runHook postInstall
    '';

    meta = {
      description = "Miyu 免编译二进制版";
      homepage = "https://github.com/inecekk/Miyu";
      mainProgram = "miyu";
      platforms = [ "x86_64-linux" ];
    };
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
      miyu # 引入上面的自定义包
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
      # 强制 GTK 应用使用 Portal 弹窗
      GTK_USE_PORTAL = "1"; 
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

  # -------------------------------------------------------------
  # ⭐ 修复 Zen 浏览器无法上传文件：配置 Desktop Portal 并强制覆盖冲突
  # -------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      # 使用 lib.mkForce 强制将 Niri 的默认 portal 后端设为 gtk
      niri = {
        default = lib.mkForce [ "gtk" ];
      };
    };
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
