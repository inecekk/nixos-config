# modules/base.nix
# ==========================================
# 系统基础设置：时区、状态版本、杂项开关
# ==========================================
{ config, lib, pkgs, ... }:
{
        programs.fish.enable = true; # 启用fish 
        time.timeZone = "Asia/Shanghai";
        time.hardwareClockInLocalTime = false;
        system.stateVersion = "26.05";

        # 日志过滤
        systemd.settings.Manager = {
        LogLevel = "err";
        };
        systemd.user.settings.Manager = {
        LogLevel = "err";
        };

        # 临时文件清理（用户缓存）
        systemd.tmpfiles.rules = [
        "e ~lk/.cache - - - 7d"
        "e ~lk/.config/materialgram/Cache - - - 7d"
        "e ~lk/.config/google-chrome/Default/Cache - - - 7d"
        "e ~lk/.config/Code/Cache - - - 7d"
        "e ~lk/.config/QQ/*/Cache - - - 7d"
        ];

        nixpkgs.config.allowUnfree = true;
        programs.fuse.userAllowOther = true;
        systemd.coredump.settings.Coredump.MaxUse = "100M";

        services.journald.extraConfig = ''
        SystemMaxUse=100M
        SystemKeepFree=1G
        MaxRetentionSec=1week
        RateLimitIntervalSec=30s
        RateLimitBurst=1000
        '';

        # 免密码挂载
        security.sudo.extraRules = [{
        users = [ "lk" ];
        commands = [
        { command = "/run/current-system/sw/bin/mount"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/umount"; options = [ "NOPASSWD" ]; }
        ];
        }];

        # 禁用 WiFi 省电
        networking.networkmanager.wifi.powersave = false;

        # ---------- 文档瘦身 ----------
        documentation.nixos.enable = false;
        documentation.info.enable = false;
        documentation.doc.enable = false;
        documentation.man.enable = false;   # 不要 man

        # 精简语言环境
        i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "zh_CN.UTF-8/UTF-8" ];

        # 禁用不需要的服务
        services.printing.enable = false;
        services.avahi.enable = false;
        programs.nano.enable = false;
        services.geoclue2.enable = false;
        services.packagekit.enable = false;
}
