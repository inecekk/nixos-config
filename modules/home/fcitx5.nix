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

  # 小鹤双拼 schema 文件（Rime 官方 rime-double-pinyin 仓库，稳定可靠）
  xdg.dataFile."fcitx5/rime/double_pinyin_flypy.schema.yaml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rime/rime-double-pinyin/master/double_pinyin_flypy.schema.yaml";
    sha256 = "sha256-a1Iqfpy3Q0dCh6FGeFl0YL0SQ2nzJXPdY+jwTnxB1Lk=";
  };

  # profile 是 fcitx5 运行时状态文件，首次启动后会被自身重写，
  # 用 force = true 确保每次 home-manager switch 都强制覆盖为声明式配置
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

  # default.custom.yaml：
  # 注意：fcitx5-rime 的 rime 用户数据目录在 ~/.local/share/fcitx5/rime/
  # （XDG_DATA_HOME），不是 ~/.config/fcitx5/rime/，必须用 xdg.dataFile
  # 而非 xdg.configFile，否则 Rime 读不到这个补丁文件。
  xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
    force = true;
    text = ''
      patch:
        schema_list:
          - schema: double_pinyin_flypy   # 小鹤双拼
        switches:
          - name: ascii_mode
            states: [ 中, 英 ]
            reset: 0        # 0 = 默认中文模式，1 = 默认西文/英文模式
          - name: zh_simp
            states: [ 繁, 简 ]
            reset: 1        # 1 = 默认简体，0 = 默认繁体
    '';
  };

  home.sessionVariables = {
    GTK_IM_MODULE  = "fcitx";
    QT_IM_MODULE   = "fcitx";
    XMODIFIERS     = "@im=fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
