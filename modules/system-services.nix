# modules/system-services.nix
# ==========================================
# 系统服务、睡眠/唤醒逻辑、音频、图形等
# ==========================================
{ pkgs, config, lib, ... }:   # 注意添加 config, lib 以便使用用户信息

{
  # ==========================================
  # 0. 内核音频补丁：彻底禁用声卡自动省电（根除物理“滋滋”和电流声）
  # ==========================================
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_node=0
  '';

  # ==========================================
  # 1. 基础睡眠策略（允许挂起，禁用休眠等）
  # ==========================================
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "poweroff";
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
    IdleAction = "ignore";
  };

  # ==========================================
  # 2. 缩短全局关机/重启超时（防卡保底，将 90s 缩短至 10s）
  # ==========================================
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };

  # ==========================================
  # 3. 抢占式睡眠前置服务（解决睡眠前“重播最后两字”的关键）
  # ==========================================
  # 在系统开始冻结进程前：停止 MPD -> 强行释放声卡硬件占用 -> 物理静音
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
  # 4. 电源管理
  # ==========================================
  powerManagement = {
    # ----- 睡眠前执行（root 权限） -----
    powerDownCommands = ''
      # 注：MPD 关闭与静音已由上方的 pre-suspend-mute 服务提前安全处理

      # 关闭蓝牙（省电）
      ${pkgs.bluez}/bin/bluetoothctl power on

      # 关闭 WiFi
      ${pkgs.networkmanager}/bin/nmcli radio wifi off

      # 禁用 USB 唤醒源（降低 s2idle 待机功耗）
      for dev in XHC0 XHC1 XHC2 XHC3 XHC4; do
        grep -q "$dev.*enabled" /proc/acpi/wakeup && echo "$dev" > /proc/acpi/wakeup
      done

      # 纯原生 shell 逻辑：强行清理并杀死正在读写 /home/lk/D 的所有进程，防止卸载挂死
      # 遍历 /proc/*/mountinfo 寻找占用 /home/lk/D 目录的进程 PID，并强行 kill -9
      for pid in $(grep -l "/home/lk/D" /proc/*/mountinfo 2>/dev/null | cut -d'/' -f3); do
        if [ "$pid" -eq "$pid" ] 2>/dev/null; then
          kill -9 "$pid" 2>/dev/null || true
        fi
      done

      # 杀掉用户进程（以用户 lk 身份执行）
      # 使用 su 切换用户执行 pkill，避免 root 误杀系统进程
      ${pkgs.su} - lk -c "${pkgs.procps}/bin/pkill -9 -x 'qq|chrome|zen|vscode' 2>/dev/null || true"
    '';

    # ----- 唤醒后执行（root 权限） -----
    resumeCommands = ''
      # 统一延迟 1 秒，等待声卡、网卡、蓝牙硬件彻底通电复位，避免瞬态“噗”声和初始化冲突
      sleep 1

      # 启动 MPD
      ${pkgs.systemd}/bin/systemctl start mpd

      # 开启蓝牙
      ${pkgs.bluez}/bin/bluetoothctl power on

      # 开启 WiFi
      ${pkgs.networkmanager}/bin/nmcli radio wifi on

      # 恢复声音并消除扬声器“滋滋”声（先解除静音，再通过两次 toggle 强制刷新声卡寄存器状态）
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
  # 5. 硬件补丁（AMD GPU 电源控制）
  # ==========================================
  services.udev.extraRules = ''
    ACTION=="suspend", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x1681", ATTR{power/control}="on"
  '';

  # ==========================================
  # 6. 图形、音频与基础服务
  # ==========================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # 强制 PipeWire 在没有音频流活动时，立即挂起音频设备，从底层清理 DMA 缓冲区残留
    extraConfig.pipewire."99-suspend-on-idle" = {
      "context.properties" = {
        "session.suspend-timeout-seconds" = 0;
      };
    };
  };
  services.pulseaudio.enable = false;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = [ "wlr" ];
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = { command = "${pkgs.niri}/bin/niri-session"; user = "lk"; };
      default_session = { command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.niri}/bin/niri-session"; user = "greeter"; };
    };
  };

  # 精简冗余服务
  services = {
    printing.enable = false;
    avahi.enable = false;
    geoclue2.enable = false;
    packagekit.enable = false;
    power-profiles-daemon.enable = false;
    gnome.gnome-keyring.enable = true;
    speechd.enable = false;
  };
}
