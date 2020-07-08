#!/usr/bin/env bash

SOURCE_FILE=$1
DEST_FRAMERATE=$2
DEST_QUALITY=$3
RTMP_KEY=$4
X264_PRESET=$5
RTMP_SERVER="rtmp://a.rtmp.youtube.com/live2"
#USABLE_THREADS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || getconf NPROCESSORS_ONLN 2>/dev/null || echo 2)"

X264_LEVEL=""
CONSTANT_BITRATE=""

if ! [ -x "$(command -v ffmpeg)" ] || ! [ -x "$(command -v ffprobe)" ]; then
  echo 'Required applications are absent, quitting :(' >&2
  exit 1
fi

function fancier_echo {
  echo "-------------" && echo "[[$(date +'%s')]] $1" && echo "-------------"
}

function print_command_before_exec {
  fancier_echo "Executing $1 with bash"
  bash -c "$1"
}

function print_and_quit {
  echo $1; echo "ffmpegLoopStream.sh [filepath] [fps] [quality] [key]"; exit 1;
}

# Some rudimentary checks before we begin
if [ -z ${SOURCE_FILE+x} ]; then
  print_and_quit "Source file missing in arguments, quitting!" >&2;
elif [ -z ${DEST_FRAMERATE+x} ]; then
  print_and_quit "Framerate missing in arguments, quitting!" >&2;
elif [ -z ${DEST_QUALITY+x} ]; then
  print_and_quit "Resolution missing in arguments, quitting!" >&2;
elif [ -z ${X264_PRESET+x} ]; then
  X264_PRESET="slow";
  print "Defaulting to ";
elif [ ! -f "$SOURCE_FILE" ]; then
  print_and_quit "Cannot locate $SOURCE_FILE or is not a valid file, quitting!" >&2;
elif ! [[ $DEST_FRAMERATE =~ ^[0-9]+$ ]]; then
  print_and_quit "Framerate is not a valid number, quitting!"  >&2;
elif ! [[ $DEST_QUALITY =~ ^[0-9]+$ ]]; then
  print_and_quit "Resolution is not a valid number, quitting!"  >&2;
fi

# https://support.google.com/youtube/answer/2853702?hl=en
function determine_quality {
  if [[ $DEST_QUALITY -le 1080 ]] && [[ $DEST_FRAMERATE -le 30 ]]; then
    X264_LEVEL="4.1";
  elif [[ $DEST_QUALITY -le 1080 ]] && [[ $DEST_FRAMERATE -le 60 ]]; then
    X264_LEVEL="4.2";
  elif [[ $DEST_QUALITY -le 1440 ]] && [[ $DEST_FRAMERATE -le 30 ]]; then
    X264_LEVEL="5.0";
  elif [[ $DEST_QUALITY -le 1080 ]] && [[ $DEST_FRAMERATE -le 60 ]]; then
    X264_LEVEL="5.1";
  elif [[ $DEST_QUALITY -le 2160 ]] && [[ $DEST_FRAMERATE -le 30 ]]; then
    X264_LEVEL="5.1";
  elif [[ $DEST_QUALITY -le 2160 ]] && [[ $DEST_FRAMERATE -le 60 ]]; then
    X264_LEVEL="5.2";
  else
    print_and_quit "Cannot determine value for x264-level, quitting! (note: $DEST_FRAMERATE fps input, the limit is 60 fps)" >&2;
  fi
}

# https://support.google.com/youtube/answer/1722171?hl=en
function determine_bitrate {
  if [[ $DEST_QUALITY -le 480 ]] && [[ $DEST_FRAMERATE -le 60 ]]; then
    CONSTANT_BITRATE="4000k";
  elif [[ $DEST_QUALITY -le 720 ]] && [[ $DEST_FRAMERATE -le 30 ]]; then
    CONSTANT_BITRATE="5000k";
  elif [[ $DEST_QUALITY -le 720 ]] && [[ $DEST_FRAMERATE -le 60 ]]; then
    CONSTANT_BITRATE="7500k";
  elif [[ $DEST_QUALITY -le 1080 ]] && [[ $DEST_FRAMERATE -le 30 ]]; then
    CONSTANT_BITRATE="8000k";
  elif [[ $DEST_QUALITY -le 1080 ]] && [[ $DEST_FRAMERATE -le 60 ]]; then
    CONSTANT_BITRATE="12000k";
  elif [[ $DEST_QUALITY -le 1440 ]] && [[ $DEST_FRAMERATE -le 30 ]]; then
    CONSTANT_BITRATE="16000k";
  elif [[ $DEST_QUALITY -le 1080 ]] && [[ $DEST_FRAMERATE -le 60 ]]; then
    CONSTANT_BITRATE="24000k";
  elif [[ $DEST_QUALITY -le 2160 ]] && [[ $DEST_FRAMERATE -le 30 ]]; then
    CONSTANT_BITRATE="45000k";
  elif [[ $DEST_QUALITY -le 2160 ]] && [[ $DEST_FRAMERATE -le 60 ]]; then
    CONSTANT_BITRATE="68000k";
  else
    print_and_quit "Cannot determine value for x264-bitrate, quitting! (note: $DEST_FRAMERATE fps input, the limit is 60 fps)" >&2;
  fi
}

determine_quality
determine_bitrate

# We want to give the impression that it is lossless, so we use a crf of 12
# https://goughlui.com/2016/08/27/video-compression-testing-x264-vs-x265-crf-in-handbrake-0-10-5/
# we also don't care about bitrate
#fancier_echo "ffmpeg will be allocated $(expr $USABLE_THREADS / 2) threads"
fancier_echo "x264-level determined to be $X264_LEVEL, x264-bitrate set to $CONSTANT_BITRATE (quality $DEST_QUALITY@$DEST_FRAMERATE fps)"
print_command_before_exec "\"ffmpeg\" -stream_loop -1 -i \"$SOURCE_FILE\" -r $DEST_FRAMERATE -g $(($DEST_FRAMERATE * 2)) -deinterlace -c:v libx264 -preset $X264_PRESET -vf scale=-2:$DEST_QUALITY -crf 12 -c:a aac -b:a 128k -threads 2 -bsf:v h264_metadata=level=$X264_LEVEL -bufsize 128k -minrate $CONSTANT_BITRATE -maxrate $CONSTANT_BITRATE -f flv \"$RTMP_SERVER/$RTMP_KEY\""
