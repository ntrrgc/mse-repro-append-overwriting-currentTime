#!/bin/bash
set -eu +x
cd "$(dirname "$0")"

rm -rf assets && mkdir -p assets

# https://mango.blender.org/download/
if [ ! -f ToS-4k-1920.mov ]; then
  wget -c -O ToS-4k-1920.mov "https://ftp.nluug.nl/pub/graphics/blender/demo/movies/ToS/ToS-4k-1920.mov"
fi

(cd assets && ffmpeg -i ../ToS-4k-1920.mov -y -ss 00:03:26.000 -to 00:03:46.000 -vcodec libx264 -acodec copy ToS-4k-1920_clip.mp4)
(cd assets && MP4Box -dash 20000 -segment-name 'audio_$Number$' 'ToS-4k-1920_clip.mp4#audio')

make_video() {
  color_name="$1"
  color_value="$2"
  key_int_max="$3"
  segment_interval="$4"

  gst-launch-1.0 \
    compositor name=comp sink_1::ypos=140 sink_2::xpos=0 sink_2::ypos=140 ! \
    videoconvert ! x264enc bframes=0 option-string="scenecut=0" key-int-max="$key_int_max" speed-preset=fast bitrate=10000 ! mp4mux ! filesink location="assets/${color_name}.mp4" \
    videotestsrc pattern=solid-color foreground-color="${color_value}" num-buffers=1200 ! \
    "video/x-raw,format=AYUV,width=1920,height=1080,framerate=(fraction)60/1" ! \
    timeoverlay font-desc="Kode Mono, 26" halignment=center ypad=6 ! queue2 ! comp. \
    uridecodebin3 uri="file://$PWD/assets/ToS-4k-1920_clip.mp4" ! videoconvert ! videoscale ! \
    "video/x-raw,format=AYUV,width=1920,height=800" ! comp. \
    videotestsrc pattern=ball background-color=0x00000000 num-buffers=1200 ! \
    "video/x-raw,format=AYUV,width=1920,height=800,framerate=(fraction)60/1" ! \
    queue2 ! comp.
  (cd assets && MP4Box -dash "$segment_interval" -segment-name '$File$_$Number$' "${color_name}.mp4")
}

#                             A R G B
make_video yellow           0xFFFFFF00 600  20000
make_video blue             0xFF0000FF 600  20000

make_video magenta_split    0xFFFF00FF 600  10000
make_video green_single_gop 0xFF00FF00 1200 20000

rm assets/*.mpd assets/{yellow,blue,magenta_split,green_single_gop}.mp4 assets/ToS-4k-1920_clip.mp4