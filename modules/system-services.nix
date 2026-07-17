{ config, pkgs, ... }:
{
  # ==========================================
  # 1. 抢占式睡眠前置服务
  # 解决睡眠前因音频设备未释放导致的“重播最后两字”问题
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
      # 1. 业务切断：关闭网络与蓝牙，防止睡眠期间产生意外连接中断
      ${pkgs.bluez}/bin/bluetoothctl power off
      ${pkgs.networkmanager}/bin/nmcli radio wifi off

      # 2. 唤醒源控制：仅允许键盘唤醒，禁用其他不必要的 ACPI 唤醒源
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

      # 5. 强制 DRM 清理：解绑 vtcon1，规避 s2idle 模式下常见的驱动挂起死机
      echo "0" > /sys/class/vtconsole/vtcon1/bind 2>/dev/null || true
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
  # 3. 硬件补丁
  # 强制 AMD GPU 运行时电源状态为 on，防止睡眠时因驱动错误导致电源管理异常
  # ==========================================
  services.udev.extraRules = ''
    ACTION=="suspend", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{power/control}="on"
  '';

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
