{ inputs, lib, ... }:
let
        homeDir = ./.;

        # 判断一个目录条目是否应该被自动 import：
        # 1. 必须是普通文件（排除目录、软链接等）
        # 2. 文件名以 .nix 结尾（.bak 后缀的备份文件会被天然排除，因为 "xxx.nix.bak" 不以 ".nix" 结尾）
        # 3. 排除 default.nix 自己，避免自我引用
        isAutoImportable = name: type:
        type == "regular"
        && lib.hasSuffix ".nix" name
        && name != "default.nix";

        # 扫描当前目录，生成所有符合条件的文件路径列表
        autoImports =
        builtins.map
        (name: homeDir + "/${name}")
        (builtins.attrNames (lib.filterAttrs isAutoImportable (builtins.readDir homeDir)));
in
{
        home-manager.users.lk = { pkgs, ... }: {
        imports = autoImports;
        home.stateVersion = "26.11";
        # --- 用户应用软件包 ---
        home.packages = with pkgs; [
        git gnused tree wget foot bluetui
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
