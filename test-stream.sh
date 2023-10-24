#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash

tw_stream_server="lhr03.contribute.live-video.net"
tw_stream_key="live_903856572_iUoDqW2G7htcCJCsjqeuNKKa5ccGRy"

yt_stream_server="a.rtmp.youtube.com/live2"
yt_stream_key="xuta-15b1-m92p-u41z-fxc0"

ki_stream_server="fa723fc1b171.global-contribute.live-video.net"
ki_stream_key="sk_us-west-2_FObEyLcKaSLi_RWZdhRhagoTPdjByAUWrY3L9MhOGUu"
# -filter_complex "[0:v]split=2[s0][s1];\
#[s1]crop=9/16*ih:ih[vPhone];\
#[s0]copy[vDesktop]" \

ffmpeg -re -f lavfi -i testsrc2=size=1960x1080 \
-filter_complex "[0:v]crop=9/16*ih:ih[vPhone]" \
-c:v:0 copy -map 0:a? -c:v:1 libx264 -map 0:a? \
-map 0:v:0 -map "[vPhone]" \
-f tee \
"[select=\'v:1,a\':f=flv:onfail=ignore]rtmp://${tw_stream_server}/app/${tw_stream_key}|\
[select=\'v:0,a\':f=flv:onfail=ignore]rtmp://${yt_stream_server}/app/${yt_stream_key}|\
[select=\'v:0,a\':f=flv:onfail=ignore]rtmps://${ki_stream_server}/app/${ki_stream_key}"