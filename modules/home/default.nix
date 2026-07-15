{ inputs, ... }:
{
  home-manager.users.lk = { pkgs, ... }: {
    imports = [
      ./niri.nix ./foot.nix ./fcitx5-rime.nix ./mpv-fastfetch.nix
      ./mako-mpd.nix ./rnote.nix ./noctalia.nix
    ];

    home.stateVersion = "26.11";

    # --- 用户应用软件包 ---
    home.packages = with pkgs; [
      # 个人 CLI 工具（从系统层挪过来的）：
      git gnused tree wget foot
      # 终端与文件：
      btop fish zsh yazi p7zip-rar imagemagick
      # Wayland 工具：
      grim slurp wl-clipboard wf-recorder libnotify
      # 浏览器：
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      # 影音通讯：
      qq materialgram rmpc go-musicfox
      # 开发生产力：
      vscode rnote opentabletdriver
    ];

    # --- 用户级环境变量 ---
    home.sessionVariables = {
      XMODIFIERS = "@im=fcitx";
      INPUT_METHOD = "fcitx5";
      NIXOS_OZONE_WL = "1";
      CHROME_EXTRA_ARGS = "--ozone-platform-hint=auto --enable-features=UsePipewireCamera --use-gl=angle --use-angle=vulkan";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
    };

    # --- 用户级服务 ---
    systemd.user.services.blueman-applet = {
      Unit = { Description = "Disabled Blueman Applet"; };
      Service = { ExecStart = "${pkgs.coreutils}/bin/true"; Restart = "no"; };
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
