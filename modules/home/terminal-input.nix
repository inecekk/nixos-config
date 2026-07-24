# modules/home/terminal-input.nix
{ pkgs, ... }:
{
  xdg.configFile."foot/foot.ini".text = ''
    [main]
    font=JetBrains Mono:size=10, WenQuanYi Micro Hei:size=10
    dpi-aware=yes
    pad=3x1 center
    selection-target=clipboard
    [csd]
    preferred=none
    [colors-dark]
    alpha=0.65
    foreground=e0e0e0
    background=000000
    [bell]
    notify=no
    visual=no
    [cursor]
    style=block
    blink=no
  '';

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-rime
        qt6Packages.fcitx5-chinese-addons
      ];
    };
  };

  xdg.configFile."fcitx5/rime/default.custom.yaml" = {
    force = true;
    text = ''
      patch:
        schema_list:
          - schema: double_pinyin_flypy
        switcher/hotkeys: [F4]
        menu/page_size: 5
    '';
  };

  xdg.configFile."fcitx5/rime/double_pinyin_flypy.schema.yaml" = {
    force = true;
    text = ''
      schema:
        schema_id: double_pinyin_flypy
        name: 小鹤双拼
      switches:
        - name: ascii_mode
          states: [中文, 西文]
          reset: 0
      engine:
        processors: [ascii_composer, recognizer, key_binder, speller, punctuator, selector, navigator, express_editor]
        segmentors: [ascii_segmentor, matcher, abc_segmentor, punct_segmentor, fallback_segmentor]
        translators: [punct_translator, table_translator]
        filters: [simplifier, uniquifier]
      speller:
        alphabet: "zyxwvutsrqponmlkjihgfedcba;"
        delimiter: " '"
        algebra:
          - erase/^xx$/
          - derive/^([jqxy])u$/$1v/
          - xlit/ch/i/
          - xlit/sh/u/
          - xlit/zh/v/
          - xform/^([a-z])ai$/$1l/
          - xform/^([a-z])an$/$1j/
          - xform/^([a-z])ang$/$1h/
          - xform/^([a-z])ao$/$1k/
          - xform/^([a-z])ei$/$1z/
          - xform/^([a-z])en$/$1f/
          - xform/^([a-z])eng$/$1g/
          - xform/^([a-z])ia$/$1x/
          - xform/^([a-z])ian$/$1m/
          - xform/^([a-z])iang$/$1d/
          - xform/^([a-z])iao$/$1c/
          - xform/^([a-z])ie$/$1p/
          - xform/^([a-z])in$/$1n/
          - xform/^([a-z])ing$/$1y/
          - xform/^([a-z])iong$/$1s/
          - xform/^([a-z])iu$/$1q/
          - xform/^([a-z])ong$/$1s/
          - xform/^([a-z])ou$/$1b/
          - xform/^([a-z])ua$/$1x/
          - xform/^([a-z])uai$/$1k/
          - xform/^([a-z])uan$/$1r/
          - xform/^([a-z])uang$/$1d/
          - xform/^([a-z])ue$/$1t/
          - xform/^([a-z])ui$/$1v/
          - xform/^([a-z])un$/$1p/
          - xform/^([a-z])uo$/$1o/
          - xform/^([a-z])ve$/$1t/
          - abbrev/^([a-z]).+$/$1/
      translator:
        dictionary: luna_pinyin
        enable_sentence: true
        enable_user_dict: true
      punctuator:
        import_preset: default
      key_binder:
        import_preset: default
      recognizer:
        import_preset: default
    '';
  };

  home.sessionVariables = {
    QT_IM_MODULE = "fcitx";
    GLOG_minloglevel = "3";
    GLOG_logtostderr = "0";
    GLOG_log_dir = "/dev/null";
  };
}
