# modules/locale.nix
# ==========================================
# 本地化（中文环境）与字体配置（精简版）
# ==========================================
{ pkgs, ... }:

{
  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        fcitx5-rime
        rime-ice
        qt6Packages.fcitx5-chinese-addons
        qt6Packages.fcitx5-configtool
      ];
    };
  };

  # ==========================================
  # 字体配置（仅中文 + 必备图标）
  # ==========================================
  fonts = {
    packages = with pkgs; [
      # --- 中文字体 ---
      noto-fonts-cjk-sans      # Noto 无衬线中文
      noto-fonts-cjk-serif     # Noto 衬线中文（备选）
      
      # --- 图标字体（终端/状态栏需要） ---
      font-awesome             # 图标字体（Niri/Noctalia 需要）
      noto-fonts-color-emoji   # 彩色表情（修复：使用正确的包名）
      
      # 英文字体使用系统自带的 dejavu，不额外安装
    ];
    
    fontconfig = {
      enable = true;
      
      defaultFonts = {
        # 无衬线字体
        sansSerif = [
          "Noto Sans CJK SC"    # 中文主字体
          "DejaVu Sans"         # 系统自带英文后备
        ];
        
        # 衬线字体
        serif = [
          "Noto Serif CJK SC"   # 中文衬线
          "DejaVu Serif"        # 系统自带英文后备
        ];
        
        # 等宽字体（终端/代码）
        monospace = [
          "Noto Sans Mono CJK SC"  # 中文等宽
          "DejaVu Sans Mono"       # 系统自带英文后备
        ];
        
        # 表情字体
        emoji = [
          "Noto Color Emoji"    # 彩色表情
        ];
      };
      
      # 渲染优化
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };
  };
}
