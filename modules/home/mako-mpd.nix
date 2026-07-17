# modules/home/mako-mpd.nix
# ==========================================
# mako 通知守护进程 + MPD 音乐服务 + rmpc 客户端
# ==========================================
{ ... }:

{
  services.mako = {
    settings = {
      default-timeout = 1500;
      border-radius = 8;
      border-color = "#7fc8ff";
      border-size = 2;
      padding = "10";
      margin = "10";
      height = 100;
      width = 300;
      text-color = "#ffffff";
      background-color = "#1a1a1a";
      font = "Sans 12";
    };
    # 蓝牙相关通知降低打扰：低优先级、短暂展示
    extraConfig = ''
      [app-name="Bluetooth"] urgency=low default-timeout=1500
      [summary~="[Bb]luetooth"] urgency=low default-timeout=1500
      [summary~="[Cc]onnected"] urgency=low default-timeout=1500
    '';
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/lk/D/Music";
    extraConfig = ''
      audio_output {
      type "pipewire"
      name "PipeWire Sound Server"
      }
    '';
  };

  programs.rmpc = {
    enable = true;
    config = ''( address: "127.0.0.1:6600", )'';
  };
}
