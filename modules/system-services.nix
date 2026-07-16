{ config, pkgs, ... }:
{

# ==========================================
        # 3. 抢占式睡眠前置服务（解决睡眠前"重播最后两字"的关键）
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
        # 关闭蓝牙（修正原配置中 power on 的笔误）
        ${pkgs.bluez}/bin/bluetoothctl power off
        # 关闭 WiFi
        ${pkgs.networkmanager}/bin/nmcli radio wifi off
        # 禁用 USB 唤醒源（降低 s2idle 待机功耗）
        for dev in XHC0 XHC1 XHC2 XHC3 XHC4; do
        grep -q "$dev.*enabled" /proc/acpi/wakeup && echo "$dev" > /proc/acpi/wakeup
        done
        # 健壮的防卡死挂载处理：对 /home/lk/D 执行 Lazy Umount（懒卸载）
        # 懒卸载会立即将目录从文件系统树中分离，让系统得以顺利睡眠，而不会因为进程占用引发死锁
        /run/current-system/sw/bin/umount -l /home/lk/D 2>/dev/null || true
        # 杀掉用户高耗能或卡挂载进程（以 root 权限直接向 lk 用户精确发送信号，不使用 su，防止 PAM 锁定）
        /run/current-system/sw/bin/pkill -9 -u lk -x 'qq|chrome|zen|vscode' 2>/dev/null || true
        '';
        # ----- 唤醒后执行（root 权限） -----
        resumeCommands = ''
        # 统一延迟 1 秒，等待声卡、网卡、蓝牙硬件彻底通电复位，避免瞬态"噗"声和初始化冲突
        sleep 1
        # 启动 MPD
        ${pkgs.systemd}/bin/systemctl start mpd
        # 开启蓝牙
        ${pkgs.bluez}/bin/bluetoothctl power on
        # 开启 WiFi
        ${pkgs.networkmanager}/bin/nmcli radio wifi on
        # 恢复声音并消除扬声器"滋滋"声（先解除静音，再通过两次 toggle 强制刷新声卡寄存器状态）
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
        # 注意：强制设置 PCI 设备的 power/control="on" 可能会阻止显卡在全局挂起时降级供电，
        # 导致某些主板/内核无法完成 suspend。如果依然睡死，请保持下方注释状态。
        services.udev.extraRules = ''
        # ACTION=="suspend", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x1681", ATTR{power/control}="on"
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
        services.printing.enable = false;
        services.avahi.enable = false;
        services.geoclue2.enable = false;
        services.packagekit.enable = false;
        services.power-profiles-daemon.enable = false;
        services.gnome.gnome-keyring.enable = true;
        services.speechd.enable = false;
}
