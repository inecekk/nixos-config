{
  services.greetd = {
    enable = true;
    settings = {
      default_session = 
{

        # 使用重定向隐藏启动时的所有日志输出
        command = "niri-session > /dev/null 2>&1";
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
