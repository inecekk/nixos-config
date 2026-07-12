{ config, pkgs, ... }:

{
  home.packages = [ pkgs.rnote ];

  # 强制生成配置文件，确保每次 rebuild 都会覆盖为你的设定
  home.file.".config/rnote/config.toml" = {
    text = ''
      # 对应你截图中的页面与文档设置
      [page]
      width = 20.0
      height = 80.0
      unit = "cm"
      dpi = 96
      orientation = "portrait"

      [document]
      layout = "fixed"
      show_grid = false
      background_color = "#FFFFFF"
      
      [document.texture]
      type = "line"
      color = "#FF8C00" # 对应你截图中的纹理颜色
      width = 32
      height = 60
    '';
  };
}
