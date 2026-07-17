# modules/home/fcitx5-rime.nix
# ==========================================
# fcitx5 + Rime 中文输入法自定义方案
# 使用双拼·小鹤音形（double_pinyin_flypy）+ rime-ice 词库
# ==========================================
{ ... }:

{
  xdg.configFile."fcitx5/rime/default.custom.yaml" = {
    force = true;
    text = ''
      patch:
      schema_list:
      - schema: double_pinyin_flypy
      - schema: rime_ice
      switcher/hotkeys:
      - F4
    '';
  };
}
