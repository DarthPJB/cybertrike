{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [
    pkgs.ffmpeg-full
  ];

  services.mediamtx =
    let
      tw_stream_server = "lhr03.contribute.live-video.net";
      tw_stream_key = "live_903856572_iUoDqW2G7htcCJCsjqeuNKKa5ccGRy";

      yt_stream_server = "a.rtmp.youtube.com/live2";
      yt_stream_key = "xuta-15b1-m92p-u41z-fxc0";

      ki_stream_server = "fa723fc1b171.global-contribute.live-video.net";
      ki_stream_key = "sk_us-west-2_FObEyLcKaSLi_RWZdhRhagoTPdjByAUWrY3L9MhOGUu";
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
#                ${pkgs.ffmpeg}/bin/ffmpeg -i rtmp://localhost/restream \
#                -filter_complex "[0:v]crop=9/16*ih:ih[vPhone]"
#                -c:v libx264 -map 0:a -map "[vPhone]" -f tee \
#                "[f=flv:onfail=ignore]rtmp://${tw_stream_server}/app/${tw_stream_key}"&;
#                |\
              runOnReady = ''              
                ${pkgs.ffmpeg}/bin/ffmpeg -i rtmp://localhost/restream -c copy -map 0:v -map 0:a -f tee \
                "[f=flv:onfail=ignore]rtmp://${tw_stream_server}/app/${tw_stream_key}|[f=flv:onfail=ignore]rtmps://${ki_stream_server}/app/${ki_stream_key}|[f=flv:onfail=ignore]rtmp://${yt_stream_server}/app/${yt_stream_key}"'';
              runOnReadyRestart = true;
            };
          };
        };
    };
  networking.firewall.allowedUDPPorts = [ 6669 8000 8001 8890 ];
  networking.firewall.allowedTCPPorts = [ 6669 8888 8889 8554 1935 ];
}
