{ pkgs, ... }:

let
        scripts = import ../scripts.nix { inherit pkgs; };
        niriBinds = builtins.readFile ./niri-binds.kdl;
in
{
        xdg.configFile."niri/config.kdl" = {
        force = true;
        # 【重点在这里：一定要写 text = '' 】
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
        skip-at-startup
        }

        window-rule {
        match app-id="code"
        opacity 0.8
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
        off
        }
        shadow {
        softness 30
        spread 5
        offset x=0 y=5
        color "#0007"
        }
        }

        window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
        }

        spawn-at-startup "qs" "-c" "noctalia-shell"
        spawn-at-startup "sh" "-c" "sleep 3 && sudo systemctl start dae.service"

        // 引入分离的快捷键
        ${niriBinds}
        '';
        };
}
