{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [
    pkgs.ffmpeg-full
  ];

  services.mediamtx =
    let
      stream_server_twitch = "lhr03.contribute.live-video.net";
      stream_key_twitch = "live_903856572_iUoDqW2G7htcCJCsjqeuNKKa5ccGRy";

      stream_server_youtube = "a.rtmp.youtube.com/live2";
      stream_key_youtube = "xuta-15b1-m92p-u41z-fxc0";

      stream_server_kick = "fa723fc1b171.global-contribute.live-video.net";
      stream_key_kick = "sk_us-west-2_FObEyLcKaSLi_RWZdhRhagoTPdjByAUWrY3L9MhOGUu";
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
                ${pkgs.ffmpeg}/bin/ffmpeg -i rtmp://localhost/restream -c copy -f flv rtmp://${stream_server_twitch}/app/${stream_key_twitch} -c copy -f flv rtmp://${stream_server_kick}/app/${stream_key_kick}'';
              runOnReadyRestart = true;
            };
          };
        };
    };
  networking.firewall.allowedUDPPorts = [ 6669 8000 8001 8890 ];
  networking.firewall.allowedTCPPorts = [ 6669 8888 8889 8554 1935 ];
}
