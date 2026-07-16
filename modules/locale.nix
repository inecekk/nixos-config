# modules/locale.nix
# ==========================================
# 本地化（中文环境）与字体配置
# ==========================================
{ pkgs, ... }:
{
        i18n = {
        defaultLocale = "zh_CN.UTF-8";
        inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = with pkgs; [
        fcitx5-gtk                          # GTK 输入法前端支持
        fcitx5-rime                         # 中州韵输入引擎
        rime-ice                            # 雾凇拼音方案
        qt6Packages.fcitx5-chinese-addons   # Qt6 中文输入附加组件
        qt6Packages.fcitx5-configtool       # Qt6 图形化配置工具
        ];
        };
        };

        fonts = {
        packages = with pkgs; [
        wqy_zenhei                   # 文泉正黑
        jetbrains-mono               # 原版等宽字体，无图标补丁，体积较小
        nerd-fonts.symbols-only      # 仅图标
        noto-fonts-color-emoji       # 彩色 emoji（emoji 字体本身不大，暂保留）
        ];

        fontconfig = {
        defaultFonts = {
        # 无衬线：中文优先，其次代码字体，图标兜底，最后 emoji
        sansSerif = [ "WenQuanYi Zen Hei Mono" "JetBrains Mono" "Symbols Nerd Font Mono" "Noto Color Emoji" ];
        serif = [ "WenQuanYi Zen Hei Mono" ];  # 未装衬线字体，退化用无衬线代替
        monospace = [ "JetBrains Mono" "Symbols Nerd Font Mono" "WenQuanYi Zen Hei Mono" ];
        emoji = [ "Noto Color Emoji" ];
        };
        antialias = true;                                   # 抗锯齿保留，高分屏下画质影响不大、开销很小
        hinting = { enable = false; };                       # 高分屏关闭 hinting：像素密度够高，用不上，减少渲染开销
        subpixel = { rgba = "none"; lcdfilter = "none"; };    # 关闭子像素渲染：高分屏+缩放下容易出彩边，改用灰度抗锯齿更干净
        };
        };
}
