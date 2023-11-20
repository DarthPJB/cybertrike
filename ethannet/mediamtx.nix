{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [
    pkgs.ffmpeg-full
  ];

  secrix.services.mediamtx.secrets = {
    tw_stream_key.encrypted.file = ../secrets/tw_stream_key;
    yt_stream_key.encrypted.file = ../secrets/yt_stream_key;
  };

  services.mediamtx =
    let
      #tw_stream_server = "lhr03.contribute.live-video.net/app";
      tw_stream_server = "live-lhr.twitch.tv/app";
      # tw_stream_key = "live_903856572_iUoDqW2G7htcCJCsjqeuNKKa5ccGRy";
      tw_stream_key = "$(cat ${config.secrix.services.mediamtx.secrets.tw_stream_key.decrypted.path})";

      yt_stream_server = "a.rtmp.youtube.com/live2";
      # yt_stream_key = "xuta-15b1-m92p-u41z-fxc0";
      yt_stream_key = "$(cat ${config.secrix.services.mediamtx.secrets.yt_stream_key.decrypted.path})";

      ki_stream_server = "fa723fc1b171.global-contribute.live-video.net/app";
      ki_stream_key = "sk_us-west-2_FObEyLcKaSLi_RWZdhRhagoTPdjByAUWrY3L9MhOGUu";

      tr_stream_server = "livepush.trovo.live/live";
      tr_stream_key = "73846_114751389_114751389?bizid=73846&txSecret=19f021f422f6cd41d578f258fab0cc07&txTime=77948015&cert=ea69c6d5ff2c08bbd9429820becb9fe4&certTime=64c87d15&flag=txcloud_114751389_114751389&timeshift_bps=0%7C2500%7C1500&timeshift_dur=43200&txAddTimestamp=4&tp_code=1690860821&tp_sign=1871107617&dm_sign=564503301&pq_sn=667866453&txHost=livepush.trovo.live";

      fb_stream_server = "live-api-s.facebook.com:443/rtmp";
      fb_stream_key = "FB-114005818335608-0-Abw335iVypxJ4xCA";
      restream_script = pkgs.writeShellScriptBin "restream.sh"
        ''              
            ${pkgs.ffmpeg}/bin/ffmpeg -i rtmp://localhost/restream \
            -tune zerolatency -map v:0 -map a:0 -c copy -f tee -use_fifo 1 \
            "[f=flv:onfail=ignore]rtmp://${tw_stream_server}/${tw_stream_key}|\
            [f=flv:onfail=ignore]rtmp://${yt_stream_server}/${yt_stream_key}|\
            [f=flv:onfail=ignore]rtmps://${ki_stream_server}/${ki_stream_key}|\
            [f=flv:onfail=ignore]rtmp://${tr_stream_server}/${tr_stream_key}" 

            #${pkgs.ffmpeg}/bin/ffmpeg -i rtmp://localhost/restream \
            #-tune zerolatency -f flv -maxrate 4500k -preset ultrafast -g 48 -keyint_min 48 -sc_threshold 0 \
            #-vf "crop=9/16*ih:ih" -strict -2 -ac 1 -ar 44100 -b:a 96k -pix_fmt yuv420p \
            #-map v:0 -map 0:a -c:a copy -c:v libx264 -f tee \
            #"[f=flv:onfail=ignore]rtmps://${fb_stream_server}/${fb_stream_key}" &

            #wait

        '';

      restreamsrt_script = pkgs.writeShellScriptBin "restreamsrt.sh"
        ''              
            ${pkgs.ffmpeg}/bin/ffmpeg -i srt://localhost/restreamsrt \
            -f fifo -fifo-format flv -map v:0 -map a:0 -c copy -vtag 7 -atag 7 -drop_pkts_on_overflow 1 -attempt_recovery 1 --recovery_wait_time 4 -f tee -use_fifo 1 \
            "[f=flv:onfail=ignore]rtmp://${tw_stream_server}/${tw_stream_key}|\
            [f=flv:onfail=ignore]rtmp://${yt_stream_server}/${yt_stream_key}|\
            [f=flv:onfail=ignore]rtmps://${ki_stream_server}/${ki_stream_key}|\
            [f=flv:onfail=ignore]rtmp://${tr_stream_server}/${tr_stream_key}" 

            #wait

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
          pathDefaults = {
            publishUser = "cybertrike";
            publishPass = "cybercybercybertrike";
          };
          paths = {
            restream = {
              runOnInitRestart = true;
              runOnReady = "${restream_script}/bin/restream.sh";
              runOnReadyRestart = true;
            };
            restreamtest = {
            #publishUser = "cybertrike";
            #publishPass = "cybercybercybertrike";
              #runOnInitRestart = true;
              #runOnReady = "${restreamsrt_script}/bin/restreamsrt.sh";
              #runOnReadyRestart = true;
            };

          };
        };
    };
  networking.firewall.allowedUDPPorts = [ 6669 8000 8001 8890 ];
  networking.firewall.allowedTCPPorts = [ 6669 8888 8889 8554 1935 ];
  users = {
    users.mediamtx = {
      isSystemUser = true;
      group = "mediamtx";
    };
    groups.mediamtx = { };
  };
}
