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
        mode "3200x2000@90"
      }
      hotkey-overlay {
        skip-at-startup
      }
      overview {
        zoom 0.5
      }
      window-rule {
        match app-id="code"
        opacity 0.85
      }
      layer-rule {
        match namespace="^noctalia-wallpaper$"
        place-within-backdrop true
      }
      layout {
        background-color "transparent"
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
        struts {
          left 1
          right 1
          top 0
          bottom 0
        }
      }
      window-rule {
        match is-window-cast-target=false
        geometry-corner-radius 12
        clip-to-geometry true
      }
      layer-rule {
        match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"
        background-effect {
          xray false
          blur true
        }
      }
      switch-events {
        lid-close {
          spawn "qs" "-c" "noctalia-shell" "ipc" "call" "sessionMenu" "lockAndSuspend"
        }
      }
      spawn-at-startup "qs" "-c" "noctalia-shell"
      ${niriBinds}
    '';
  };
}
