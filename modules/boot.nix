{ config, pkgs, lib, ... }:

let
  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  # ==========================================
  # 1. 引导与内核配置
  # ==========================================
  boot = {
    # 内核使用稳定版，避免 latest 可能引发的 AMD 驱动稳定性问题
    kernelPackages = pkgs.linuxPackages;

    supportedFilesystems = [ "ntfs" ];
    kernelModules = [ "tcp_bbr" ];
    
    # 【已添加】彻底禁止 amd_pmc 模块，强制放弃 Modern Standby
    blacklistedKernelModules = [ "amd_pmc" ];
    
    # 启用 IP 转发
    kernel.sysctl."net.ipv4.ip_forward" = 1;

    # 硬件驱动加载参数
    extraModprobeConfig = ''
      options cfg80211_regdom=CN
      options mac80211 minstrel_vht_only=0
      # 禁止声卡自动电源管理，防止唤醒杂音或卡死
      options snd_hda_interpower_save=0 power_save_node=0
    '';

    # 关键内核参数优化
    kernelParams = lib.mkForce [
      "loglevel=4"
      "acpi_enforce_resources=lax"
      "systemd.default_timeout_stop_sec=9s"

      # --- 挂起/电源管理核心修复 ---
      # 强制关闭 STB 调试以减轻 SMU 负担，防止通讯超时
      "amd_pmc.enable_stb=0"
      # 合盖触发方式设为 ACPI method，更稳定
      "button.lid_init_state=method"
      # 禁止 amdgpu 自动电源管理抢占，防止唤醒时显卡卡死
      "amdgpu.runpm=0"
      # 禁止 NVMe 进入超深睡眠状态，防止唤醒掉盘
      "nvme_core.default_ps_max_latency_us=0"
    ];

    # GRUB 引导加载配置
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
  # 2. 睡眠前置任务 (Systemd 服务)
  # ==========================================
  systemd.services.pre-suspend-mute = {
    description = "音频设备预静音，防止睡眠瞬间产生杂音";
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c " \
          ${pkgs.systemd}/bin/systemctl stop mpd; \
          ${pkgs.wireplumber}/bin/wpctl suspend @DEFAULT_AUDIO_SINK@ >/dev/null 2>&1; \
          ${pkgs.alsa-utils}/bin/amixer -c 0 set Master mute >/dev/null 2>&1; \
          sleep 0.1 \
        "
      '';
    };
  };

  # ==========================================
  # 3. 电源管理执行逻辑
  # ==========================================
  powerManagement = {
    # --- 挂起前：环境清理 ---
    powerDownCommands = ''
      # 1. 业务切断：关闭网络与蓝牙，防止睡眠唤醒波动
      ${pkgs.bluez}/bin/bluetoothctl power off
      ${pkgs.networkmanager}/bin/nmcli radio wifi off

      # 2. ACPI 唤醒源清理：仅保留键盘，禁用其他干扰设备
      KBD_PCI_SLOTS=""
      for input_dev in /sys/class/input/input*; do
        if [ -f "$input_dev/name" ] && grep -qiE "keyboard" "$input_dev/name" 2>/dev/null; then
          devpath=$(readlink -f "$input_dev/device" 2>/dev/null)
          p="$devpath"
          while [ -n "$p" ] && [ "$p" != "/" ] && [ "$p" != "/sys" ]; do
            if [ -f "$p/idVendor" ]; then found_usb="$p"; fi
            p=$(dirname "$p")
          done
          if [ -n "$found_usb" ]; then
            pci=$(readlink -f "$found_usb"/../../.. 2>/dev/null)
            slot=$(basename "$pci" 2>/dev/null)
            KBD_PCI_SLOTS="$KBD_PCI_SLOTS $slot"
          fi
        fi
      done

      while read -r name status rest; do
        case "$name" in Device*|*"----"*) continue ;; esac
        if [ "$status" = "*enabled" ]; then
          keep="no"
          for slot in $KBD_PCI_SLOTS; do
            acpi_path=$(grep -l "^$name$" /sys/bus/acpi/devices/*/path 2>/dev/null | head -n1)
            if [ -n "$acpi_path" ]; then
              real_pci=$(readlink -f "$(dirname "$acpi_path")/physical_node" 2>/dev/null)
              if [ -n "$real_pci" ] && echo "$real_pci" | grep -q "$slot"; then keep="yes"; fi
            fi
          done
          if [ "$keep" = "no" ]; then echo "$name" > /proc/acpi/wakeup 2>/dev/null || true; fi
        fi
      done < /proc/acpi/wakeup

      # 3. 挂载处理：卸载数据盘防止锁死
      /run/current-system/sw/bin/umount -l /home/lk/D 2>/dev/null || true

      # 4. 进程清理：强制释放 GPU 占用进程
      /run/current-system/sw/bin/pkill -u lk -x 'qq|chrome|zen|vscode' 2>/dev/null || true
      sleep 1.5
      /run/current-system/sw/bin/pkill -9 -u lk -x 'qq|chrome|zen|vscode' 2>/dev/null || true
    '';

    # --- 唤醒后：恢复服务 ---
    resumeCommands = ''
      sleep 1.5
      ${pkgs.systemd}/bin/systemctl start mpd
      ${pkgs.bluez}/bin/bluetoothctl power on
      ${pkgs.networkmanager}/bin/nmcli radio wifi on
      # 强制刷新声卡寄存器，确保声音正常
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Master unmute >/dev/null 2>&1
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Speaker unmute >/dev/null 2>&1
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Headphone unmute >/dev/null 2>&1
    '';
  };
}
