# CYBERTRIKE

All rights reserved, Lee Hughes and John bargman - 2023


## test-stream command with ffmpeg
``` bash
ffmpeg -re -f lavfi -i testsrc2=size=960x540 -f lavfi -i aevalsrc="sin(0*2*PI*t)" -acodec aac -vcodec libx264 -r 30 -g 30 -preset fast -vb 4500k -pix_fmt yuv420p -f flv rtmp://149.5.115.135/restream
```
