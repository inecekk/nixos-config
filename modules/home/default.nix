{ inputs, lib, pkgs, ... }:
let
  homeDir = ./.;
  autoImports = builtins.map (name: homeDir + "/${name}") (
    builtins.attrNames (
      lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
        (builtins.readDir homeDir)
    )
  );

  miyu = pkgs.stdenv.mkDerivation rec {
    pname = "miyu"; version = "0.4.5";
    src = pkgs.fetchurl {
      url = "https://github.com/inecekk/Miyu/releases/download/v${version}/miyu-x86_64-linux.tar.gz";
      hash = "sha256-EngbDv6Jh2+YWE143VVaXu75UQyvaT+TBlCGoLSPPvA=";
    };
    sourceRoot = ".";
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = with pkgs; [ alsa-lib openssl stdenv.cc.cc.lib zlib ];
    installPhase = "mkdir -p $out/bin; cp miyu $out/bin/; chmod +x $out/bin/miyu";
  };

  voicefox = pkgs.stdenv.mkDerivation rec {
    pname = "voicefox"; version = "v0.3.11";
    src = pkgs.fetchurl {
      url = "https://github.com/emoeem/voicefox/releases/download/${version}/voicefox-linux-x86_64.zip";
      sha256 = "d93f99b220b1c1558669c38a5ef4177b8b65a7a4271eafbb5581e84d573ea6f1";
    };
    sourceRoot = ".";
    nativeBuildInputs = with pkgs; [ autoPatchelfHook unzip ];
    buildInputs = with pkgs; [ alsa-lib mpv-unwrapped openssl stdenv.cc.cc.lib zlib ];
    installPhase = "mkdir -p $out/bin; cp voicefox $out/bin/; chmod +x $out/bin/voicefox";
  };
in
{
  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.lk = { pkgs, ... }: {
    imports = autoImports;
    home.stateVersion = "26.11";

    # ⚠️ 绝对不要在这里放 fcitx5 / qt6Packages.fcitx5-chinese-addons / fcitx5-gtk 等任何 fcitx5 相关包
    home.packages = with pkgs; [
      btop foot git go-musicfox  libnotify materialgram
      brightnessctl mpvpaper miyu pcmanfm qq tree voicefox vscode wget
      (inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default)
    ];

    home.sessionPath = [ "$HOME/.local/bin" "/etc/profiles/per-user/lk/bin" ];

    home.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      GDK_BACKEND = "wayland";
      GTK_USE_PORTAL = "1";
      INPUT_METHOD = "fcitx5";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      XMODIFIERS = "@im=fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "ibus";
    };
  };

  # ============================================================
  # fcitx5 + Rime（系统级，与 programs.niri 平级）
  # ============================================================
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-gtk
        qt6Packages.fcitx5-chinese-addons   # 中文引擎
        qt6Packages.fcitx5-configtool       # GUI 配置工具
      ];
      waylandFrontend = true;
      ignoreUserConfig = false;   # 保留 ~/.config/fcitx5 控制权
    };
  };

  programs.niri = { enable = true; package = pkgs.niri; };
  services.upower.enable = true;
  programs.noctalia = { enable = true; package = pkgs.noctalia; };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common = { default = [ "gtk" ]; };
      niri = { default = lib.mkForce [ "gtk" ]; };
    };
  };

  fileSystems."/home/lk/.config/QQ/versions" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=1M" "nr_inodes=64" "uid=1000" "gid=100" "mode=0755" "x-systemd.requires-mounts-for=/home/lk/.config/QQ" ];
  };
}
