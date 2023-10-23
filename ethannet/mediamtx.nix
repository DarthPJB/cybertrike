{ config, pkgs, lib, ... }:
{
  services.mediamtx =
    {
      enable = true;
      env =
        { };
      settings =
        {
          logDestinations = [
            "stdout"
          ];
          logFile = "/var/log/mediamtx/mediamtx.log";
          logLevel = "info";
        };
      paths = {
        cam = {
          runOnInit = "ffmpeg -f v4l2 -i /dev/video0 -f rtsp rtsp://localhost:$RTSP_PORT/$RTSP_PATH";
          runOnInitRestart = true;
        };
      };
    };
}
