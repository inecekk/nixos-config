# modules/nix-settings.nix
# ==========================================
# Nix 包管理器设置：镜像源、缓存密钥、实验特性、垃圾回收
# ==========================================

{...}: {

  nix = {

    settings = {

      # 替代下载源
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];


      # Flake支持
      experimental-features = [
        "nix-command"
        "flakes"
      ];


      # 自动优化store硬链接
      auto-optimise-store = true;


      # 优化参数
      builders-use-substitutes = true;
      max-jobs = "auto";
      cores = 0;


      # 下载超时
      connect-timeout = 5;

      # fallback
      fallback = true;
    };


    # 垃圾回收
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

  };
}
