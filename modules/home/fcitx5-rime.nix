# modules/home/fcitx5-rime.nix
# ==========================================
# fcitx5 + Rime 中文输入法自定义方案
# 启用 rime-ice 雾凇词库，并开启双拼·小鹤音形
# ==========================================
{ ... }:

{
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
}
