# modules/home/shell-tools.nix
# ==========================================
# 终端与输入法：foot + fcitx5
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
    alpha=0.65
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
  # ---------- fcitx5 输入法 ----------
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
  #      qt6Packages.fcitx5-chinese-addons
        (fcitx5-rime.override {
          rimeDataPkgs = [ rime-ice ];
        })
      ];
    };
  };
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
  home.sessionVariables = {
    QT_IM_MODULE = "fcitx";
    GLOG_minloglevel = "3";
    GLOG_logtostderr = "0";
    GLOG_log_dir = "/dev/null";
  };


}
