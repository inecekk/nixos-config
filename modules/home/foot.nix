# modules/home/foot.nix
# ==========================================
# Foot 终端模拟器配置
# ==========================================
{ ... }:
{
  xdg.configFile."foot/foot.ini".text = ''
    [main]
    # 字体与大小
    font=JetBrains Mono,Symbols Nerd Font Mono:size=16
    # 内边距，4x4 像素，居中
    pad=4x4 center
    # 选中文本后自动复制到系统剪贴板
    selection-target=clipboard
    horizontal-letter-offset=0
    vertical-letter-offset=0

    [csd]
    # 关闭标题栏（额头），不显示窗口标题和最小化/最大化/关闭按钮
    # 注意：这是独立的 [csd] 段，不是写在 [main] 里面
    preferred=none

    [colors-dark]
    # 整个终端窗口背景的透明度（0.0 全透明，1.0 不透明）
    alpha=0.5
    # 背景模糊（部分合成器/显卡支持才生效）
   # blur=yes
    # 前景色（正常文字颜色）
    foreground=e0e0e0
    # 背景色，foot 颜色字段必须是 6 位纯 RGB，不能带透明度后缀
    background=000000
    # 选中背景色：故意设成和终端背景一样的颜色（000000）
    # 因为整个窗口背景会跟随上面的 alpha 一起变透明，
    # 选中区域颜色和背景色相同，视觉上就像"选中框透明"，
    # 只靠文字变色来提示选中范围
    selection-background=000000
    # 选中时的文字颜色，改成醒目的颜色，避免选中后文字看不清
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
    style=beam
    blink=yes

    [mouse]
    hide-when-typing=yes
  '';
}
