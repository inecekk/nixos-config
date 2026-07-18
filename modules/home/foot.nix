# modules/home/foot.nix
# ==========================================
# Foot 终端模拟器配置
# ==========================================
{ ... }:
{
  xdg.configFile."foot/foot.ini".text = ''
    [main]
    font=JetBrains Mono:size=12
    pad=3x3 center
    selection-target=clipboard
    horizontal-letter-offset=0
    vertical-letter-offset=0
    resize-delay-ms=10  # 平铺式合成器(niri)下调整窗口更跟手,默认 100ms
    word-delimiters= ,│`|:"'()[]{}<>@%  # 扩展分词符,双击更容易选中完整路径/URL
    bold-text-in-bright=yes  # 部分工具用加粗表示亮色,开启后配色更准确,这个选项在 [main] 下

    [scrollback]
    lines=10000  # 默认只有 1000 行,日志/编译输出很容易翻不到

    [csd]
    preferred=none  # 关闭标题栏

    [colors-dark]
    alpha=0.6  # 整个窗口背景透明度
    # blur=yes  # 毛玻璃
    foreground=e0e0e0
    background=000000
    cursor=000000 e0e0e0  # 光标前景
    selection-background=000000  # 与背景色相同,靠反色文字提示选中范围
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
