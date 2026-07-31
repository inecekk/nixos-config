{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      # ✅ 禁用自动登录，启用 agreety 进行密码认证
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd '${pkgs.niri}/bin/niri-session'";
        user = "lk";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
