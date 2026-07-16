# modules/home/dms.nix
# =================================================================================
# DankMaterialShell（DMS）
# =================================================================================
# 功能：
#   • 状态栏
#   • 应用启动器
#   • 通知中心
#   • 壁纸管理
#
# Niri 通过 config.kdl 管理，不使用 Home Manager 的
# wayland.windowManager.niri 模块，因此不要在这里写
# spawn-at-startup。
# =================================================================================

{ inputs, ... }:

{
        imports = [
        inputs.dms.homeModules.dank-material-shell
        ];

        programs.dank-material-shell = {
        enable = true;      # 启用 DankMaterialShell
        };
}
