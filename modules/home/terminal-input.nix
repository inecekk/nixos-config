# modules/home/terminal-input.nix
# ==========================================
# 终端与输入法：foot + 纯 Rime 输入法引擎
# ==========================================
{ pkgs, ... }:
{
  # ---------- foot 终端 ----------
  xdg.configFile."foot/foot.ini".text = ''
    [main]
    font=JetBrains Mono:size=10, WenQuanYi Micro Hei:size=10
    dpi-aware=yes
    pad=3x1 center
    selection-target=clipboard
    horizontal-letter-offset=0
    vertical-letter-offset=0
    resize-delay-ms=10
    word-delimiters= ,│`|:"'()[]{}<>@%
    bold-text-in-bright=yes
    [scrollback]
    lines=10000
    [csd]
    preferred=none
    [colors-dark]
    alpha=0.7
    blur=yes #启用模糊
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

  # ---------- fcitx5 输入法 (纯 Rime，无多余设置组件) ----------
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = [
        (pkgs.fcitx5-rime.override {
          rimeDataPkgs = [ pkgs.rime-ice ];
        })
      ];
    };
  };

  # ---------- Rime 小鹤双拼配置 ----------
  xdg.configFile."fcitx5/rime/default.custom.yaml" = {
    force = true;
    text = ''
      patch:
        __include: rime_ice_suggestion:/
        schema_list:
          - schema: rime_ice
          - schema: double_pinyin_flypy
        switcher/hotkeys:
          - F4
    '';
  };

  # ---------- 输入法环境变量 ----------
  home.sessionVariables = {
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    GLOG_minloglevel = "3";
    GLOG_logtostderr = "0";
    GLOG_log_dir = "/dev/null";
  };
}
