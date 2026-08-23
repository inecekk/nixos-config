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
    kernelModules = ["tcp_bbr"];
    # 强制 S2idle 以避开 ACPI 深度睡眠 Bug，loglevel=3 减少日志噪音
    kernelParams = [
  # --- 电源管理与睡眠优化 ---
  "mem_sleep_default=deep"          # 深度睡眠（S3，比 s2idle 更省电稳定）
  "amd_pstate=guided"               # AMD CPU 协同调频优化
  "amd_pmc.enable_stb=0"            # 关闭 AMD PMC 的 Telemetry Buffer 降低功耗/唤醒延迟
  "amdgpu.runpm=0"                  # 独显/核显运行时电源管理调整
  
  # --- IOMMU 与硬件直通/PCIe 优化 ---
  "amd_iommu=on"
  "iommu=pt"
  "pcie_aspm=force"                 # 强制启用 PCIe 省电状态
  
  # --- 存储与延迟优化 ---
  "nvme_core.default_ps_max_latency_us=0" # 消除 NVMe 固态硬盘休眠延迟
  
  # --- 看门狗与错误处理（彻底解决关机 watchdog 报错） ---
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


  # 2. 睡眠前置清理任务 (防报错处理)
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
  # 3. 电源管理执行逻辑
  # ==========================================
  powerManagement = {
    powerDownCommands = ''
      ${pkgs.bluez}/bin/bluetoothctl power off 2>/dev/null || true
      ${pkgs.networkmanager}/bin/nmcli radio wifi off 2>/dev/null || true
      /run/current-system/sw/bin/pkill -9 -u lk -x 'qq|chrome|zen|vscode' 2>/dev/null || true
    '';

    resumeCommands = ''
      sleep 2
      # 仅在服务存在时尝试启动，使用 --no-block 避免挂起
  /*  
         if systemctl list-unit-files mpd.service | grep -q 'mpd.service'; then
        systemctl start mpd --no-block
      fi

*/

      ${pkgs.bluez}/bin/bluetoothctl power on 2>/dev/null || true
      ${pkgs.networkmanager}/bin/nmcli radio wifi on 2>/dev/null || true
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Master unmute 2>/dev/null || true
    '';
  };
}
