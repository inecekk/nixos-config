{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd '${pkgs.niri}/bin/niri-session'";
        user = "lk";
      };
    };
  };

}
