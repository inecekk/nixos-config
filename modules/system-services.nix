# modules/system-services.nix
{ config, pkgs, ... }:
{
  # ==========================================
  # 1. 抢占式睡眠前置服务
  # 解决睡眠前因音频设备未释放导致的"重播最后两字"问题
  # ==========================================
  systemd.services.pre-suspend-mute = {
    description = "Stop MPD, suspend PipeWire node and mute audio before system freezing";
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
  # 2. 电源管理
  # 优化 s2idle 下的睡眠进入与唤醒流程
  # ==========================================
  powerManagement = {
    # --- 睡眠前置任务 ---
    powerDownCommands = ''
      # 1. 业务切断：关闭网络与蓝牙，防止睡眠期间产生意外连接、间接阻止设备完全进入低功耗状态
      ${pkgs.bluez}/bin/bluetoothctl power off
      ${pkgs.networkmanager}/bin/nmcli radio wifi off

      # 2. 唤醒源控制：仅允许键盘唤醒，禁用其他不必要的 ACPI 唤醒源
      #    （原理：找到键盘所在的 PCI/USB 路径，保留其唤醒能力，其余全部关闭）
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

      # 3. 挂载与进程处理：执行懒卸载以防数据盘在睡眠时锁死
      /run/current-system/sw/bin/umount -l /home/lk/D 2>/dev/null || true

      # 4. 显卡驱动清理：增加 kill 等待间隔，给予 GPU 上下文释放缓冲时间
      /run/current-system/sw/bin/pkill -u lk -x 'qq|chrome|zen|vscode' 2>/dev/null || true
      sleep 1.5
      /run/current-system/sw/bin/pkill -9 -u lk -x 'qq|chrome|zen|vscode' 2>/dev/null || true

      # 移除：echo "0" > /sys/class/vtconsole/vtcon1/bind
      # 原因：解绑虚拟终端控制台会导致 DRM/KMS 驱动在唤醒时无法正确重新接管显示输出，
      #       是此前"唤醒失败/黑屏卡死"的直接原因，已彻底移除，不再保留
    '';

    # --- 唤醒后置任务 ---
    resumeCommands = ''
      # 统一等待硬件初始化复位，防止音频瞬态杂音
      sleep 1.5
      ${pkgs.systemd}/bin/systemctl start mpd
      ${pkgs.bluez}/bin/bluetoothctl power on
      ${pkgs.networkmanager}/bin/nmcli radio wifi on
      # 强制刷新声卡寄存器状态
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Master unmute >/dev/null 2>&1
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Speaker unmute >/dev/null 2>&1
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Headphone unmute >/dev/null 2>&1
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Master toggle >/dev/null 2>&1
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Master toggle >/dev/null 2>&1
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Speaker toggle >/dev/null 2>&1
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Speaker toggle >/dev/null 2>&1
    '';
  };

  # ==========================================
  # 3. 硬件补丁（已移除）
  # ------------------------------------------
  # 原规则：
  #   ACTION=="suspend", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{power/control}="on"
  # 移除原因：
  #   该规则在挂起时强制 AMD 独显/核显电源状态保持 "on"，
  #   与 s0i3/s2idle 要求所有设备主动降至低功耗状态的机制直接冲突——
  #   SMU 会一直等待 GPU 汇报"已降功耗"而收不到响应，
  #   这正是日志中 "amd_pmc: SMU response timed out / suspend failed: -110"
  #   的最可能成因。结合 boot.nix 中 amdgpu.runpm=0（禁止运行时电源管理抢占）
  #   已经能起到防止驱动异常的作用，此 udev 规则予以移除。
  # ==========================================

  # ==========================================
  # 4. 图形与基础服务
  # ==========================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # 强制 PipeWire 音频流不自动挂起，从底层减少 DMA 中断波动
    extraConfig.pipewire."99-suspend-on-idle" = {
      "context.properties" = {
        "session.suspend-timeout-seconds" = 0;
      };
    };
  };
  services.pulseaudio.enable = false;

  # Portal 配置
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = [ "wlr" ];
  };

  # Greetd 登录管理器
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "lk";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.niri}/bin/niri-session";
        user = "greeter";
      };
    };
  };

  # 服务精简：禁用冗余服务以减少系统开销
  services.printing.enable = false;
  services.avahi.enable = false;
  services.geoclue2.enable = false;
  services.packagekit.enable = false;
  services.power-profiles-daemon.enable = false;
  services.gnome.gnome-keyring.enable = true;
  services.speechd.enable = false;
}
