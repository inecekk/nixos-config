# modules/hardware.nix
# ==========================================
# 硬件驱动、图形、蓝牙与安全策略模块
# ==========================================
{ pkgs, ... }:

{
        # --- 1. 数位板驱动与规则 ---
        # 通过 udev 规则加载驱动，确保即插即用且无需服务模块支持
        environment.systemPackages = [ pkgs.opentabletdriver ];
        services.udev.packages = [ pkgs.opentabletdriver ];

        # --- 2. 密钥管理服务 ---
        # 启用 gnome-keyring，由 system-services.nix 中的 PAM 规则负责解锁
        services.gnome.gnome-keyring.enable = true;

        # --- 3. 硬件基础设置 ---
        hardware = {
        # 图形驱动配置
        graphics = {
        enable = true;
        enable32Bit = true; # 支持 32 位图形库 (Steam/WINE 等)
        };

        # 蓝牙控制器配置
        bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        ControllerMode = "dual";
        FastConnectable = true;
        AutoEnable = true;
        JustWorksRepairing = "always";
        };
        };
        };

        # --- 4. 辅助程序配置 ---
        programs = {
        dconf.enable = true; # GNOME 配置数据库，许多应用依赖
        niri.enable = true;   # 启用 Niri 窗口管理器
        };

        # --- 5. 安全与认证策略 ---
        security = {
        polkit.enable = true; # 必须：系统权限授权管理
        
        # 登录时通过 PAM 自动解锁 gnome-keyring
        pam.services.greetd.text = ''
        auth requisite pam_nologin.so
        auth include login
        auth optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
        account include login
        password include login
        password optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so use_authtok
        session include login
        session optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
        '';
        };
}
