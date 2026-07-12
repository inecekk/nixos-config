# modules/system-services.nix
# ==========================================
# 系统服务、睡眠/唤醒逻辑、音频、图形等
# ==========================================
{ pkgs, config, lib, ... }:   # 注意添加 config, lib 以便使用用户信息

{
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
  # 2. 电源管理
  # ==========================================
  powerManagement = {
    # ----- 睡眠前执行（root 权限） -----
    powerDownCommands = ''
      # 停止 MPD 服务
      ${pkgs.systemd}/bin/systemctl stop mpd

      # 关闭蓝牙（省电）
      ${pkgs.bluez}/bin/bluetoothctl power off

      # 关闭 WiFi（若你想保留网络连接可注释掉下一行）
      ${pkgs.networkmanager}/bin/nmcli radio wifi off

      # 禁用 USB 唤醒源（降低 s2idle 待机功耗）
      for dev in XHC0 XHC1 XHC2 XHC3 XHC4; do
        grep -q "$dev.*enabled" /proc/acpi/wakeup && echo "$dev" > /proc/acpi/wakeup
      done

      # 杀掉用户进程（以用户 lk 身份执行）
      # 使用 su 切换用户执行 pkill，避免 root 误杀系统进程
      ${pkgs.su} - lk -c "${pkgs.procps}/bin/pkill -9 -x 'qq|chrome|zen|vscode' 2>/dev/null || true"
    '';

    # ----- 唤醒后执行（root 权限） -----
    resumeCommands = ''
      # 启动 MPD
      ${pkgs.systemd}/bin/systemctl start mpd

      # 开启蓝牙
      ${pkgs.bluez}/bin/bluetoothctl power on

      # 开启 WiFi
      ${pkgs.networkmanager}/bin/nmcli radio wifi on

      # 消除扬声器“滋滋”声（两次切换静音，强制刷新声卡状态）
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Master toggle >/dev/null 2>&1
      ${pkgs.alsa-utils}/bin/amixer -c 0 set Master toggle >/dev/null 2>&1
    '';
  };

  # ==========================================
  # 3. 硬件补丁（AMD GPU 电源控制）
  # ==========================================
  services.udev.extraRules = ''
    ACTION=="suspend", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x1681", ATTR{power/control}="on"
  '';

  # ==========================================
  # 4. 图形、音频与基础服务
  # ==========================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
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

  # 精简冗余服务（）
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
