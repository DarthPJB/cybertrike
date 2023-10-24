# CYBERTRIKE

All rights reserved, Lee Hughes and John bargman - 2023


## test-stream command with ffmpeg
``` ffmpeg -re -f lavfi -i testsrc2=size=960x540 -f lavfi -i aevalsrc="sin(0*2*PI*t)" -vcodec libx264 -r 30 -g 30 -preset fast -vb 3000k -pix_fmt rgb24 -pix_fmt yuv420p -f flv rtmp://149.5.115.135/restream ```
