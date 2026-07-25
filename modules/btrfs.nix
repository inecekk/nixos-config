{ ... }:

{
  # Btrfs 自动数据完整性检查
  # 每月执行一次 scrub，检查 checksum 错误
  services.btrfs.autoScrub = {
    enable = true;

    # 执行周期
    interval = "monthly";

    # 检查根文件系统
    fileSystems = [
      "/"
    ];
  };
}
