# modules/home/mpv-fastfetch.nix
{ pkgs, ... }: 

{

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "gpu-next";
      keep-open = "yes";
      volume-max = "150";
      sub-auto = "fuzzy";
    };
    bindings = {
      "WHEEL_UP" = "add volume 5";
      "WHEEL_DOWN" = "add volume -5";
    };
    
    scripts = [
      pkgs.mpvScripts.mpris
    ];
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = { type = "auto"; padding = { top = 1; right = 4; }; };
      display = { separator = "  "; };
	modules = [
        "title"
        "separator"
        { type = "os"; key = "󱄅 系统"; }
        { type = "kernel"; key = "󰒋 内核"; }
        { type = "uptime"; key = "󰅐 开机时长"; }
        { type = "packages"; key = "󰏖 软件包"; }
        
        # 新增：中文环境/语言设置
        { type = "locale"; key = "󰇄 语言"; }
        # 新增：虚拟化检测
        { type = "initsystem"; key = "󰣖 systemd"; }
        { type = "terminal"; key = " 终端"; }
        { type = "terminalfont"; key = " 字体"; }
        
        "break"
        { type = "cpu"; key = " CPU"; }
        { type = "memory"; key = " 内存"; format = "{percentage} ({used} / {total})"; }
        "break"
        "disk"
        "break"
        { type = "display"; key = "󰍹 分辨率"; }
        { type = "localip"; key = "󰩟 内网IP"; showIpv4 = true; }
        { type = "publicip"; key = "󰖟 公网IP"; }
        "break"
        { type = "colors"; symbol = "block"; }
      ];

    };
  };
}
