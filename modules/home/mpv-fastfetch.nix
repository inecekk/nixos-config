# modules/home/mpv-fastfetch.nix
{ pkgs, ... }: 

{

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "gpu-next";
      keep-open = "yes";
      volume-max = "150";
      sub-auto = "fuzzy";
    };
    bindings = {
      "WHEEL_UP" = "add volume 5";
      "WHEEL_DOWN" = "add volume -5";
    };
    
    scripts = [
      pkgs.mpvScripts.mpris
    ];
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "small";
        padding = {
          top = 1;
          left = 1;
        };
      };
      display = {
        separator = "   ";
      };
      modules = [
        # Title with custom colors
        {
          type = "title";
          format = "    {#38;2;243;139;168} {#38;2;249;226;175}{user-name}{#38;2;205;214;244}@{#38;2;137;180;250}{host-name}";
        }
        # Separator line
        {
          type = "custom";
          format = "    {#38;2;203;166;247}──────────────────────────────{#}";
        }
        # OS
        {
          type = "os";
          key = "    {#38;2;243;139;168}{#} OS       ";
          format = "{3} {12}";
        }
        # Host
        {
          type = "host";
          key = "    {#38;2;250;179;135}󰌢{#} Host     ";
          format = "{2} {3}";
        }
        # Kernel
        {
          type = "kernel";
          key = "    {#38;2;249;226;175}{#} Kernel   ";
        }
        # Uptime
        {
          type = "uptime";
          key = "    {#38;2;166;227;161}󰅐{#} Uptime   ";
        }
        # Packages
        {
          type = "packages";
          key = "    {#38;2;148;226;213}󰏖{#} Packages ";
        }
        "break"
        # CPU
        {
          type = "cpu";
          key = "    {#38;2;137;180;250}{#} CPU      ";
          format = "{1}";
        }
        # GPU
        {
          type = "gpu";
          key = "    {#38;2;203;166;247}󰢮{#} GPU      ";
          format = "{2}";
        }
        # Memory
        {
          type = "memory";
          key = "    {#38;2;245;194;231}{#} Memory   ";
        }
        # Disk
        {
          type = "disk";
          key = "    {#38;2;180;190;254}{#} Disk (/) ";
        }
        "break"
        # DE
        {
          type = "de";
          key = "    {#38;2;137;220;235}{#} DE       ";
        }
        # WM
        {
          type = "wm";
          key = "    {#38;2;137;180;250}{#} WM       ";
        }
        # Shell
        {
          type = "shell";
          key = "    {#38;2;166;227;161}{#} Shell    ";
        }
        # Terminal
        {
          type = "terminal";
          key = "    {#38;2;249;226;175}{#} Terminal ";
        }
        # Local IP
        {
          type = "localip";
          key = "    {#38;2;148;226;213}󰩟{#} Local IP ";
          compact = true;
        }
        "break"
        # Colors
        {
          type = "colors";
          key = "    {#38;2;203;166;247}{#} Colors   ";
          symbol = "circle";
        }
      ];
    };
  };
}
