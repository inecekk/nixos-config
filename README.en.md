# Personal NixOS Configuration

A personal NixOS system configuration managed via Flakes, using [niri](https://github.com/YaLTeR/niri) as the Wayland compositor, with home-manager for user-level environment management.

> 中文版: [README.md](./README.md)

## Directory Structure

```
.
├── dot-bashrc                  # bash config template
├── flake.lock                  # flake dependency lockfile
├── flake.nix                   # flake entry point, defines system & home-manager outputs
├── hardware-configuration.nix  # auto-generated hardware config (via nixos-generate-config)
├── install.sh                  # one-shot install/deploy script
├── modules
│   ├── activation.nix          # system activation-stage config
│   ├── base.nix                # base system config (locale, shell enablement, etc.)
│   ├── boot.nix                # bootloader config
│   ├── dae.nix                 # dae transparent proxy service config
│   ├── filesystems.nix         # filesystems & mount points
│   ├── hardware.nix            # GPU driver, bluetooth, etc.
│   ├── home                    # home-manager user-level config
│   │   ├── default.nix         # entry point, aggregates all submodule imports
│   │   ├── dms.nix.bak         # deprecated: DMS-related config (kept as backup)
│   │   ├── fcitx5-rime.nix     # fcitx5 + rime Chinese input method
│   │   ├── fish.nix            # fish shell config (aliases, functions, env vars)
│   │   ├── foot.nix            # foot terminal emulator config
│   │   ├── mako-mpd.nix        # mako notifications + mpd music player
│   │   ├── mpv-fastfetch.nix   # mpv player + fastfetch system info
│   │   ├── niri-binds.kdl      # niri keybindings (separate file, imported by niri.nix)
│   │   ├── niri.nix            # niri compositor main config
│   │   ├── noctalia.nix        # Noctalia bar/shell config (currently active)
│   │   ├── rnote.nix           # rnote handwriting app config
│   │   ├── waybar.nix.bak      # deprecated: waybar config (kept for reference)
│   │   └── yambar.nix.bak      # deprecated: yambar config (kept for reference)
│   ├── locale.nix              # system locale config
│   ├── networking.nix          # networking config (NetworkManager, etc.)
│   ├── nix-settings.nix        # Nix daemon settings (experimental features, caches, etc.)
│   ├── packages.nix            # system-level package list
│   ├── scripts.nix             # shared custom scripts used by other modules
│   ├── system-services.nix     # system services: sleep/resume, power management, audio, display manager, etc.
│   └── users.nix               # user account definitions
├── pkgs
│   └── dae-v2.nix              # custom derivation for the dae proxy
├── README.md                   # Chinese version of this document
├── README.en.md                # this document
└── result -> /nix/store/...    # build output symlink (not version-controlled)
```

## Core Design

### Window Management: niri

Uses [niri](https://github.com/YaLTeR/niri), a scrollable-tiling Wayland compositor. Configured in `modules/home/niri.nix`, with keybindings kept separately in `modules/home/niri-binds.kdl`. Rounded corners (`geometry-corner-radius`), shadows, and focus rings are enabled; `layout.gaps` / `layout.struts` control inter-window spacing and overall screen-edge padding respectively. A `layer-rule` explicitly disables compositor background blur (`ext-background-effects`) for Noctalia's bar/panel/dock/notification/OSD surfaces — requires niri ≥ 26.04.

### Status Bar: Noctalia (current) / waybar, yambar (deprecated)

Currently using [Noctalia](https://docs.noctalia.dev/) (a quickshell/QML-based desktop shell), configured in `modules/home/noctalia.nix`. `waybar` (C++/GTK, feature-rich but higher memory footprint) and `yambar` (C, extremely lightweight but no longer maintained upstream) were both evaluated; their configs are kept with a `.bak` suffix for reference and are not wired into `default.nix`'s `imports`.

### Sleep & Power Management

`modules/system-services.nix` handles:

- **Preemptive pre-suspend mute**: via `systemd.services.pre-suspend-mute` (ordered before `sleep.target`) — stops MPD, suspends the PipeWire audio node, and physically mutes the sound card before the system freezes, avoiding leftover audio replay glitches on suspend.
- **Suspend-time cleanup**: `powerManagement.powerDownCommands` turns off bluetooth/WiFi, lazy-unmounts mount points that could deadlock suspend, and terminates high-power or GPU-context-holding user processes (`SIGTERM` first, then `SIGKILL`, to avoid racing with GPU suspend).
- **Keyboard-only wake source**: instead of blanket-disabling ACPI wakeup on all USB controllers (the root cause of the machine becoming unwakeable after long sleeps), the controller hosting the keyboard is dynamically detected and only its wakeup capability is preserved.
- **Resume-time restoration**: `resumeCommands` restores networking, bluetooth, and audio (including a register-refresh trick to avoid speaker pop/static noise).

### Network Proxy: dae

`modules/dae.nix` + `pkgs/dae-v2.nix` provide a transparent proxy service based on [dae](https://github.com/daeuniverse/dae), started with a delay via niri's `spawn-at-startup` to avoid contending for resources with other startup items.

### Shell: fish (login shell)

Enabled system-wide via `programs.fish.enable = true;` (`modules/base.nix`); the login shell is set via `users.defaultUserShell = pkgs.fish;` or `users.users.lk.shell = pkgs.fish;` (`modules/users.nix`). User-level config (aliases, proxy toggle functions, Starship prompt, auto-starting niri on tty1, etc.) lives in `modules/home/fish.nix`.

### Input Method & Other Apps

- `fcitx5-rime.nix`: Chinese input method (fcitx5 + rime engine).
- `mako-mpd.nix`: desktop notifications (mako) and music playback (mpd).
- `foot.nix`: lightweight terminal emulator.
- `mpv-fastfetch.nix` / `rnote.nix`: media playback and handwriting-note config.

## Common Commands

```bash
# Syntax & eval check only, no actual switch (alias: ntest)
sudo nixos-rebuild dry-build --flake .

# Apply the configuration
sudo nixos-rebuild switch --flake .

# New files must be tracked by git before flakes can see them
git add -A

# Validate niri config syntax
niri validate

# Manually test a user-space program (e.g. the status bar) to see errors directly
yambar    # or: qs -c noctalia-shell
```

## Known Gotchas

- **Flakes only see git-tracked files**: a newly created file not yet `git add`-ed will cause `nixos-rebuild` to fail with `Path ... is not tracked by Git` — always track before building.
- **yambar is no longer maintained upstream** (marked "NOT DEVELOPED ANYMORE" by the author on its [official repo](https://codeberg.org/dnkl/yambar)); no confirmed actively-maintained successor fork exists as of writing. `yambar.nix.bak` is kept for historical reference only.
- **Changing the login shell requires system-level enablement too**: e.g. before setting `users.users.lk.shell = pkgs.fish;`, `programs.fish.enable = true;` must already be set in some system module, or `nixos-rebuild` will be blocked by a built-in assertion.
- **KDL config comments use `//` or `/* */`, not `#`**; multiple sibling nodes on one line must be separated by a semicolon or newline — whitespace alone is not enough.
