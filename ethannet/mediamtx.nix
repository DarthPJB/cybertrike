{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [
    pkgs.ffmpeg-full
  ];

  services.mediamtx =
    let
      tw_stream_server = "lhr03.contribute.live-video.net/app";
      tw_stream_key = "live_903856572_iUoDqW2G7htcCJCsjqeuNKKa5ccGRy";

      yt_stream_server = "a.rtmp.youtube.com/live2";
      yt_stream_key = "xuta-15b1-m92p-u41z-fxc0";

      ki_stream_server = "fa723fc1b171.global-contribute.live-video.net/app";
      ki_stream_key = "sk_us-west-2_FObEyLcKaSLi_RWZdhRhagoTPdjByAUWrY3L9MhOGUu";

      tr_stream_server = "rtmp://livepush.trovo.live/live/";
      tr_stream_key = "sk_us-west-2_FObEyLcKaSLi_RWZdhRhagoTPdjByAUWrY3L9MhOGUu";

      fb_stream_server = "live-api-s.facebook.com:443/rtmp";
      fb_stream_key = "FB-114005818335608-0-Abw335iVypxJ4xCA";
      restream_script = pkgs.writeShellScriptBin "restream.sh"
        ''              
            ${pkgs.ffmpeg}/bin/ffmpeg -i rtmp://localhost/restream \
            -tune zerolatency -map v:0 -map a:0 -c copy -f tee \
            "[f=flv:onfail=ignore]rtmp://${tw_stream_server}/${tw_stream_key}|\
            [f=flv:onfail=ignore]rtmp://${yt_stream_server}/${yt_stream_key}|\
            [f=flv:onfail=ignore]rtmps://${ki_stream_server}/${ki_stream_key}|\
            [f=flv:onfail=ignore]rtmps://${tr_stream_server}/${tr_stream_key}" &

            ${pkgs.ffmpeg}/bin/ffmpeg -i rtmp://localhost/restream \
            -tune zerolatency -f flv -maxrate 4500k -preset ultrafast -g 48 -keyint_min 48 -sc_threshold 0 \
            -vf "crop=9/16*ih:ih" -strict -2 -ac 1 -ar 44100 -b:a 96k -pix_fmt yuv420p \
            -map v:0 -map 0:a -c:a copy -c:v libx264 -f tee \
            "[f=flv:onfail=ignore]rtmps://${fb_stream_server}/${fb_stream_key}" &

            wait

        '';
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
              runOnReady = "${restream_script}/bin/restream.sh";
              runOnReadyRestart = true;
            };

          };
        };
    };
  networking.firewall.allowedUDPPorts = [ 6669 8000 8001 8890 ];
  networking.firewall.allowedTCPPorts = [ 6669 8888 8889 8554 1935 ];
}
