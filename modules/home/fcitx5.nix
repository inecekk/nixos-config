# modules/home/fcitx5.nix
# ==========================================
# fcitx5 输入法 + 小鹤双拼配置
# ==========================================
{ pkgs, ... }:
{
  # 不再依赖 rime-ice（其打包路径导致 double_pinyin_flypy 无法部署），
  # 改用官方 rime 基础数据 + 独立小鹤双拼 schema 文件
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;  # niri 是 wayland 合成器，必须启用
      addons = with pkgs; [ fcitx5-rime ];  # 用默认 rimeDataPkgs（rime-data）
    };
  };

  # 小鹤双拼 schema 文件
  xdg.dataFile."fcitx5/rime/double_pinyin_flypy.schema.yaml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-double-pinyin/master/double_pinyin_flypy.schema.yaml";
    sha256 = "sha256-a1Iqfpy3Q0dCh6FGeFl0YL0SQ2nzJXPdY+jwTnxB1Lk=";
  };

  # --------------------------------------------------------------------------
  # 核心修復：針對小鶴雙拼方案（double_pinyin_flypy）的專屬補丁
  # 強制開啟 zh_simp（簡體），並修正狀態欄標籤為 [ 中, 英 ]
  # --------------------------------------------------------------------------
  xdg.dataFile."fcitx5/rime/double_pinyin_flypy.custom.yaml" = {
    force = true;
    text = ''
      patch:
        "switches/@0/reset": 0        # ascii_mode: 0 = 中文, 1 = 英文
        "switches/@0/states": ["中", "英"]
        "switches/@1/reset": 1        # zh_simp (簡體): 1 = 預設啟用簡體!
        "switches/@1/states": ["漢字", "汉字"]
    '';
  };

  # 全局預設選單補丁
  xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
    force = true;
    text = ''
      patch:
        schema_list:
          - schema: double_pinyin_flypy   # 小鹤双拼
    '';
  };

  # Profile 狀態文件
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

  home.sessionVariables = {
    GTK_IM_MODULE  = "fcitx";
    QT_IM_MODULE   = "fcitx";
    XMODIFIERS     = "@im=fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
