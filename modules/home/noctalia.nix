# modules/home/noctalia.nix
{ inputs, ... }:
{
        imports = [ inputs.noctalia.homeModules.default ];

        programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = {
        theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
        };
        
        # --- 壁纸配置 ---
        wallpaper = {
            enabled = true;
            mode = "fill"; # 这里设置为 fill (全屏铺满并裁剪)
        };

        # --- 截图配置 (根据 Noctalia 标准配置项添加) ---
        screenshot = {
            directory = "/home/lk/Pictures/Screenshots"; # 在这里自定义你的截图目录
        };
        };
        };
}
