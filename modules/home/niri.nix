{ pkgs, ... }:
let
        scripts = import ../scripts.nix { inherit pkgs; };
        niriBinds = builtins.readFile ./niri-binds.kdl;
in
{
        xdg.configFile."niri/config.kdl" = {
        force = true;
        text = ''
        input {
        keyboard {
        numlock
        }
        touchpad {
        tap
        natural-scroll
        }
        }
        cursor {
        xcursor-size 24
        }
        output "eDP-1" {
        scale 2.0
        }
        hotkey-overlay {
        skip-at-startup  // 跳过启动时的快捷键提示,省一点点渲染开销
        }
        window-rule {
        match app-id="code"
        opacity 0.8  // 半透明需要额外合成一层,对内存影响很小,主要吃 GPU/CPU
        }
        layout {
        gaps 16
        preset-column-widths {
        proportion 0.25
        proportion 0.5
        proportion 0.75
        }
        default-column-width {
        proportion 0.5
        }
        focus-ring {
        width 4
        active-color "#a0e8af20"
        inactive-color "#50505020"
        }
        border {
        off  // 已关闭边框
        }
        shadow {
        softness 30
        spread 5
        offset x=0 y=5
        color "#0007"
        }
        }
        window-rule {
        geometry-corner-radius 12  // 圆角同样是每帧渲染开销,不是内存
        clip-to-geometry true
        }
        spawn-at-startup "qs" "-c" "noctalia-shell"
        // dae 是网络代理服务,常驻内存一般不大(几 MB~几十 MB)
        spawn-at-startup "sh" "-c" "sleep 3 && sudo systemctl start dae.service"
        // 引入分离的快捷键配置文件
        ${niriBinds}
        '';
        };
}
