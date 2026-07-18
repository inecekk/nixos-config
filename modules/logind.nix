# modules/logind.nix
{ ... }:
{
  # 合盖、电源键都不再由 logind 直接处理
  # 全部交给 niri（switch-events）或 Noctalia 菜单调用 sessionMenu.lockAndSuspend
  # 避免多条路径并行触发 suspend 造成竞态、漏锁屏
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
  };
}
