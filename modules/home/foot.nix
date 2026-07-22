# modules/home/foot.nix
# ==========================================
# Foot 终端模拟器配置
# ==========================================
{ ... }: # 模块函数参数（当前未使用任何传入变量）
{
  xdg.configFile."foot/foot.ini".text = '' # 通过 XDG 将生成的 foot.ini 写入 ~/.config/foot/foot.ini
    [main] # 主配置段
    font=Sarasa Term SC:size=11
    pad=3x1 center # 内容区上下左右
    selection-target=clipboard # 选中文本自动复制到系统剪贴板（而非仅 primary selection）
    horizontal-letter-offset=0 # 字符水平偏移 0px（微调字间距）
    vertical-letter-offset=0 # 字符垂直偏移 0px（微调行高对齐）
    resize-delay-ms=10 # 窗口重绘延迟 10ms；niri 等平铺合成器下比默认 100ms 更跟手
    word-delimiters= ,│`|:"'()[]{}<>@% # 双击选词时的分界符集合，方便选中完整路径/URL
    bold-text-in-bright=yes # 加粗文本同时使用亮色变体，避免部分工具加粗后颜色失真

    [scrollback] # 回滚缓冲区配置段
    lines=10000 # 保留 10000 行历史（默认仅 1000，编译/日志易丢失）

    [csd] # 客户端装饰（标题栏）配置段
    preferred=none # 禁用 CSD 标题栏，由合成器或无边框模式接管

    [colors-dark] # 暗色主题配色段
    alpha=0.6 # 窗口整体背景透明度 60%
    # blur=yes # 毛玻璃模糊（已注释；需合成器支持 blur 才生效）
    foreground=e0e0e0 # 默认前景色（浅灰）
    background=000000 # 默认背景色（纯黑）
    cursor=000000 e0e0e0 # 光标颜色：前景黑、背景浅灰（与文字反色）
    selection-background=000000 # 选中区域背景色（与底色相同，靠反色文字标识选中范围）
    selection-foreground=ffffff # 选中区域前景色（白色，与黑色背景形成反色）
    regular0=2e3436 # ANSI 0 黑（深色）
    regular1=cc0000 # ANSI 1 红
    regular2=4e9a06 # ANSI 2 绿
    regular3=c4a000 # ANSI 3 黄
    regular4=3465a4 # ANSI 4 蓝
    regular5=75507b # ANSI 5 紫
    regular6=06989a # ANSI 6 青
    regular7=d3d7cf # ANSI 7 白（浅色）
    bright0=555753 # ANSI 8 亮黑
    bright1=ef2929 # ANSI 9 亮红
    bright2=8ae234 # ANSI 10 亮绿
    bright3=fce94f # ANSI 11 亮黄
    bright4=729fcf # ANSI 12 亮蓝
    bright5=ad7fa8 # ANSI 13 亮紫
    bright6=34e2e2 # ANSI 14 亮青
    bright7=eeeeec # ANSI 15 亮白

    [bell] # 响铃/提示配置段
    notify=no # 禁用系统通知式响铃
    visual=no # 禁用视觉闪烁提示

    [cursor] # 光标样式配置段
    style=beam # 光标形状为竖线
    blink=yes # 启用光标闪烁

    [mouse] # 鼠标行为配置段
    hide-when-typing=yes # 打字时自动隐藏鼠标指针
  '';
}
