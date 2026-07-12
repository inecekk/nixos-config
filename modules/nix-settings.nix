# modules/nix-settings.nix
# ==========================================
# Nix 包管理器设置：镜像源、缓存密钥、实验特性、垃圾回收
# ==========================================
{ ... }:
{
  nix = {
    settings = {
      # 替代下载源：清华镜像优先（国内更稳定）+ 官方缓存 + nix-community 缓存
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      # 单个源连接超时缩短到5秒，避免卡在解析失败的域名上
      connect-timeout = 5;
      # 某个源不可用时自动跳过，继续用其他源，不再直接报错终止
      fallback = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
