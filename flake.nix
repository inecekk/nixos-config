{
  description = "lk 的 NixOS + Niri + DankMaterialShell 配置"; # 系统配置说明


  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # NixOS 软件包源（unstable）


    home-manager = {
      url = "github:nix-community/home-manager"; # 用户环境管理
      inputs.nixpkgs.follows = "nixpkgs"; # 使用同一个 nixpkgs，减少重复依赖
    };


    zen-browser = {
      url = "github:youwen5/zen-browser-flake"; # Zen 浏览器
      inputs.nixpkgs.follows = "nixpkgs"; # 跟随主 nixpkgs
    };

   noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };
    daeuniverse = {
      url = "github:daeuniverse/flake.nix"; # dae 透明代理
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, home-manager, ... }@inputs:

  let
    system = "x86_64-linux"; # 当前设备架构
  in {

    nixosConfigurations.nixos =
      nixpkgs.lib.nixosSystem {

        inherit system; # 继承系统架构


        specialArgs = {
          inherit inputs; # 将 flake 输入传递给所有模块
        };


        modules = [

          ./hardware-configuration.nix # 硬件自动生成配置


          home-manager.nixosModules.home-manager # 启用 Home Manager


          {
            home-manager.useGlobalPkgs = true; # 使用系统 nixpkgs
            home-manager.useUserPackages = true; # 用户软件安装到 profile
              # 给 Home Manager 模块传递 flake inputs
  	    home-manager.extraSpecialArgs = {
    	    inherit inputs;
  };
          }


          ./modules/base.nix # 基础系统设置
          ./modules/nix-settings.nix # Nix 参数、flakes、垃圾回收
          ./modules/boot.nix # 引导和内核设置
          ./modules/networking.nix # 网络配置
          ./modules/system-services.nix # 系统服务
          ./modules/hardware.nix # 显卡、蓝牙等硬件
          ./modules/locale.nix # 中文环境和字体
          ./modules/users.nix # 用户账户
          ./modules/filesystems.nix # 文件系统挂载
          ./modules/packages.nix # 系统软件包
          ./modules/activation.nix # 激活脚本
          ./modules/dae.nix # dae 透明代理


          ./modules/home/default.nix # Home Manager 用户配置

        ];
      };
  };
}
