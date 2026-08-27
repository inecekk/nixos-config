{
  config,
  pkgs,
  lib,
  ...
}: let
  scripts = import ./scripts.nix {inherit pkgs;};
in {
  # ==========================================
  # 1. 引导与内核配置
  # ==========================================
  boot = {
    kernelPackages = pkgs.linuxPackages;
    supportedFilesystems = ["ntfs"];
    kernelModules = ["tcp_bbr" "rtw89_8852be"]; # 显式加载 8852be 模块

    # 针对 RTL8852BE 和 AMD 6800H 的黑科技驱动参数
    extraModprobeConfig = ''
      # 禁用 8852be 的 PCIe 深度省电和 ASPM，彻底解决掉网/高延迟
      options rtw89_core disable_ps_mode=y
      options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y
    '';

    kernelParams = [
      # --- 电源管理与 CPU 调频 ---
      "mem_sleep_default=deep"          # 深度睡眠 (S3)
      "amd_pstate=active"               # 改为 active，赋予 powerprofilesctl / EPP 完整的性能调优能力
      "amd_pmc.enable_stb=0"            # 关闭 Telemetry Buffer 降低延迟
      # 移除 amdgpu.runpm=0 恢复显卡正常电源管理，确保性能模式正常拉满

      # --- IOMMU 与 PCIe 优化 ---
      "amd_iommu=on"
      "iommu=pt"
      # 彻底移除 pcie_aspm=force，换为按需保护 RTL8852BE 网卡：
      "pcie_aspm.policy=performance"    # 保证 PCIe 总线响应速度，防止网卡与 NVMe 掉线

      # --- 存储与延迟优化 ---
      "nvme_core.default_ps_max_latency_us=0" # 消除 NVMe 休眠延迟

      # --- 看门狗与错误处理 ---
      "nowatchdog"
      "nmi_watchdog=0"

      # --- 系统杂项与 ACPI ---
      "acpi_enforce_resources=lax"
      "quiet"
      "loglevel=3"
      "mitigations=auto"
      "systemd.default_timeout_stop_sec=9s"
    ];

    loader = {
      timeout = 3;
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
        useOSProber = true;
        theme = "${scripts.wutheringGrubTheme}/grub/themes/changli";
        extraConfig = ''
          set gfxmode=1920x1080
          set gfxpayload=keep
        '';
      };
    };
  };

  # ==========================================
  # 2. 硬件网络与性能模式配置
  # ==========================================
  # 禁用 NetworkManager 自身的 WiFi 省电策略
  networking.networkmanager.wifi.powersave = false;

  # 启用 power-profiles-daemon 以支持性能模式切换
  services.power-profiles-daemon.enable = true;

  # ==========================================
  # 3. 睡眠前置清理任务 (防报错处理)
  # ==========================================
  systemd.services.pre-suspend-tasks = {
    description = "睡眠前清理任务";
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];

    script = ''
      ${pkgs.wireplumber}/bin/wpctl suspend-node @DEFAULT_AUDIO_SINK@ 2>/dev/null || true
      ${pkgs.alsa-utils}/bin/amixer -c 0 sset Master mute 2>/dev/null || true
    '';

    serviceConfig = {
      Type = "oneshot";
    };
  };

  # ==========================================
  # 4. 电源管理执行逻辑
  # ==========================================
  powerManagement = {
    powerDownCommands = ''
      ${pkgs.util-linux}/bin/timeout 3s ${pkgs.bluez}/bin/bluetoothctl power off 2>/dev/null || true
      ${pkgs.networkmanager}/bin/nmcli radio wifi off 2>/dev/null || true
      /run/current-system/sw/bin/pkill -9 -u lk -x 'qq|chrome|zen|vscode' 2>/dev/null || true
    '';

    resumeCommands = ''
      sleep 2
      ${pkgs.util-linux}/bin/timeout 3s ${pkgs.bluez}/bin/bluetoothctl power on 2>/dev/null || true
      ${pkgs.networkmanager}/bin/nmcli radio wifi on 2>/dev/null || true
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Master unmute 2>/dev/null || true
    '';
  };
}
