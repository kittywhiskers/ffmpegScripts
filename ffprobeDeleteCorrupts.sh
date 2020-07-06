#!/usr/bin/env bash
# basically a stripped down version ffmpegNormalize.sh

if ! [ -x "$(command -v /usr/local/bin/ffmpeg)" ] || ! [ -x "$(command -v /usr/local/bin/ffprobe)" ]; then
  echo 'Required applications are absent, quitting :(' >&2
  exit 1
fi

COMMAND_HEADER="find -E . -regex "
COMMAND_FOOTER="-exec bash -c 'process_file \"\$0\"' {} \;"

SCRIPT_PATH="$(dirname "$(realpath -s "$0")")"
FFMPEG_SUPPORTED_EXTS=$(ffmpeg -demuxers -hide_banner | tail -n +5 | cut -d' ' -f4 | xargs -I {} ffmpeg -hide_banner -h demuxer={} | grep 'Common extensions' | cut -d' ' -f7 | tr ',' $'\n' | tr -d '.' | sort -u | tr '\n' ' ' | sed "s/ /|/g" | rev | cut -c2- | rev | echo ".*\.($(</dev/stdin))")

function fancier_echo {
  echo "-------------" && echo "[[$(date +'%s')]] $1" && echo "-------------"
}

function print_command_before_exec {
  fancier_echo "Executing $1 with bash"
  bash -c "$1"
}

export -f fancier_echo

function process_file {
  if /usr/local/bin/ffprobe "$1"; then
    fancier_echo "\"$1\" not corrupt, skipping, left intact";
  else
    fancier_echo "\"$1\" corrupt, deleting";
    rm "$1"
  fi
  return;
}

export -f process_file

fancier_echo "Regex used by find is (in quotes) -> \"$FFMPEG_SUPPORTED_EXTS\""

echo "This shell script will be executed in the directory $SCRIPT_PATH and **will** make destructive changes"
print_command_before_exec "$COMMAND_HEADER \"$FFMPEG_SUPPORTED_EXTS\" $COMMAND_FOOTER";
