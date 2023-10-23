{ config, pkgs, lib, ... }:
{

  environment.systemPackages = [
    pkgs.ffmpeg-full
  ];

  services.mediamtx =
    {
      enable = true;
      env =
        {
          stream_server = "lhr03.contribute.live-video.net";
          stream_key = "live_903856572_iUoDqW2G7htcCJCsjqeuNKKa5ccGRy";
        };
      settings =
        {
          logDestinations = [
            "stdout"
          ];
          logFile = "/var/log/mediamtx/mediamtx.log";
          logLevel = "info";
        };
      paths = {
        restream = {
          runOnInit = "echo 'MTX SERVER LOADING:'";
          runOnInitRestart = true;
          runOnReady = ''
            ffmpeg -i rtmp://localhost:6669/restream -c copy -f flv 'rtmp://''${stream_server}/app/''${stream_key}'

          '';
          runOnReadyRestart = "yes";
        };
      };
    };
  networking.firewall.allowedUDPPorts = [ 6669 ];
  networking.firewall.allowedTCPPorts = [ 6669 ];
}
