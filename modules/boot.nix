# modules/boot.nix
{
  config,
  pkgs,
  lib,
  ...
}:

let
  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  boot = {
    # 内核使用默认稳定版，不用 latest（AMD s2idle 相关驱动在 latest 上不稳定，已验证会导致唤醒失败）
    kernelPackages = pkgs.linuxPackages;

    supportedFilesystems = [ "ntfs" ];
    kernelModules = [ "tcp_bbr" ];
    kernel.sysctl."net.ipv4.ip_forward" = 1;

    extraModprobeConfig = ''
      options cfg80211_regdom=CN
      options mac80211 minstrel_vht_only=0
      options snd_hda_interpower_save=0 power_save_node=0
    '';

    kernelParams = lib.mkForce [
      "loglevel=4"
      "acpi_enforce_resources=lax"
      "systemd.default_timeout_stop_sec=9s"

      # 保留：仅开启 SMU 调试轨迹缓冲区，用于排查 s2idle 问题，不影响挂起流程本身
      "amd_pmc.enable_stb=1"

      # 保留：合盖状态检测方式改为 method（ACPI 方法查询），比默认更可靠
      "button.lid_init_state=method"

      # 保留：禁止 amdgpu 运行时电源管理抢占，配合 udev 规则统一由系统接管（见 system-services.nix）
      "amdgpu.runpm=0"

      # 移除：acpi_osi=!acpi_osi=Linux
      # 原因：谎报非 Linux 系统会让固件走未经测试的 ACPI 挂起分支，
      #       是本次 SMU 握手超时（suspend failed: -110）的主要嫌疑，予以移除

      # 移除：pcie_aspm=force
      # 原因：强制所有 PCIe 设备开启主动电源管理，容易导致 USB4/Thunderbolt
      #       控制器在挂起/唤醒时不稳定，与日志中 ucsi_acpi 报错时间点吻合，予以移除

      # 移除：amd_pmc.pref_ignore_msr=1
      # 原因：绕过硬件 MSR 状态检测强行走 s0i3 深睡路径，
      #       硬件条件不满足时容易导致挂起流程卡死，予以移除

      # 保留：禁止 NVMe 进入深度休眠，防止睡眠时掉盘死机
      "nvme_core.default_ps_max_latency_us=0"
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
}
