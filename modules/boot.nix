# modules/boot.nix
# ==========================================
# 系统引导、内核参数与文件系统支持
# ==========================================
{ config, pkgs, lib, ... }:

let
  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  boot = {
    # --- 内核设置 ---
    kernelPackages = pkgs.linuxPackages; # 使用标准内核
    supportedFilesystems = [ "ntfs" ];   # NTFS 支持
    
    # --- 内核参数（合并所有参数） ---
    kernelParams = lib.mkForce [
      # 日志设置
      "loglevel=4"                        # 设置日志级别，减少启动刷屏
      "log_buf_len=8M"                   # 日志缓冲区大小
      
      # 硬件兼容性
      "acpi_enforce_resources=lax"        # 放宽 ACPI 资源限制
      "acpi_osi=!acpi_osi=Linux"          # 硬件兼容性伪装
      "button.lid_init_state=method"      # 修复合盖状态检测
      
      # AMD 相关
      "amd_pmc.enable_stb=1"              # AMD 电源管理调试
      "amd_pmc.pref_ignore_msr=1"         # 忽略 MSR 错误
      "amdgpu.runpm=1"                    # 启用 AMDGPU 运行时电源管理
      
      # 系统优化
      "systemd.default_timeout_stop_sec=9s" # 缩短关机等待时间
    ];

    # --- 内核模块 ---
    kernelModules = [ "tcp_bbr" ];       # 启用 BBR 拥塞控制
    kernel.sysctl."net.ipv4.ip_forward" = 1; # 启用 IPv4 转发

    # 驱动模块参数
    extraModprobeConfig = ''
      options cfg80211_regdom=CN
      options mac80211 minstrel_vht_only=0
    '';

    # --- 引导加载程序配置 ---
    loader = {
      timeout = 3; 

      efi.canTouchEfiVariables = false;
      
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
        useOSProber = true;
        
        # 主题与分辨率设置
        theme = "${scripts.wutheringGrubTheme}/grub/themes/changli";
        extraConfig = ''
          set gfxmode=1920x1080
          set gfxpayload=keep
        '';
      };
    };
  };
}
