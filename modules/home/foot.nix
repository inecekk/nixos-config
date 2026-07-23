# modules/home/foot.nix
# ==========================================
# Foot 终端模拟器配置
# ==========================================
{ ... }:
{
  xdg.configFile."foot/foot.ini".text = ''
    [main]
    font=JetBrains Mono:size=10, WenQuanYi Micro Hei:size=10 # 主字体：英文字体优先 JetBrains Mono，中文回退微米黑
    dpi-aware=yes # 开启高分屏 DPI 自适应，确保 Wayland 缩放时文字锐利
    pad=3x1 center # 终端内边距：上下 3px，左右 1px，内容居中
    selection-target=clipboard # 选中的文本自动复制到系统剪贴板
    horizontal-letter-offset=0 # 字符水平间距微调
    vertical-letter-offset=0 # 字符垂直行距微调
    resize-delay-ms=10 # 窗口重绘延迟 10ms，在平铺合成器下更跟手
    word-delimiters= ,│`|:"'()[]{}<>@% # 双击选词时的分界符集合
    bold-text-in-bright=yes # 加粗文本同时使用亮色变体，防止颜色失真

    [scrollback]
    lines=10000 # 回滚缓冲区行数设为 10000 行，避免查看长日志时丢失

    [csd]
    preferred=none # 禁用客户端自带标题栏（CSD），由窗口合成器接管

    [colors-dark]
    alpha=0.6 # 终端窗口整体背景透明度 60%
    foreground=e0e0e0 # 默认前景色（浅灰色文字）
    background=000000 # 默认背景色（纯黑色）
    cursor=000000 e0e0e0 # 光标颜色：前景黑、背景浅灰（与文字反色）
    selection-background=000000 # 选中区域背景色（与底色相同，靠反色文字辨识）
    selection-foreground=ffffff # 选中区域前景色（纯白色）
    regular0=2e3436 # ANSI 标准黑
    regular1=cc0000 # ANSI 标准红
    regular2=4e9a06 # ANSI 标准绿
    regular3=c4a000 # ANSI 标准黄
    regular4=3465a4 # ANSI 标准蓝
    regular5=75507b # ANSI 标准紫
    regular6=06989a # ANSI 标准青
    regular7=d3d7cf # ANSI 标准白
    bright0=555753 # ANSI 高亮黑
    bright1=ef2929 # ANSI 高亮红
    bright2=8ae234 # ANSI 高亮绿
    bright3=fce94f # ANSI 高亮黄
    bright4=729fcf # ANSI 高亮蓝
    bright5=ad7fa8 # ANSI 高亮紫
    bright6=34e2e2 # ANSI 高亮青
    bright7=eeeeec # ANSI 高亮白

    [bell]
    notify=no # 禁用系统通知式响铃
    visual=no # 禁用屏幕视觉闪烁提示

    [cursor]
    style=block # 光标形状为实心块状
    blink=no # 关闭光标闪烁，减少视觉干扰

    [mouse]
    hide-when-typing=yes # 键盘打字时自动隐藏鼠标指针
  '';
}
