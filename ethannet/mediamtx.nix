{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [
    pkgs.ffmpeg-full
  ];

  services.mediamtx =
    let
      stream_server = "lhr03.contribute.live-video.net";
      stream_key = "live_903856572_iUoDqW2G7htcCJCsjqeuNKKa5ccGRy";
    in
    {
      enable = true;
      settings =
        {
          logDestinations = [
            "stdout"
          ];
          logFile = "/var/log/mediamtx/mediamtx.log";
          logLevel = "debug";
          paths = {
            restream = {
              runOnInitRestart = true;
              runOnReady = ''
                ${pkgs.ffmpeg}/bin/ffmpeg -i rtmp://localhost/restream -c copy -f flv rtmp://${stream_server}/app/${stream_key}'';
              runOnReadyRestart = true;
            };
          };
        };
    };
  networking.firewall.allowedUDPPorts = [ 6669 8000 8001 8890 ];
  networking.firewall.allowedTCPPorts = [ 6669 8888 8889 8554 1935 ];
}
