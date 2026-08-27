{ inputs, lib, pkgs, ... }:
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

  # Miyu 免编译二进制包
  miyu = pkgs.stdenv.mkDerivation rec {
    pname = "miyu";
    version = "0.4.5";
    src = pkgs.fetchurl {
      url = "https://github.com/inecekk/Miyu/releases/download/v${version}/miyu-x86_64-linux.tar.gz";
      hash = "sha256-EngbDv6Jh2+YWE143VVaXu75UQyvaT+TBlCGoLSPPvA=";
    };
    sourceRoot = ".";
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = with pkgs; [ alsa-lib openssl stdenv.cc.cc.lib zlib ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp miyu $out/bin/
      chmod +x $out/bin/miyu
      runHook postInstall
    '';
    meta = { description = "Miyu 免编译二进制版"; homepage = "https://github.com/inecekk/Miyu"; mainProgram = "miyu"; platforms = [ "x86_64-linux" ]; };
  };

  # Voicefox 免编译二进制包
  voicefox = pkgs.stdenv.mkDerivation rec {
    pname = "voicefox";
    version = "0.3.7";
    src = pkgs.fetchurl {
      url = "https://github.com/emoeem/voicefox/releases/download/${version}/voicefox-linux-x86_64.zip";
      sha256 = "b4792571966b7f82961e9a337f248a31702e09a05d88991f95be86fa142680c4";
    };
    sourceRoot = ".";
    nativeBuildInputs = with pkgs; [ autoPatchelfHook unzip ];
    buildInputs = with pkgs; [ alsa-lib mpv-unwrapped openssl stdenv.cc.cc.lib zlib ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp voicefox $out/bin/
      chmod +x $out/bin/voicefox
      runHook postInstall
    '';
    meta = { description = "Voicefox 免编译二进制版"; homepage = "https://github.com/emoeem/voicefox"; mainProgram = "voicefox"; platforms = [ "x86_64-linux" ]; };
  };
in
{
  # 1. Home Manager 用户配置
  home-manager.users.lk = { pkgs, ... }: {
    imports = autoImports; # 自动导入所有子模块
    home.stateVersion = "26.11";
    # 用户软件包列表 (按字母序排列)
    home.packages = with pkgs; [
      bluetui btop foot git go-musicfox impala libnotify materialgram
	mpvpaper   miyu pcmanfm qq tree voicefox vscode wget
      (inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default)
    ];
    home.sessionPath = [ "$HOME/.local/bin" "/etc/profiles/per-user/lk/bin" ];
    home.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      GDK_BACKEND = "wayland";
      GTK_USE_PORTAL = "1"; # 强制 GTK 应用使用 Portal 弹窗
      INPUT_METHOD = "fcitx5";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      XMODIFIERS = "@im=fcitx";
    };
  };

  # 2. 系统级服务与窗口管理器
  programs.niri = { enable = true; package = pkgs.niri; };
  services.upower.enable = true; # Noctalia 电量显示依赖
  programs.noctalia = { enable = true; package = pkgs.noctalia; };

  # 3. Desktop Portal 配置 (修复 Zen 浏览器文件选择器)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common = { default = [ "gtk" ]; };
      niri = { default = lib.mkForce [ "gtk" ]; };
    };
  };

  # 4. 系统级挂载：QQ 缓存目录 tmpfs
  fileSystems."/home/lk/.config/QQ/versions" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=1M" "nr_inodes=64" "uid=1000" "gid=100" "mode=0755" "x-systemd.requires-mounts-for=/home/lk/.config/QQ" ];
  };
}
