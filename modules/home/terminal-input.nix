# modules/home/terminal-input.nix
# ==========================================
# 终端、输入法与 Fastfetch 极简配置
# ==========================================
{ pkgs, ... }:
{
  # 安装极速 fastfetch
  home.packages = [ pkgs.fastfetch ];

  # ---------- foot 终端 ----------
  xdg.configFile."foot/foot.ini".text = ''
    [main]
    font=JetBrains Mono:size=10, WenQuanYi Micro Hei:size=10
    dpi-aware=yes
    pad=3x1 center
    selection-target=clipboard
    resize-delay-ms=10
    bold-text-in-bright=yes
    [scrollback]
    lines=10000
    [csd]
    preferred=none
    [colors-dark]
    alpha=0.7
    blur=yes
    foreground=e0e0e0
    background=000000
    cursor=000000 e0e0e0
    selection-background=000000
    selection-foreground=ffffff
    regular0=2e3436
    regular1=cc0000
    regular2=4e9a06
    regular3=c4a000
    regular4=3465a4
    regular5=75507b
    regular6=06989a
    regular7=d3d7cf
    bright0=555753
    bright1=ef2929
    bright2=8ae234
    bright3=fce94f
    bright4=729fcf
    bright5=ad7fa8
    bright6=34e2e2
    bright7=eeeeec
    [bell]
    notify=no
    visual=no
    [cursor]
    style=block
    blink=no
    [mouse]
    hide-when-typing=yes
  '';

  # ---------- fastfetch 配置（零延迟、卡片式极简布局）----------
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": { "type": "small", "padding": { "top": 1, "left": 1, "right": 2 } },
      "display": { "separator": " ➜  " },
      "modules": [
        "title", "separator",
        { "type": "os", "key": "OS" },
        { "type": "kernel", "key": "Kernel" },
        { "type": "wm", "key": "WM" },
        { "type": "terminal", "key": "Terminal" },
        { "type": "cpu", "key": "CPU" },
        { "type": "gpu", "key": "GPU" },
        { "type": "memory", "key": "Memory" },
        { "type": "uptime", "key": "Uptime" },
        "break", "colors"
      ]
    }
  '';

  # ---------- fcitx5 输入法与雾凇小鹤双拼 ----------
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = [
        pkgs.qt6Packages.fcitx5-chinese-addons
        (pkgs.fcitx5-rime.override { rimeDataPkgs = [ pkgs.rime-ice ]; })
      ];
    };
  };

  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
      [GroupOrder]
      0=Default
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=rime
      [Groups/0/Items/0]
      Name=keyboard-us
      [Groups/0/Items/1]
      Name=rime
      [GroupList]
      0=Default
    '';
  };

  xdg.configFile."fcitx5/rime/default.custom.yaml" = {
    force = true;
    text = ''
      patch:
        __include: rime_ice_suggestion:/
        schema_list:
          - schema: rime_ice_flypy
        switches:
          - name: zh_simp
            reset: 1
    '';
  };

  home.sessionVariables = {
    GTK_IM_MODULE  = "fcitx";
    QT_IM_MODULE   = "fcitx";
    XMODIFIERS     = "@im=fcitx";
    GLFW_IM_MODULE = "ibus";
    GLOG_minloglevel = "3";
    GLOG_logtostderr = "0";
    GLOG_log_dir     = "/dev/null";
  };
}
