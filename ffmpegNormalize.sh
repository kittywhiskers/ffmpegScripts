#!/usr/bin/env bash

# https://unix.stackexchange.com/a/269367
trap 'trap - SIGINT; kill -SIGINT $$' SIGINT;

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
    if [ -z ${1+x} ]; then
        echo "no files found, exiting";
    else
        if [ "${1: -9}" == "_x265.mp4" ]; then
          fancier_echo "$1 has _x265.mp4 suffix, probably already processed, testing with ffprobe";
          if /usr/local/bin/ffprobe "$1"; then
            fancier_echo "\"$1\"_x265.mp4 already processed and not corrupt, skipping, not deleting original";
          else
            fancier_echo "\"$1\"_x265.mp4 already processed but corrupt, skipping, not deleting original";
          fi
          return;
        else
          bash -c "fancier_echo \"Running ffmpeg with input $1 and output file ${1%.*}_x265.mp4\"";
          /usr/local/bin/ffmpeg -y -i "$1" -c:v libx265 -preset slow -vf scale=-2:720 -x265-params crf=18 \
           -c:a aac -b:a 128k \
          "${1%.*}_x265.mp4";
          sleep 2 && sync;
          # Now check if output passses integrity checks
          if /usr/local/bin/ffprobe "${1%.*}_x265.mp4"; then
            fancier_echo "${1%.*}_x265.mp4 passes ffprobe, deleting original";
            rm "$1";
          else
            fancier_echo "${1%.*}_x265.mp4 is corrupt, preserving original, deleting corrupt file";
            rm "${1%.*}_x265.mp4";
          fi
        fi
      fi
}

export -f process_file

fancier_echo "Regex used by find is (in quotes) -> \"$FFMPEG_SUPPORTED_EXTS\""

echo "This shell script will be executed in the directory $SCRIPT_PATH and **will** make destructive changes"
print_command_before_exec "$COMMAND_HEADER \"$FFMPEG_SUPPORTED_EXTS\" $COMMAND_FOOTER";
